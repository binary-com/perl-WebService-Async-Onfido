use strict;
use warnings;
use Test::More;

use IO::Async::Loop;
use WebService::Async::Onfido::RateLimiter;
my $loop = IO::Async::Loop->new;
$loop->add(
    my $limiter = WebService::Async::Onfido::RateLimiter->new(
        interval => 5,
        limit    => 3
    ));

my @feed = (0, 1, 2, 3, 4, 4, 5, 6, 8, 8, 17, 17, 17, 25, 25, 25, 26);
my @request_futures;
my $now = time();
for my $request_time (@feed) {
    my $f = $loop->delay_future(after => $request_time);
    $f = $f->then(
        sub {
            submit_request($request_time);
            return Future->done;
        });
    push @request_futures, $f;
}

my $f = $loop->delay_future(after => 50)->on_ready(
    sub {
        fail('timeout');
        $loop->stop;
    });

my @requests;
my @value_of_is_limited;

sub submit_request {
    my $arg = shift;
    diag("requesting $arg...");
    push @value_of_is_limited, $limiter->is_limited;
    my $f = $limiter->acquire->then(sub { my $execute_time = shift; Future->done([$arg, $execute_time - $now]) });
    if ($arg == 26) {
        $f->on_ready(sub { $loop->stop });
    }
    push @requests, $f;
}

$loop->run();
is_deeply(
    [map { $_->get } @requests],
    [
        [0, 0], [1, 1], [2, 2], [3, 5], [4, 6], [4, 7], [5, 10], [6, 11], [8, 12], [8, 15],
        [17, 17], [17, 17], [17, 20], [25, 25], [25, 25], [25, 25], [26, 30]
    ],
    'the executing time is ok'
);
is_deeply(\@value_of_is_limited, [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1], 'the status of is_limited is ok');
done_testing;
