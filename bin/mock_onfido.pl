# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Clone 'clone';
use Date::Utility;
use Data::UUID;
use File::Basename;
use Path::Tiny;

# In this script we think the key like '_xxxxx' in hash as private keys. Will not send them
plugin 'RenderFile';

# Route with placeholder
my $applicant_template;
my $check_template;

# $applicants{$app_id}
my %applicants;
my %deleted_applicants;

# $documents{$doc_id}
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
    my $id        = Data::UUID->new->create_str();
    my $applicant = {
        id         => $id,
        created_at => Date::Utility->new()->datetime_iso8601,
        href       => "v2/applicants/$id",
    };
    for my $k (keys %$data) {
        $applicant->{$k} = $data->{$k};
    }
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
        $deleted_applicants{$id}->{delete_at} =
            Date::Utility->new()->datetime_iso8601;
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
    my $file         = $c->param('file');
    my $document     = {
        id            => $document_id,
        created_at    => Date::Utility->new()->datetime_iso8601,
        href          => "/v2/applicants/$applicant_id/documents/$document_id",
        download_href => "/v2/applicants/$applicant_id/documents/$document_id/download",
        _applicant_id => $applicant_id,
        file_name     => basename($file->filename),
        file_size     => $file->size,
        file_type     => $file->headers->content_type,
    };
    for my $param (qw(type side issuing_country)) {
        $document->{$param} = $c->param($param);
    }
    $files{$document_id} = Path::Tiny->tempfile;
    $file->move_to($files{$document_id}->stringify);
    $documents{$document_id} = $document;
    return $c->render(json => clone_and_remove_private($document));
};

get '/v2/applicants/:applicant_id/documents' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my @documents =
        sort { $b->{created_at} cmp $a->{created_at} }
        map  { clone_and_remove_private($_) }
        grep { $_->{_applicant_id} eq $applicant_id } values %documents;
    return $c->render(json => {documents => \@documents});
};

get '/v2/applicants/:applicant_id/documents/:document_id' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $document_id  = $c->stash('document_id');
    unless (exists($documents{$document_id})
        && $documents{$document_id}{_applicant_id} eq $applicant_id)
    {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render(json => clone_and_remove_private($documents{$document_id}));
};

get '/v2/applicants/:applicant_id/documents/:document_id/download' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my $document_id  = $c->stash('document_id');
    unless (exists($documents{$document_id})
        && $documents{$document_id}{_applicant_id} eq $applicant_id)
    {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render_file(
        'filepath'     => $files{$document_id}->stringify,
        'filename'     => $documents{$document_id}{file_name},
        'content_type' => $documents{$document_id}{file_type},
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
        map  { clone_and_remove_private($_) }
        grep { $_->{_applicant_id} eq $applicant_id } values %photos;
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
    my ($c, $check_id, $applicant_id) = @_;
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
    my @document_ids =
        map  { $_->{id} }
        grep { $_->{_applicant_id} eq $applicant_id } values %documents;
    for my $req (@req_reports) {
        my $report_id = Data::UUID->new->create_str();
        my $report    = {
            id         => $report_id,
            _check_id  => $check_id,
            created_at => Date::Utility->new()->datetime_iso8601,
            name       => $req->{name},
            status     => 'complete',
            result     => 'clear',
            breakdown  => {},
            properties => {document_type => 'passport'},
            $req->{name} eq 'document'
            ? (documents => [map { {id => $_} } @document_ids])
            : (),
        };
        $reports{$report_id} = $report;
        push @reports, $report_id;
    }
    return [map { clone_and_remove_private($_) } @reports];
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
        status        => 'in_progress',
        result        => 'clear',
        redirect_uri  => 'https://somewhere.else',
        results_uri   => "https://onfido.com/dashboard/information_requests/<REQUEST_ID>",
        download_uri  => "https://onfido.com/dashboard/pdf/information_requests/<REQUEST_ID>",
        reports       => create_report($c, $check_id, $applicant_id),
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

    unless (exists($checks{$check_id})
        && $checks{$check_id}{_applicant_id} eq $applicant_id)
    {
        return $c->render(json => {status => 'Not Found'});
    }
    $checks{$check_id}{status} = 'complete';
    return $c->render(json => clone_and_remove_private($checks{$check_id}));
};

get '/v2/applicants/:applicant_id/checks' => sub {
    my $c            = shift;
    my $applicant_id = $c->stash('applicant_id');
    my @checks =
        sort { $b->{created_at} cmp $a->{created_at} }
        map  { clone_and_remove_private($_) }
        grep { $_->{_applicant_id} eq $applicant_id } values %checks;
    return $c->render(json => {checks => \@checks});
};

get '/v2/checks/:check_id/reports' => sub {
    my $c        = shift;
    my $check_id = $c->stash('check_id');
    my @reports =
        sort { $b->{created_at} cmp $a->{created_at} }
        map  { clone_and_remove_private($_) }
        grep { $_->{_check_id} eq $check_id } values %reports;

    return $c->render(json => {reports => \@reports});
};

get '/v2/checks/:check_id/reports/:report_id' => sub {
    my $c         = shift;
    my $check_id  = $c->stash('check_id');
    my $report_id = $c->stash('report_id');
    unless (exists($reports{$report_id})
        && $reports{$report_id}{_check_id} eq $check_id)
    {
        return $c->render(json => {status => 'Not Found'});
    }
    return $c->render(json => clone_and_remove_private($reports{$report_id}));
};

my @sdk_tokens;
post '/v2/sdk_token' => sub {
    my $c            = shift;
    my $data         = $c->req->json;
    my $applicant_id = $data->{applicant_id};
    my $referrer     = $data->{referrer};
    unless (exists($applicants{$applicant_id}) && $referrer) {
        return $c->render(json => {status => 'Not Found'});
    }
    my $sdk_token = {
        token        => Data::UUID->new->create_str(),
        applicant_id => $applicant_id,
        referrer     => $referrer,
    };
    push @sdk_tokens, $sdk_token;
    return $c->render(json => $sdk_token);
};

my %counter;
post '/test_rate_limit' => sub {
    my $c    = shift;
    my $data = $c->req->json;

    my $id        = $data->{id};
    my $try_times = $data->{try_times};
    $counter{$id}++;
    return $c->render(json => {status => 'ok'}) if $counter{$id} >= $try_times;
    return $c->render(
        status => 429,
        json   => {
            error => {
                type    => 'rate_limit',
                message => 'Rate limit exceeded. Please try again later.',
            }});
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

# Start the Mojolicious command system
app->start;

sub END {
    for my $f (values %files) {
        print "removing $f\n";
        $f->remove;
    }
}
