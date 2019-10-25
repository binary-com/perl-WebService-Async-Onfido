# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Clone 'clone';
use Data::Dumper;
use Date::Utility;
use Data::UUID;
use File::Basename;
use Path::Tiny;

# In this script we think the key like '_xxxxx' in hash as private keys. Will not send them
plugin 'RenderFile';
# try https://metacpan.org/source/MASAKI/Test-Fake-HTTPD-0.08/t/10_http.t this one
# Route with placeholder
my $applicant_template;
my $check_template;
# $applicants{$app_id}
my %applicants;
my %deleted_applicants;
# $documents{$app_id}{$doc_id} file
my %documents;
# $photos{$photo_id}
my %photos;
# $files{$doc_id}
# $files{$photo_id}
my %files;
my %reports;
my %checks;
################################################################################
# applicants
# create applicant
post '/v2/applicants' => sub {
    my $c         = shift;
    my $data      = $c->req->json;
    my $applicant = clone($applicant_template);
    my $id        = $applicant->{id} = Data::UUID->new->create_str();
    $applicant->{href} = "v2/applicants/$id";
    for my $k (keys %$data) {
        $applicant->{$k} = $data->{$k};
    }
    $applicant->{created_at} = Date::Utility->new()->datetime_iso8601;
    $applicants{$id} = $applicant;
    $c->render(json => $applicant);
};

get '/v2/applicants' => sub {
    my $c = shift;
    # TODO page
    return $c->render(json => {applicants => [sort { $b->{created_at} cmp $a->{created_at} } values %applicants]});
};

put '/v2/applicants/:id' => sub {
    my $c         = shift;
    my $id        = $c->stash('id');
    my $applicant = $applicants{$id};
    my $data      = $c->req->json;
    for my $k (keys %$data) {
        $applicant->{$k} = $data->{$k};
    }
    $c->render(json => $applicant);
};

get '/v2/applicants/:id' => sub {
    my $c  = shift;
    my $id = $c->stash('id');
    # There is no description that what result should be if there is no such applicant.
    # So return 'Not Found' temporarily
    my $applicant = $applicants{$id} // {status => 'Not Found'};
    $c->render(json => $applicant);
};

del '/v2/applicants/:id' => sub {
    my $c  = shift;
    my $id = $c->stash('id');
    if (exists $applicants{$id}) {
        $deleted_applicants{$id} = delete $applicants{$id};
        $deleted_applicants{$id}->{delete_at} = Date::Utility->new()->datetime_iso8601;
    }
    $c->render(
        status => 204,
        json   => {status => 'delete ok'});
};

################################################################################
# documents

post '/v2/applicants/:applicant_id/documents' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $document_id  = Data::UUID->new->create_str();
    my $document     = {
        id            => $document_id,
        created_at    => Date::Utility->new()->datetime_iso8601,
        href          => "/v2/applicants/$applicant_id/documents/$document_id",
        download_href => "/v2/applicants/$applicant_id/documents/$document_id/download",
    };
    for my $param (qw(type side issuing_country)) {
        $document->{$param} = $c->param($param);
    }
    my $file = $c->param('file');
    $document->{file_name} = basename($file->filename);
    $document->{file_size} = $file->size;
    $document->{file_type} = $file->headers->content_type;
    $files{$document_id}   = Path::Tiny->tempfile;
    $file->move_to($files{$document_id}->stringify);
    $documents{$applicant_id}{$document_id} = $document;
    return $c->render(json => $document);
};

get '/v2/applicants/:applicant_id/documents' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    unless (exists($documents{$applicant_id})) {
        return $c->render(json => {status => 'Not Found'});
    }
    my @documents = values $documents{$applicant_id}->%*;
    @documents = sort { $b->{created_at} cmp $a->{created_at} } @documents;
    return $c->render(json => {documents => \@documents});
};

get '/v2/applicants/:applicant_id/documents/:document_id' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $document_id  = $c->stash('document_id');
    unless (exists($documents{$applicant_id}) && exists($documents{$applicant_id}{$document_id})) {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render(json => $documents{$applicant_id}{$document_id});
};

