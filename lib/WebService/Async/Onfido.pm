package WebService::Async::Onfido;
# ABSTRACT: Webservice to connect to Onfido API

use strict;
use warnings;

our $VERSION = '0.001';

use parent qw(IO::Async::Notifier);

=head1 NAME

WebService::Async::Onfido - unofficial support for the Onfido identity verification service

=head1 SYNOPSIS


=head1 DESCRIPTION

=cut

use mro;
no indirect;

use Syntax::Keyword::Try;
use Dir::Self;
use URI;
use URI::QueryParam;
use URI::Template;
use Ryu::Async;

use Future;
use Future::Utils qw(repeat);
use File::Basename;
use Path::Tiny;
use Net::Async::HTTP;
use HTTP::Request::Common;
use JSON::MaybeUTF8 qw(:v1);
use JSON::MaybeXS;
use File::ShareDir;
use URI::Escape qw(uri_escape_utf8);

use WebService::Async::Onfido::Applicant;
use WebService::Async::Onfido::Address;
use WebService::Async::Onfido::Document;
use WebService::Async::Onfido::Photo;
use WebService::Async::Onfido::Video;
use WebService::Async::Onfido::Check;
use WebService::Async::Onfido::Report;

use Log::Any qw($log);

# Mapping file extension to mime type for currently
# supported document types
my %FILE_MIME_TYPE_MAPPING = (
    jpg  => 'image/jpeg',
    jpeg => 'image/jpeg',
    png  => 'image/png',
    pdf  => 'application/pdf',
);

sub configure {
    my ($self, %args) = @_;
    for my $k (qw(token requests_per_minute)) {
        $self->{$k} = delete $args{$k} if exists $args{$k};
    }
    $self->next::method(%args);
}

=head2 applicant_list

Retrieves a list of all known applicants.

Returns a L<Ryu::Source> which will emit one L<WebService::Async::Onfido::Applicant> for
each applicant found.

=cut

sub applicant_list {
    my ($self, %args) = @_;
    my $src = $self->source;
    my $f = $src->completed;
    my $uri = $self->endpoint('applicants');
    (repeat {
        $log->tracef('GET %s', "$uri");
        $self->rate_limiting->then(sub {
            $self->ua->GET(
                $uri,
                $self->auth_headers,
            )
        })->then(sub {
            try {
                my ($res) = @_;
                my $data = decode_json_utf8($res->content);
                $log->tracef('Have response %s', $data);
                my ($total) = $res->header('X-Total-Count');
                $log->tracef('Expected total count %d', $total);
                for(@{$data->{applicants}}) {
                    return $f if $f->is_ready;
                    $src->emit(
                        WebService::Async::Onfido::Applicant->new(
                            %$_,
                            onfido => $self
                        )
                    );
                }
                $log->tracef('Links are %s', [ $res->header('Link') ]);
                my %links = $self->extract_links($res->header('Link'));
                if(my $next = $links{next}) {
                    ($uri) = $next;
                } else {
                    $f->done unless $f->is_ready;
                }
                return Future->done;
            } catch {
                my ($err) = $@;
                $log->errorf('Failed - %s', $err);
                return Future->fail($err);
            }
        }, sub {
            my ($err, @details) = @_;
            $log->errorf('Failed to request document_list: %s', $err);
            $src->completed->fail($err, @details) unless $src->completed->is_ready;
            Future->fail($err, @details);
        })
    } until => sub { $f->is_ready })->retain;
    return $src;
}

=head2 extract_links

Given a set of strings representing the C<Link> headers in an HTTP response,
extracts the URIs based on the C<rel> attribute as described in
L<RFC5988|http://tools.ietf.org/html/rfc5988>.

Returns a list of key, value pairs where the key contains the lowercase C<rel> value
and the value is a L<URI> instance.

 my %links = $self->extract_links($res->header('Link'))
 print "Last page would be $links{last}"

=cut

sub extract_links {
    my ($self, @links) = @_;
    my %links;
    for (map { split /\h*,\h*/ } @links) {
        # Format is like:
        # <https://api.onfido.com/v2/applicants?page=2>; rel="next"
        if(my ($url, $rel) = m{<(http[^>]+)>;\h*rel="([^"]+)"}) {
            $links{lc $rel} = URI->new($url);
        }
    }
    return %links
}

=head2 applicant_create

Creates a new applicant record.

See accessors in L<WebService::Async::Onfido::Applicant> for a full list of supported attributes.
These can be passed as named parameters to this method.

