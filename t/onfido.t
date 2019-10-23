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
                                                      )
          );
$onfido->{base_uri} = 'http://localhost:3000';

#applicant create
my $app;
lives_ok {$app = $onfido->applicant_create(
                                    title      => 'Mr',
                                    first_name => 'John',
                                    last_name  => 'Smith',
                                    email      => 'john@example.com',
                                    gender     => 'male',
                                    dob        => '1980-01-22',
                                    country    => 'GBR',
                                    addresses => [ {
                                                    building_number => '100',
                                                    street          => 'Main Street',
                                                    town            => 'London',
                                                    postcode        => 'SW4 6EH',
                                                    country         => 'GBR',
                                                   } ],
                                   )->get; } 'create applicant ok';
like($app->as_string, qr/^John Smith/, 'application string is correct');
isa_ok($app, 'WebService::Async::Onfido::Applicant', 'object type is ok');

#applicant_update
lives_ok {$onfido->applicant_update(first_name => 'Jack', applicant_id => $app->id)->get; } "update applicant ok ";
$app = $onfido->applicant_get(applicant_id => $app->id)->get;
like($app->as_string, qr/^Jack Smith/, 'application string is correct');

#applicant_list
my $src;
lives_ok {$src = $onfido->applicant_list; } "get applicant list ok ";
isa_ok($src, 'Ryu::Source', 'the applicant list is a Ryu::Source');
is($src->as_arrayref->get->[0]->id, $app->id, 'the most recent applicants is the one we created just now');

#document upload
my $tmpfile = Path::Tiny->tempfile;
$tmpfile->spew('x' x 5);
$tmpfile = "$tmpfile.png";
my $document;
lives_ok {$document = $onfido->document_upload(applicant_id => $app->id, filename => $tmpfile, type => 'passport',
                                  issuing_country => 'China')->get } "upload document ok";
isa_ok($document, 'WebService::Async::Onfido::Document', "document type is ok");
is($document->type, 'passport', 'data is correct');




lives_ok {$onfido->applicant_delete(applicant_id => $app->id)->get} "delete ok";

done_testing();