get '/v2/applicants/:applicant_id/documents/:document_id/download' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $document_id  = $c->stash('document_id');
    unless (exists($documents{$applicant_id}) && exists($documents{$applicant_id}{$document_id})) {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render_file(
        'filepath'     => $files{$document_id}->stringify,
        'filename'     => $documents{$applicant_id}{$document_id}{file_name},
        'content_type' => $documents{$applicant_id}{$document_id}{file_type},
    );
};

post '/v2/live_photos' => sub {
    my $c            = shift;
    my $applicant_id = $c->param('applicant_id');
    # don't know how to used yet
    #my $advanced_validation = $c->param('advanced_validation');
    my $photo_id = Data::UUID->new->create_str();
    my $photo    = {
        id            => $photo_id,
        created_at    => Date::Utility->new()->datetime_iso8601,
        href          => "/v2/live_photos/$photo_id",
        download_href => "/v2/live_photos/$photo_id/download",
    };
    my $file = $c->param('file');
    $photo->{file_name} = basename($file->filename);
    $photo->{file_size} = $file->size;
    $photo->{file_type} = $file->headers->content_type;
    $files{$photo_id}   = Path::Tiny->tempfile;
    $file->move_to($files{$photo_id}->stringify);
    $photo->{_applicant_id} = $applicant_id;
    $photos{$photo_id} = $photo;
    return $c->render(json => clone_and_remove_private($photo));
};

get '/v2/live_photos' => sub {
    my $c            = shift;
    my $applicant_id = $c->param('applicant_id');
    my @photos =
        sort { $b->{created_at} cmp $a->{created_at} }
        map { clone_and_remove_private($_) } grep { $_->{_applicant_id} eq $applicant_id } values %photos;
    return $c->render(json => {live_photos => \@photos});
};

get '/v2/live_photos/:photo_id' => sub {
    my $c        = shift;
    my $photo_id = $c->stash('photo_id');
    my $photo    = clone_and_remove_private($photos{$photo_id});
    return $c->render(json => {status => 'Not Found'}) unless $photo;
    return $c->render(json => $photo);
};

get '/v2/live_photos/:photo_id/download' => sub {
    my $c        = shift;
    my $photo_id = $c->stash('photo_id');
    unless (exists($photos{$photo_id})) {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render_file(
        'filepath'     => $files{$photo_id}->stringify,
        'filename'     => $photos{$photo_id}{file_name},
        'content_type' => $photos{$photo_id}{file_type},
    );

};

sub create_report {
    my ($c, $check_id) = @_;
    use URI::Escape qw(uri_unescape);
    my $params = $c->req->params->to_string;
    $params = uri_unescape($params);
    my @params = map { s/reports|\[|\]//g; $_ } grep { /reports/ } split '&', $params;
    my @req_reports;
    my $req_report;
    for my $param (@params) {
        my @pair = split '=', $param;
        # name always be first pair
        if ($pair[0] eq 'name') {
            push @req_reports, $req_report if $req_report;
            $req_report = {@pair};
        } else {
            $req_report->{$pair[0]} = $pair[1];
        }
    }
    push @req_reports, $req_report;
    my @reports;
    for my $req (@req_reports) {
        my $report_id = Data::UUID->new->create_str();
        my $report    = {
            id         => $report_id,
            _check_id  => $check_id,
            created_at => Date::Utility->new()->datetime_iso8601,
        };
        $reports{$report_id} = $report;
        push @reports, $report_id;
    }
    return \@reports;
}

post '/v2/applicants/:applicant_id/checks' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $check_id     = Data::UUID->new->create_str();
    my $check        = {
        id            => $check_id,
        created_at    => Date::Utility->new()->datetime_iso8601,
        href          => "/v2/applicants/$applicant_id/checks/$check_id",
        type          => $c->param('type'),
        status        => 'complete',
        result        => 'clear',
        redirect_uri  => 'https://somewhere.else',
        results_uri   => "https://onfido.com/dashboard/information_requests/<REQUEST_ID>",
        download_uri  => "https://onfido.com/dashboard/pdf/information_requests/<REQUEST_ID>",
        reports       => create_report($c),
        tags          => $c->req->params->to_hash->{'tags[]'},
        _applicant_id => $applicant_id,
    };
    $checks{$check_id} = $check;
    return $c->render(json => clone_and_remove_private($check));
};

get '/v2/applicants/:applicant_id/checks/:check_id' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $check_id     = $c->stash('check_id');
    unless (exists($applicants{$applicant_id}) && exists($checks{$check_id})) {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render(json => clone_and_remove_private($checks{$check_id}));
};

get '/v2/applicants/:applicant_id/checks' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my @checks =
        sort { $b->{created_at} cmp $a->{created_at} }
        map { clone_and_remove_private($_) } grep { $_->{_applicant_id} eq $applicant_id } values %checks;
    return $c->render(json => {checks => \@checks});
};