Returns a L<Future> which resolves to a L<WebService::Async::Onfido::Applicant>
instance on successful completion.

=cut

sub applicant_create {
    my ($self, %args) = @_;
    $self->rate_limiting->then(sub {
        $self->ua->POST(
            $self->endpoint('applicants'),
            encode_json_utf8(\%args),
            content_type => 'application/json',
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->done(
                WebService::Async::Onfido::Applicant->new(
                    %$data,
                    onfido => $self
                )
            );
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

=head2 applicant_delete

Deletes a single applicant.

Returns a L<Future> which resolves to empty on success.

=cut

sub applicant_delete {
    my ($self, %args) = @_;
    $self->rate_limiting->then(sub {
        $self->ua->do_request(
            uri => $self->endpoint('applicant', %args),
            method => 'DELETE',
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            return Future->done if $res->code == 204;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->fail($data);
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

=head2 applicant_get

Retreive a single applicant.

Returns a L<Future> which resolves to a L<WebService::Async::Onfido::Applicant>

=cut

sub applicant_get {
    my ($self, %args) = @_;
    $self->rate_limiting->then(sub {
        $self->ua->do_request(
            uri => $self->endpoint('applicant', %args),
            method => 'GET',
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->done(
                WebService::Async::Onfido::Applicant->new(
                    %$data,
                    onfido => $self
                )
            );
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

=head2 document_list

List all documents for a given L<WebService::Async::Onfido::Applicant>.

Takes the following named parameters:

=over 4

=item * C<applicant_id> - the L<WebService::Async::Onfido::Applicant/id> for the applicant to query

=back

Returns a L<Ryu::Source> which will emit one L<WebService::Async::Onfido::Document> for
each document found.

=cut

sub document_list {
    my ($self, %args) = @_;
    my $src = $self->source;
    my $uri = $self->endpoint('documents', %args);
    $self->rate_limiting->then(sub {
        $self->ua->GET(
            $uri,
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            $log->tracef("GET %s => %s", $uri, $res->decoded_content);
            my $data = decode_json_utf8($res->content);
            my $f = $src->completed;
            $log->tracef('Have response %s', $data);
            for(@{$data->{documents}}) {
                return $f if $f->is_ready;
                $src->emit(
                    WebService::Async::Onfido::Document->new(
                        %$_,
                        onfido => $self
                    )
                );
            }
            $f->done unless $f->is_ready;
            return Future->done;
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            $src->completed->fail('Failed to get document list.') unless $src->completed->is_ready;
            return Future->fail($err);
        }
    })->retain;
    return $src;
}

=head2 photo_list

List all photos for a given L<WebService::Async::Onfido::Applicant>.

Takes the following named parameters:

=over 4

=item * C<applicant_id> - the L<WebService::Async::Onfido::Applicant/id> for the applicant to query

=back

Returns a L<Ryu::Source> which will emit one L<WebService::Async::Onfido::Photo> for
each photo found.

=cut

sub photo_list {
    my ($self, %args) = @_;
    my $src = $self->source;
    my $uri = $self->endpoint('photos', %args);
    $self->rate_limiting->then(sub {
        $self->ua->GET(
            $uri,
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            $log->tracef("GET %s => %s", $uri, $res->decoded_content);
            my $data = decode_json_utf8($res->content);
            my $f = $src->completed;
            $log->tracef('Have response %s', $data);
            for(@{$data->{live_photos}}) {
                return $f if $f->is_ready;
                $src->emit(
                    WebService::Async::Onfido::Photo->new(
                        %$_,
                        onfido => $self
                    )
                );
            }
            $f->done unless $f->is_ready;
            return Future->done;
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            $src->completed->fail('Failed to get photo list.') unless $src->completed->is_ready;
            return Future->fail($err);
        }
    })->retain;
    return $src;
}

=head2 document_upload

Uploads a single document for a given applicant.

Takes the following named parameters:

=over 4

=item * C<type> - can be C<passport>, C<photo>, C<poa>

=item * C<side> - which side, either C<front> or C<back>

=item * C<issuing_country> - which country this document is for

=item * C<filename> - the file name to use for this item

=item * C<data> - the bytes for this image file (must be in JPEG format)

=back

=cut

sub document_upload {
    my ($self, %args) = @_;
    my $uri = $self->endpoint('documents', applicant_id => delete $args{applicant_id});
    my $req = HTTP::Request::Common::POST(
        $uri,
        content_type => 'form-data',
        content => [
            %args{grep { exists $args{$_} } qw(type side issuing_country)},
            file => [ undef, $args{filename}, 'Content-Type' => _get_mime_type($args{filename}), Content => $args{data} ],
        ],
        %{$self->auth_headers},
    );
    $self->rate_limiting->then(sub {
        $self->ua->do_request(
            request => $req,
        )
    })->catch(
        http => sub {
            my ($message, undef, $response, $request) = @_;
            $log->errorf('Request %s received %s with full response as %s',
                $request->uri,
                $message,
                $response->as_string("\n"),
            );
            # Just pass it on
            Future->fail($message, http => $response, $request);
        }
    )->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->done(
                WebService::Async::Onfido::Document->new(
                    %$data,
                    onfido => $self
                )
            );
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

=head2 live_photo_upload

Uploads a single "live photo" for a given applicant.

Takes the following named parameters:

=over 4

=item * C<applicant_id> - ID for the person this photo relates to

=item * C<advanced_validation> - perform additional validation (ensure we only have a single face)

=item * C<filename> - the file name to use for this item

=item * C<data> - the bytes for this image file (must be in JPEG format)

=back

=cut

sub live_photo_upload {
    my ($self, %args) = @_;
    my $uri = $self->endpoint('photo_upload');
    $args{advanced_validation} = $args{advanced_validation} ? 'true' : 'false';
    my $req = HTTP::Request::Common::POST(
        $uri,
        content_type => 'form-data',
        content => [
            %args{grep { exists $args{$_} } qw(advanced_validation applicant_id)},
            file => [ undef, $args{filename}, 'Content-Type' => _get_mime_type($args{filename}), Content => $args{data} ],
        ],
        %{$self->auth_headers},
    );
    $log->tracef('Photo upload: %s', $req->as_string("\n"));
    $self->rate_limiting->then(sub {
        $self->ua->do_request(
            request => $req,
        )
    })->catch(
        http => sub {
            my ($message, undef, $response, $request) = @_;
            $log->errorf('Request %s received %s with full response as %s',
                $request->uri,
                $message,
                $response->as_string("\n"),
            );
            # Just pass it on
            Future->fail($message, http => $response, $request);
        }
    )->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->done(
                WebService::Async::Onfido::Photo->new(
                    %$data,
                    onfido => $self
                )
            );
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

=head2 applicant_check

Perform an identity check on an applicant.

This is the main method for dealing with verification - once you have created
the applicant and uploaded some documents, call this to start the process of
checking the documents and details, and generating the reports.

L<https://documentation.onfido.com/#check-object>

Takes the following named parameters:

=over 4

=item * C<type> - either C<standard> or C<express>

=item * C<reports> - the reports to generate for this applicant (arrayref)

=item * C<tags> - custom tags to apply to these reports

=item * C<suppress_form_emails> - if true, do B<not> send out the email to
the applicant

=item * C<async> - return immediately and perform check in the background

=item * C<charge_applicant_for_check> - the applicant must enter payment
details for this check, and it will not count towards the quota for this
service account

=item * C<consider> - used for sandbox API testing only

Returns a L<Future> which will resolve with the result.

=cut

sub applicant_check {
    my ($self, %args) = @_;
    $args{type} //= 'standard';
    $_ = $_ ? 'true' : 'false' for @args{qw(
        suppress_form_emails async charge_applicant_for_check
    )};
    my $reports = delete $args{reports};
    my $tags = delete $args{tags};
    my @content = map { uri_escape_utf8($_) . '=' . uri_escape_utf8($args{$_}) } sort keys %args;
    push @content, "reports[][name]=" . uri_escape_utf8($_) for @{$reports || []};
    push @content, "tags[]=" . uri_escape_utf8($_) for @{$tags || []};
    $self->rate_limiting->then(sub {
        $self->ua->POST(
            $self->endpoint('checks', applicant_id => delete $args{applicant_id}),
            join('&', @content),
            content_type => 'application/x-www-form-urlencoded',
            $self->auth_headers,
        )
    })->catch(
        http => sub {
            my ($message, undef, $response, $request) = @_;
            $log->errorf('Request %s received %s with full response as %s',
                $request->as_string("\n"),
                $message,
                $response->as_string("\n"),
            );
            # Just pass it on
            Future->fail($message, http => $response, $request);
        }
    )->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            return Future->done(
                WebService::Async::Onfido::Check->new(
                    %$data,
                    onfido => $self
                )
            );
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })
}

sub check_list {
    my ($self, %args) = @_;
    my $applicant_id = delete $args{applicant_id} or die 'Need an applicant ID';
    my $src = $self->source;
    my $f = $src->completed;
    my $uri = $self->endpoint('checks', applicant_id => $applicant_id);
    $log->tracef('GET %s', "$uri");
    $self->rate_limiting->then(sub {
        $self->ua->do_request(
            uri    => $uri,
            method => 'GET',
            $self->auth_headers,
        )
    })->then(sub {
        try {
            my ($res) = @_;
            my $data = decode_json_utf8($res->content);
            $log->tracef('Have response %s', $data);
            my ($total) = $res->header('X-Total-Count');
            $log->tracef('Expected total count %d', $total);
            for(@{$data->{checks}}) {
                return $f if $f->is_ready;
                $src->emit(
                    WebService::Async::Onfido::Check->new(
                        %$_,
                        onfido => $self
                    )
                );
            }
            $f->done unless $f->is_ready;
            Future->done;
        } catch {
            my ($err) = $@;
            $log->errorf('Failed - %s', $err);
            return Future->fail($err);
        }
    })->retain;
    return $src;
}

=head2 endpoints

Returns an accessor for the endpoints data. This is a hashref containing URI
templates, used by L</endpoint>.

=cut

sub endpoints {
    my ($self) = @_;
    $self->{endpoints} ||= do {
        my $path = Path::Tiny::path(__DIR__)->parent(3)->child('share/endpoints.json');
        $path = Path::Tiny::path(
            File::ShareDir::dist_file(
                'WebService-Async-Onfido',
                'endpoints.json'
            )
        ) unless $path->exists;
        my $endpoints = decode_json_text($path->slurp_utf8);
        my $base_uri = $self->base_uri;
        $_ = $base_uri . $_ for values %$endpoints;
        $endpoints
    };
}

=head2 endpoint

Expands the selected URI via L<URI::Template>. Each item is defined in our C<endpoints.json>
file.

Returns a L<URI> instance.

=cut

sub endpoint {
    my ($self, $endpoint, %args) = @_;
    URI::Template->new(
        $self->endpoints->{$endpoint}
    )->process(%args);
}

sub base_uri { shift->{base_uri} //= URI->new('https://api.onfido.com') }

sub token { shift->{token} }

sub ua {
    my ($self) = @_;
    $self->{ua} //= do {
        $self->add_child(
            my $ua = Net::Async::HTTP->new(
                fail_on_error            => 1,
                decode_content           => 1,
                pipeline                 => 0,
                stall_timeout            => 60,
                max_connections_per_host => 4,
                user_agent               => 'Mozilla/4.0 (WebService::Async::Onfido; BINARY@cpan.org; https://metacpan.org/pod/WebService::Async::Onfido)',
            )
        );
        $ua
    }
}

sub auth_headers {
    my ($self) = @_;
    return headers => {
        'Authorization' => 'Token token=' . $self->token
    }
}

sub ryu {
    my ($self) = @_;
    $self->{ryu} //= do {
        $self->add_child(
            my $ryu = Ryu::Async->new
        );
        $ryu
    }
}

=head2 is_rate_limited

Returns true if we are currently rate limited, false otherwise.

May eventually be updated to return number of seconds that you need to wait.

=cut

sub is_rate_limited {
    my ($self) = @_;
    return $self->{rate_limit} && $self->{request_count} >= $self->requests_per_minute; 
}

=head2 rate_limiting

Applies rate limiting check.

Returns a L<Future> which will resolve once it's safe to send further requests.

=cut

sub rate_limiting {
    my ($self) = @_;
    $self->{rate_limit} //= do {
        $self->loop->delay_future(
            after => 60
        )->on_ready(sub {
            $self->{request_count} = 0;
            delete $self->{rate_limit};
        })
    };
    return Future->done unless $self->requests_per_minute and ++$self->{request_count} >= $self->requests_per_minute;
    return $self->{rate_limit};
}

sub requests_per_minute { shift->{requests_per_minute} //= 300 }

sub source {
    my ($self) = shift;
    $self->ryu->source(@_)
}

sub _get_mime_type {
    my $filename = shift;

    my $ext = (fileparse($filename, "[^.]+"))[2];

    return $FILE_MIME_TYPE_MAPPING{lc($ext // '')} // 'application/octet-stream';
}

1;

__END__

=head1 AUTHOR

binary.com

=head1 COPYRIGHT

Copyright Binary.com 2019.

=head1 LICENSE

Licensed under the same terms as Perl5 itself.

