use strict;
use warnings;
use Test::More;

use IO::Async::Loop;
use WebService::Async::Onfido::RateLimiter;
my $loop = IO::Async::Loop->new;
$loop->add(
    my $limiter = WebService::Async::Onfido::RateLimiter->new(
        interval => 5,
        limit    => 3,
        backoff_min => 6,
        backoff_max => 30,
    ));

my @feed = ([0,0], [1,0], [2,0], [3,0], [4,0], [4,1], [5,0], [6,0], [8,0], [8,0], [17,0], [17,0], [17,0], [25,0], [25,0], [25,0], [26,0], [27,0], [28,0], [29,0], [30,0]);
my @request_futures;
my $now = time();
for my $request_info (@feed) {
    my $f = $loop->delay_future(after => $request_info->[0]);
    $f = $f->then(
        sub {
            submit_request($request_info);
            return Future->done;
        });
    push @request_futures, $f;
}

my $f = $loop->delay_future(after => 200)->on_ready(
    sub {
        fail('timeout');
        $loop->stop;
    });

my @requests;
my @value_of_is_limited;

sub submit_request {
    my $arg = shift;
    diag("requesting $arg->[0]...");
    push @value_of_is_limited, $limiter->is_limited;
    use Data::Dumper;
    # $arg->[0] >= 27 will ask backoff
    my $f = $limiter->acquire($arg->[1],
                              $arg->[0] >= 28
                          )->then(sub { my $execute_time = shift; my $done_time = $execute_time - $now; diag("request " . Dumper($arg) . " is done at $done_time"); Future->done([$arg->[0], $execute_time - $now]) });
    if ($arg->[0] == 30) {
        $f->on_ready(sub {
                           $loop->stop
                       });
    }
    push @requests, $f;
}

$loop->run();
my $executing_time = [map { $_->get } @requests];
diag(explain($executing_time));
is_deeply(
    $executing_time,
    [
        [0, 0], [1, 1], [2, 2], [3, 6], [4, 7], [4, 5], [5, 10], [6, 11], [8, 12], [8, 15],
        [17, 17], [17, 17], [17, 20], [25, 25], [25, 25], [25, 25], [26, 54],[27,54],[28,54],[29,59],[30,59]
    ],
    'the executing time is ok'
);
is_deeply(\@value_of_is_limited, [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1,1,1,1,1], 'the status of is_limited is ok');
is(scalar $limiter->{queue}->@*, 5, 'the queue will be shrink');
done_testing;
