package WebService::Async::Onfido::RateLimiter;

use strict;
use warnings;

use Scalar::Util qw(refaddr weaken);
use List::Util qw(first);
use Algorithm::Backoff;
use feature qw(state);
use Data::Dumper;
our $VERSION = '0.001';

=head1 NAME

WebService::Async::Onfido::RateLimiter - Module abstract

=head1 SYNOPSIS

    use WebService::Async::Onfido::RateLimiter;
    my $instance = WebService::Async::Onfido::RateLimiter->new;

=head1 DESCRIPTION

=cut

=head1 METHODS

=cut

use Future;
use mro;

use parent qw(IO::Async::Notifier);

=head1 NAME

WebService::Async::CustomerIO::RateLimitter - This class provide possibility to limit amount
of request in time interval

=head1 SYNOPSIS

   use IO::Async::Loop;
   use WebService::Async::Onfido::RateLimiter;
   my $loop = IO::Async::Loop->new;
   $loop->add(
       my $limiter = WebService::Async::Onfido::RateLimiter->new(
           interval => 5,
           limit    => 3
       ));
   my $f = $limiter->acquire->then(sub{print "doing "});
   $loop->run;

=head1 DESCRIPTION

=cut

sub _init {
    my ($self, $args) = @_;
    for my $k (qw(limit interval)) {
        die "Missing required argument: $k" unless exists $args->{$k};
        $self->{$k} = delete $args->{$k};
    }

    $self->{backoff_min} = delete $args->{backoff_min} // 30;
    $self->{backoff_max} = delete $args->{backoff_max} // 3600;
    for my $k (qw(limit interval backoff_min backoff_max)) {
        die "Invalid value for $k: $self->{$k}" unless int($self->{$k}) > 0;
    }

    $self->{_start_time} = time();
    # fill the dummy items to normalize the process of queue
    $self->{queue}              = [];
    $self->{history}            = [];
    $self->{last_reset_backoff} = 1;
    return $self->next::method($args);
}

=head2 interval

=cut

sub interval { return shift->{interval} }

=head2 limit

=cut

sub limit { return shift->{limit} }

=head2 is_limited

=cut

sub backoff {
    my $self = shift;
    $self->{backoff} //= Algorithm::Backoff->new(
        min => $self->{backoff_min},
        max => $self->{backoff_max});
}

sub is_limited {
    my $self = shift;
    return 1 if scalar($self->{queue}->@*);
    return $self->_calc_delay > 0 ? 1 : 0;
}

sub _calc_delay {
    my $self    = shift;
    my $history = $self->{history};
    my $delay   = 0;
    if (@$history >= $self->{limit}) {
        $delay = $history->[-$self->{limit}] + $self->{interval} - time();
    }
    return $delay;
}

sub set_timer {
    my $self          = shift;
    my $reset_backoff = shift;

    $self->backoff->reset_value if $reset_backoff;
    my $backoff_changed = ($reset_backoff xor $self->{last_reset_backoff});
    $self->{last_reset_backoff} = $reset_backoff;

    #we still need to fetch next_value even if we needn't use backoff
    # be++cause the backoff 'next_value' is started from 0,
    if ($backoff_changed) {
        if ($self->{_timer} && !$self->{_timer}->is_ready) {
            $self->{_timer}->cancel;
        }
    }
    return if ($self->{_timer} && !$self->{_timer}->is_ready);
    my $backoff = $self->backoff->next_value;
    my $delay    = $backoff || $self->_calc_delay;
    my $queue    = $self->{queue};
    my $interval = $self->{interval};
    my $history  = $self->{history};
    $self->{_timer} = $self->loop->delay_future(after => $delay)->on_done(
        sub {
            my $slot;
            my $count = 0;
            while ($slot = shift @$queue) {
                #filter cancelled slot
                last unless $slot->[0]->is_ready;
            }
            my $now = time;
            if ($slot && !$slot->[0]->is_ready) {
                $slot->[0]->done($now);
                @$history = grep { $now - $interval < $_ } @$history;
                push @$history, $now;
            }
            $self->set_timer($self->{last_reset_backoff}) if @$queue;
        });
}

=head2 acquire

Method checks availability for free slot.
It returns future, when slot will be available, then future will be resolved.

=head3 args

=item priority

Requests with igh priority will be moved to the head of queue

=item reset_backoff

If the previous request ok, then we should reset backoff value

=cut

# A queue is maintained in the array. The slot (item in the queue) is the format:
# [Future f1, Future f2]
# f1 represent that the request is ready. f2 is a $loop->future->delay.
# slot[n]'s f2 will observer slot[n-limit]'s f1. When slot[n-limit] is done, then slot[n][f2] will start a timer with delay 'interval'.  When time is reached, slot[n][f2] will mark slot[n][f1] as done.

sub acquire {
    my ($self, %args) = @_;
    my $priority      = $args{priority}      // 0;
    my $reset_backoff = $args{reset_backoff} // 1;
    die "Invalid value for priority: $priority" unless int($priority) eq $priority;
    my $queue = $self->{queue};
    my $slot = [$self->loop->new_future->new, $priority];
    @$queue = sort { $b->[1] <=> $a->[1] } ($queue->@*, $slot);
    $self->set_timer($reset_backoff);
    return $slot->[0];
}

1;

=head1 AUTHOR

Binary.com

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Binary.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 SEE ALSO

=over 4

=item *

=back

