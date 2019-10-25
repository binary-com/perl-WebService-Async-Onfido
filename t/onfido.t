use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Tiny;

use IO::Async::Loop;

use WebService::Async::Onfido;
use URI;
#TODO https://metacpan.org/pod/IO::Async::Test
my $loop = IO::Async::Loop->new;
$loop->add(
    my $onfido = WebService::Async::Onfido->new(
        token => 'test_token',
#                                                       base_uri => 'http://localhost:3000'
    ));
$onfido->{base_uri} = 'http://localhost:3000';

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
is($src->as_arrayref->get->[0]->id, $app->id, 'the most recent applicants is the one we created just now');

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
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is($src->as_arrayref->get->[0]->id, $doc->id, 'the most recent doc is the one we created just now');

# get document
my $doc2;
lives_ok { $doc2 = $onfido->get_document_details(applicant_id => $app->id, document_id => $doc->id)->get } 'get doc ok';
is($doc2->id, $doc->id, 'id is right');

# download_document
my $content2;
lives_ok { $content2 = $onfido->download_document(applicant_id => $app->id, document_id => $doc->id)->get }, 'download doc ok';

is($content2, $content, "the content is right");

# photo upload
my $photo;
lives_ok { $photo = $onfido->live_photo_upload(applicant_id => $app->id, filename => 'photo1.jpg', data => 'photo ' x 50)->get }, 'upload photo ok';
isa_ok($photo, 'WebService::Async::Onfido::Photo', 'result type is ok');
is($photo->file_name, 'photo1.jpg', 'result is ok');

# photo list
lives_ok { $src = $onfido->photo_list(applicant_id => $app->id) } "photo list ok";
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is($src->as_arrayref->get->[0]->id, $photo->id, 'the most recent photo is the one we created just now');

# get document
my $photo2;
lives_ok { $photo2 = $onfido->get_photo_details(live_photo_id => $photo->id)->get } 'get photo ok';
is($photo2->id, $photo->id, 'id is right');

# download_photo
lives_ok { $content = $onfido->download_photo(live_photo_id => $photo->id)->get }, 'download doc ok';

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
is_deeply($check2, $check, 'result is ok');

# applicant delete
lives_ok { $onfido->applicant_delete(applicant_id => $app->id)->get } "delete ok";

done_testing();
