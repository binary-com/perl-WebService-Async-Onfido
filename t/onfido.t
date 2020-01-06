use strict;
use warnings;
use Test::MockTime::HiRes qw(set_relative_time);
use Test::More tests => 100;
use Test::Exception;
#use Test::NoWarnings;
use Path::Tiny;
use JSON::MaybeUTF8 qw(:v1);
use IO::Async::Loop;

use WebService::Async::Onfido;
use URI;
use FindBin qw($Bin);

my $pid = fork();
die "fork error " unless defined($pid);
unless ($pid) {
    my $mock_server = "$Bin/../bin/mock_onfido.pl";
    #open(STDOUT, '>/dev/null');
    #open(STDERR, '>/dev/null');
    exec('perl', $mock_server, 'daemon');
}

sleep 2;
my $loop = IO::Async::Loop->new;
$loop->add(
    my $onfido = WebService::Async::Onfido->new(
        token    => 'test_token',
        base_uri => 'http://localhost:3000',
    ));

#applicant create
my $app;
lives_ok {
    $app = $onfido->applicant_create(
        title      => 'Mr',
        first_name => 'John',
        last_name  => 'Smith',
        email      => 'john@example.com',
        gender     => 'male',
        dob        => '1980-01-22',
        country    => 'GBR',
        addresses  => [{
                building_number => '100',
                street          => 'Main Street',
                town            => 'London',
                postcode        => 'SW4 6EH',
                country         => 'GBR',
            }
        ],
    )->get;
}
'create applicant ok';
like($app->as_string, qr/^John Smith/, 'application string is correct');
isa_ok($app, 'WebService::Async::Onfido::Applicant', 'object type is ok');

#applicant_update
lives_ok { $onfido->applicant_update(first_name => 'Jack', applicant_id => $app->id)->get; } "update applicant ok ";
$app = $onfido->applicant_get(applicant_id => $app->id)->get;
like($app->as_string, qr/^Jack Smith/, 'application string is correct');

#applicant_list
my $src;
lives_ok { $src = $onfido->applicant_list; } "get applicant list ok ";
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is_deeply($src->as_arrayref->get->[0], $app, 'the most recent applicants is the one we created just now');

# get applicant
my $app2;
lives_ok { $app2 = $onfido->applicant_get(applicant_id => $app->id)->get; } "get applicant ok ";
isa_ok($app2, 'WebService::Async::Onfido::Applicant', 'the applicant type is ok');
is_deeply($app2, $app, 'get applicant result ok');

#document upload
my $doc;
my $content = 'x' x 500;
lives_ok {
    $doc = $onfido->document_upload(
        applicant_id    => $app->id,
        filename        => "document1.png",
        type            => 'passport',
        issuing_country => 'China',
        data            => $content,
        )->get
}
"upload document ok";
isa_ok($doc, 'WebService::Async::Onfido::Document', "document type is ok");
is($doc->type, 'passport', 'data is correct');

# document list
lives_ok { $src = $onfido->document_list(applicant_id => $app->id) } "document list ok";
isa_ok($src, 'Ryu::Source', 'the document list is a Ryu::Source');
is_deeply($src->as_arrayref->get->[0], $doc, 'the most recent doc is the one we created just now');

# get document
my $doc2;
lives_ok { $doc2 = $onfido->get_document_details(applicant_id => $app->id, document_id => $doc->id)->get } 'get doc ok';
is_deeply($doc2, $doc, 'get doc result is right');

# download_document
my $content2;
lives_ok { $content2 = $onfido->download_document(applicant_id => $app->id, document_id => $doc->id)->get } 'download doc ok';

is($content2, $content, "the content is right");

# photo upload
my $photo;
lives_ok { $photo = $onfido->live_photo_upload(applicant_id => $app->id, filename => 'photo1.jpg', data => 'photo ' x 50)->get } 'upload photo ok';
isa_ok($photo, 'WebService::Async::Onfido::Photo', 'result type is ok');
is($photo->file_name, 'photo1.jpg', 'result is ok');

# photo list
lives_ok { $src = $onfido->photo_list(applicant_id => $app->id) } "photo list ok";
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is_deeply($src->as_arrayref->get->[0], $photo, 'the most recent photo is the one we created just now');

# get document
my $photo2;
lives_ok { $photo2 = $onfido->get_photo_details(live_photo_id => $photo->id)->get } 'get photo ok';
is_deeply($photo2, $photo, 'get result is right');

# download_photo
lives_ok { $content = $onfido->download_photo(live_photo_id => $photo->id)->get } 'download doc ok';

is($content, 'photo ' x 50, "the content is right");

# applicant_check
my $check;
lives_ok {
    $check = $onfido->applicant_check(
        applicant_id => $app->id,
        type         => 'standard',
        reports      => [
            {name => 'document'},
            {
                name    => 'facial_similarity',
                variant => 'standard'
            }
        ],
        tags                       => ['tag1', 'tag2'],
        suppress_from_email        => 0,
        async                      => 1,
        charge_applicant_for_check => 0,
        )->get
}
"create check ok";
isa_ok($check, "WebService::Async::Onfido::Check", "check class is right");
is_deeply($check->tags, ['tag1', 'tag2'], 'result is ok');

# get check
my $check2;
lives_ok {
    $check2 = $onfido->check_get(
        applicant_id => $app->id,
        check_id     => $check->id,
        )->get
}
"get check ok";
isa_ok($check2, "WebService::Async::Onfido::Check", "check class is right");
$check->{status} = 'complete';    # after get check, it will be 'complete';
is_deeply($check2, $check, 'result is ok');

