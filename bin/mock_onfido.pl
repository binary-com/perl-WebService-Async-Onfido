# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Clone 'clone';
use Data::Dumper;
use Date::Utility;
use Data::UUID;
use File::Basename;
use Path::Tiny;

# try https://metacpan.org/source/MASAKI/Test-Fake-HTTPD-0.08/t/10_http.t this one
# Route with placeholder
my $applicant_template;
my $check_template;
# $applicants{$app_id}
my %applicants;
my %deleted_applicants;
# $documents{$app_id}{$doc_id}
my %documents;
# $files{$doc_id}
my %files;
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
    warn "all app id" . Dumper([keys %files]);
    unless (exists($documents{$applicant_id})) {
        warn "no found $applicant_id";
        return $c->render(json => {status => 'Not Found'});
    }
    my @documents = values $documents{$applicant_id}->%*;
    @documents = sort { $b->{created_at} cmp $a->{created_at} } @documents;
    warn "documents " . Dumper(\@documents);
    return $c->render(json => {documents => \@documents});
};

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
