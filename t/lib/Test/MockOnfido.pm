package Test::MockOnfido;
use Mojolicious::Lite;
use IO::Async::Loop;
use IO::Async::Timer::Absolute;

my $loop = IO::Async::Loop->new;

# Wait 3 seconds before rendering a response
get '/' => sub {
    my $self = shift;
    $loop->add(IO::Async::Timer::Absolute->new(
                                               time      => time + 3,
                                               on_expire => sub { $self->render(text => 'Delayed by 3 seconds!') }
                                              ));
};

use Test::Mojo;
my $t = Test::Mojo->new;
$t->get_ok('/');
done_testing();