# check list
lives_ok { $src = $onfido->check_list(applicant_id => $app->id) } "check list ok";
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is_deeply($src->as_arrayref->get->[0], $check, 'the most recent check is the one we created just now');

#get report
my ($report, $report2);
lives_ok { $report = $check->reports->as_arrayref->get->[0] } "get report from check ok";
isa_ok($report, 'WebService::Async::Onfido::Report');

lives_ok {
    $report2 = $onfido->report_get(
        check_id  => $check->id,
        report_id => $report->{id},
        )->get
}
"get report ok";

isa_ok($report2, 'WebService::Async::Onfido::Report');
$report2->{check} = $check;    # set check for test.
is_deeply($report2, $report, 'id is correct');

# sdk_token
my $token;
lives_ok { $token = $onfido->sdk_token(applicant_id => $app->id, referrer => 'https://*.example.com/example_page/*')->get };
ok($token->{token}, 'there is a token in the result');
is($token->{referrer}, 'https://*.example.com/example_page/*', 'referrer is ok in the result');

# applicant delete
lives_ok { $onfido->applicant_delete(applicant_id => $app->id)->get } "delete ok";


# replace onfido's default ratelimiter with new ratelimiter with smaller interval
$onfido->{rate_limiter} = do{
    my $limiter = WebService::Async::Onfido::RateLimiter->new(
        limit    => 2,
        interval => 2,
        backoff_min => 2,
    );
    $onfido->add_child($limiter);
    $limiter;
};
$onfido->endpoints->{test_rate_limit} = $onfido->base_uri . '/test_rate_limit';

sub request_test_rate_limit{
    my ($onfido, %args) = @_;
    my $start_time = time();
    $onfido->_do_request(
        request => sub {
            my $prepare_future = shift;
            $prepare_future->then(
                sub {
                    $onfido->ua->POST(
                        $onfido->endpoint('test_rate_limit'),
                        encode_json_utf8(\%args),
                        content_type => 'application/json',
                        $onfido->auth_headers,
                    );
                }
                )->then(
                    sub {
                            my ($res) = @_;
                            my $data = decode_json_utf8($res->content);
                    Future->done(time - $start_time, $data);
                })
            })->else(
                sub {
                    my $failure = shift;
                    Future->done(time - $start_time, $failure);
                }
            );
}

# try_times means try Nth times the mocked onfido server will return correct value,
# before that it will return 429 status code
my $id = 0;
my @result = request_test_rate_limit($onfido, id => $id++, try_times => 1)->get;
diag(explain(\@result));
is($result[0], 0, '1st time return ok, 0 time backoff, 0 seconds');
@result = request_test_rate_limit($onfido, id => $id++, try_times => 2)->get;
diag(explain(\@result));
is($result[0], 2, '2nd time return ok, 1 time backoff, 2 seconds because it failed 1 time . the backoff is 2');
@result = request_test_rate_limit($onfido, id => $id++, try_times => 3)->get;
diag(explain(\@result));
is($result[0], 2+4, '3rd time return ok, 2 times backoff, 2 + 4 seconds because it failed 2 time . the backoff is 2 + 4');
@result = request_test_rate_limit($onfido, id => $id++, try_times => 4)->get;
diag(explain(\@result));
is($result[0], 2+4+5, '4th time return ok, 3 times backoff, 2 + 4 + 5 seconds because it failed 3 time . the backoff is 2 + 4 + 5 , max value is 5');
is($result[1]->{status}, 'ok','the status is ok' );
@result = request_test_rate_limit($onfido, id => $id++, try_times => 5)->get;
diag(explain(\@result));
is($result[0], 2+4+5, '5th time return ok, 4 times backoff, 0 seconds because it already reached max failure times. the max backoff time is 3 time');
is($result[1], 'backoff reached the limit!', 'request failed of 429');





# ratelimit
# clear rate limiting
diag('-' x 80);
diag('start testing ratelimit\n');

$loop->add(
    $onfido = WebService::Async::Onfido->new(
        token               => 'test_token',
        base_uri            => 'http://localhost:3000',
        requests_per_minute => 5,
    ));


for (1 .. 5) {
    ok(!$onfido->is_rate_limited, "not limited yet");
    my $result = $onfido->rate_limiting;
    $onfido->loop->loop_once(0);
    ok($result->is_ready, 'all results are ready at first because they are in the rate limit');
}
my @results;
for (1 .. 10) {
    ok($onfido->is_rate_limited, "is rate_limited now");
    my $result = $onfido->rate_limiting;
    ok(!$result->is_ready, 'all results are not ready now because they are out of rate limit');
    push @results, $result;
}

# advance 1st interval
set_relative_time(60);
# trigger loop delay_future
$onfido->loop->loop_once(0);
ok($onfido->is_rate_limited, "still rate_limited again");
for (1 .. 5) {
    my $result = shift @results;
    ok($result->is_ready, 'now the first 5 future should be ready because they are in the rate limit now');
}
ok($onfido->is_rate_limited, "here still rate_limited");
for (1 .. 5) {
    my $result = shift @results;
    ok(!$result->is_ready, 'now the last 5 futures should not be ready because they are still out of rate limit');
}

# advance 2nd interval
set_relative_time(60 * 2);
# trigger loop delay_future
$onfido->loop->loop_once(0);
ok($onfido->is_rate_limited, "still rate_limited because new queue has been filled already");
# advance 3rd interval
set_relative_time(60 * 3);
# trigger loop delay_future
$onfido->loop->loop_once(0);
ok(!$onfido->is_rate_limited, "all futures ready, should not limited");
kill('TERM', $pid);