get '/v2/checks/:check_id/reports' => sub {
    my $c        = shift;
    my $check_id = $c->stash('check_id');
    my @reports =
        sort { $b->{created_at} cmp $a->{created_at} }
        map { clone_and_remove_private($_) } grep { $_->{_check_id} eq $check_id } values %reports;
    return $c->render(json => {reports => \@reports});
};

sub clone_and_remove_private {
    my $result = shift;
    return $result unless $result && ref($result) eq 'HASH';
    $result = clone($result);
    for my $k (keys %$result) {
        if ($k =~ /^_/) {
            delete $result->{$k};
        }
    }
    return $result;
}

$applicant_template = {
    "id"                  => "123456",
    "created_at"          => "2014-05-23T13:50:33Z",
    "delete_at"           => "2018-10-31T04:39:52Z",
    "href"                => "/v2/applicants/12345",
    "title"               => "Mr",
    "first_name"          => "John",
    "middle_name"         => undef,
    "last_name"           => "Smith",
    "email"               => 'john@example.com',
    "gender"              => "Male",
    "dob"                 => "1980-01-22",
    "telephone"           => "02088909293",
    "mobile"              => undef,
    "country"             => "GBR",
    "mothers_maiden_name" => "Johnson",
    "previous_last_name"  => undef,
    "nationality"         => "USA",
    "country_of_birth"    => "USA",
    "town_of_birth"       => "New York City",
    "id_numbers"          => [{
            "type"  => "ssn",
            "value" => "433-54-3937"
        },
        {
            "type"       => "driving_licence",
            "value"      => "I1234562",
            "state_code" => "CA"
        }
    ],
    "addresses" => [{
            "flat_number"     => undef,
            "building_name"   => undef,
            "building_number" => "100",
            "street"          => "Main Street",
            "sub_street"      => undef,
            "state"           => undef,
            "town"            => "London",
            "postcode"        => "SW4 6EH",
            "country"         => "GBR",
            "start_date"      => "2013-01-01",
            "end_date"        => undef
        },
        {
            "flat_number"     => "Apt 2A",
            "building_name"   => undef,
            "building_number" => "1017",
            "street"          => "Oakland Ave",
            "sub_street"      => undef,
            "town"            => "Piedmont",
            "state"           => "CA",
            "postcode"        => "94611",
            "country"         => "USA",
            "start_date"      => "2006-03-07",
            "end_date"        => "2012-12-31"
        }]};

$check_template = {
    "id"           => "<CHECK_ID>",
    "created_at"   => "2014-05-23T13:50:33Z",
    "href"         => "/v2/applicants/<APPLICANT_ID>/checks/<CHECK_ID>",
    "type"         => "express",
    "status"       => "complete",
    "result"       => "clear",
    "redirect_uri" => "https://somewhere.else",
    "results_uri"  => "https://onfido.com/dashboard/information_requests/<REQUEST_ID>",
    "download_uri" => "https://onfido.com/dashboard/pdf/information_requests/<REQUEST_ID>",
    "reports"      => ["<REPORT_ID>", "<REPORT_ID>"],
    "tags"         => ["My tag", "Another tag"]};

# Start the Mojolicious command system
app->start;

sub END {
    for my $f (values %files) {
        print "removing $f\n";
        $f->remove;
    }
}
