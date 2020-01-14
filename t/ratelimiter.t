use strict;
use warnings;
use Test::More;

use Test::Exception;
use IO::Async::Loop;
use WebService::Async::Onfido::RateLimiter;
my $loop = IO::Async::Loop->new;
my @limiter;
throws_ok {
    WebService::Async::Onfido::RateLimiter->new(
        interval => 5,
        )
}
qr/Missing required argument/, 'check arg ok';

$loop->add(
    $limiter[0] = WebService::Async::Onfido::RateLimiter->new(
        interval => 5,
        limit    => 3,
    ));

$loop->add(
    $limiter[1] = WebService::Async::Onfido::RateLimiter->new(
        interval    => 1,
        limit       => 2,
        backoff_min => 2,
        backoff_max => 5,

    ));

# [time to send request, priority, backoff]
my @request_queue = ([
        [0, 0, 0], [1, 0, 0], [2, 0, 0], [3, 0, 0], [4, 0, 0], [4, 1, 0], [5, 0, 0], [6, 0, 0],
        [8, 0, 0], [8, 0, 0], [17, 0, 0], [17, 0, 0], [17, 0], [25, 0, 0]
    ],
    [
        [0, 0, 0], [1, 0, 1], [2, 0, 0], [4, 0, 1], [5, 0, 1], [6, 0, 0], [11, 0, 1], [12, 0, 1], [13, 0, 0],
        [14, 0, 1], [15, 0, 1], [16, 0, 1],
        [17, 0, 1]
        #, [3,0,1], [4,0,1], [5,0,1], [6,0,1], [7,0,1], [8,0,1], [9,0,1]
    ],
);
my @request_futures;
my $now = time();
for my $t (0 .. 100) {
    my $f = $loop->delay_future(after => $t)->on_ready(sub { diag("time $t -----------------------------") });
}
for my $index (0 .. $#request_queue) {
    for my $request_info ($request_queue[$index]->@*) {
        my $f = $loop->delay_future(after => $request_info->[0]);
        $f = $f->then(
            sub {
                submit_request($index, $request_info);
                return Future->done;
            });
        push $request_futures[$index]->@*, $f;
    }
}

my @requests;
my @value_of_is_limited;

sub submit_request {
    my ($index, $arg) = @_;
    diag("queue $index requesting $arg->[0]...");
    push $value_of_is_limited[$index]->@*, $limiter[$index]->is_limited;
    my $f = $limiter[$index]->acquire(
        priority      => $arg->[1],
        reset_backoff => !$arg->[2]
        )->then(
        sub {
            my $execute_time = shift;
            my $done_time    = $execute_time - $now;
            diag("queue $index request " . $arg->[0] . " is done at $done_time");
            Future->done([$arg->[0], $execute_time - $now]);
        }
        )->else(
        sub {
            Future->done([$arg->[0], 'f']);
        });
    if ($arg->[0] == 14) {
        $f->cancel;
    }
    push $requests[$index]->@*, $f;
    return $f;
}

my $timeout_f = $loop->delay_future(after => 40)->on_done(
    sub {
        fail('timeout');
        $loop->stop;
    });
my $wait_all_f = Future->wait_all($request_futures[0][-1], $request_futures[1][01])->then(
    sub {
        Future->wait_all($requests[0][-1], $requests[1][-1])->on_ready(
            sub {
                warn "stopping";
                $timeout_f->cancel;
                $loop->stop;
            });
    });

$loop->run();
my @executing_time;
$executing_time[0] = [map { $_->get } $requests[0]->@*];
$executing_time[1] = [map { $_->is_done ? $_->get : $_->state } $requests[1]->@*];
is_deeply(
    $executing_time[0],
    [[0, 0], [1, 1], [2, 2], [3, 6], [4, 7], [4, 5], [5, 10], [6, 11], [8, 12], [8, 15], [17, 17], [17, 17], [17, 20], [25, 25]],
    'the executing time is ok'
);
is_deeply($value_of_is_limited[0], [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0], 'the status of is_limited is ok');
is(scalar $limiter[0]->{queue}->@*,   0, 'the queue will be shrink');
is(scalar $limiter[0]->{history}->@*, 1, 'the queue will be shrink');
diag(explain($executing_time[1]));
is_deeply(
    $executing_time[1],
    #[[0, 0], [1, 3], [2, 3], [4, 9], [5, 9], [6, 10], [11, 22], [12, 22], [13, 23], 'cancelled', [15, 23], [16, 24], [17, 24]],
    [[0, 0], [1, 2], [2, 2], [4, 6], [5, 6], [6, 7], [11, 13], [12, 13], [13, 16], 'cancelled', [15, 20], [16, 25], [17, 30]],
    'the executing time of backoff is ok'
);

for my $i (0 .. $#request_futures) {
    for my $j (0 .. $request_futures[$i]->$#*) {
        is($request_futures[$i][$j]->state, 'done', "request future $i $j has no error");
    }
}
done_testing;
