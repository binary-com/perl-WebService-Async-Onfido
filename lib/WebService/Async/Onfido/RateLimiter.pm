package WebService::Async::Onfido::RateLimiter;

use strict;
use warnings;

use Scalar::Util qw(refaddr weaken);
use List::Util qw(first);
use Algorithm::Backoff;

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
    for my $k (qw(limit interval backoff_min backoff_max)){
        die "Invalid value for $k: $self->{$k}" unless int($self->{$k}) > 0;
    }

    $self->{_start_time}          = time();
    # fill the dummy items to normalize the process of queue
    $self->{queue} = [];
    $self->{history} = [];

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
    warn "is_limited queue length: " . scalar($self->{queue}->@*);
    warn "is_limited delay: " . $self->_calc_delay;
    return 1 if scalar($self->{queue}->@*);
    return $self->_calc_delay > 0 ? 1 : 0;
}

sub _calc_delay{
    my $self = shift;
    my $history = $self->{history};
    use Data::Dumper;
    #    warn Dumper($history);
    my $delay = 0;
    if (@$history >= $self->{limit}) {
        $delay = $history->[-$self->{limit}] + $self->{interval} - time();
    }
    return $delay;
}

sub set_timer {
    my $self = shift;
    my $reset_backoff = shift;
    if($reset_backoff){
        $self->backoff->reset_value;
    }
    warn "here reset_backoff $reset_backoff";
    #we still need to fetch next_value even if we needn't use backoff
    # because the backoff 'next_value' is started from 0,
    my $backoff = $self->backoff->next_value;
    warn "here backoff $backoff....";
    if($backoff){
        warn "here in $backoff";
        warn "here timer " . $self->{_timer};
        warn "here timer state " . $self->{_timer}->state;
        if($self->{_timer} && !$self->{_timer}->is_ready){
            warn "here parepare cancel";
            $self->{_timer}->cancel;
            warn "error $@" if $@;
            warn "here cancel timer";
        }
    }
    warn "here backoff $backoff";
    return if($self->{_timer} && !$self->{_timer}->is_ready);
    my $delay = $backoff || $self->_calc_delay;
    warn "delay $delay";
    my $queue = $self->{queue};
    warn "queueref in set_timer $queue";
    my $interval = $self->{interval};
    #warn "queue @$queue";
    my $history = $self->{history};
    $self->{_timer} = $self->loop->delay_future(after => $delay)->on_done(sub{
                                                                         my $slot;
                                                                         #warn "queue @$queue";
                                                                         my $count = 0;
                                                                         warn "queueref in timer $queue";
                                                                         warn "before while " . scalar(@$queue);
                                                                         while($slot = shift @$queue){
                                                                             #filter cancelled slot
                                                                             last unless $slot->[0]->is_ready;
                                                                         }
                                                                         warn "after while " . scalar(@$queue);
                                                                         #warn "slot $slot";
                                                                         #TODO if no slot, should push into history ?
                                                                         my $now = time;
                                                                         warn "processing $slot";
                                                                         $slot->[0]->done($now) if $slot && !$slot->[0]->is_ready;
                                                                         @$history = grep {$now - $interval < $_ } @$history;
                                                                         push @$history, $now;
                                                                         $self->set_timer(1) if @$queue;
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
    my ($self, %args)         = @_;
    #warn "here";
    my $priority     = $args{priority} // 0;
    my $reset_backoff = $args{reset_backoff} // 1;
    die "Invalid value for priority: $priority" unless int($priority) eq $priority;
    my $queue        = $self->{queue};
    warn "queueref in acquire $queue";
    my $slot = [$self->loop->new_future->new, $priority];
    warn "here";
    @$queue = sort {$b->[1] <=> $a->[1]} ($queue->@*, $slot);
    warn "here";
    $self->set_timer($reset_backoff);
    warn "slot in acquire $slot";
    warn "queue @$queue";
    warn "queue length " . scalar(@$queue);
    return $slot->[0];
#    if($reset_backoff){
#        $self->backoff->reset_value;
#    }
#
#    #we still need to fetch next_value even if we needn't use backoff
#    # because the backoff 'next_value' is started from 0,
#    my $backoff = $self->backoff->next_value;
#
#    my $loop     = $self->loop;
#    my $new_slot = [$loop->new_future->new, $loop->new_future, $priority];
#    weaken(my $f = $new_slot->[0]);
#    weaken(my $weak_self = $self);
#    # if f1 is cancelled, then we must remove it from the queue
#    $f->on_cancel(sub{
#                      my $slot = first {$_->[0] eq $f} $self->{queue}->@*;
#                      $slot->[1]->cancel unless $slot->[1]->is_ready;
#                      $self->{queue}->@* = (grep {$_->[0] ne $f} $self->{queue}->@*);
#                      $self->_rebuild_queue();
#                  });
#    my $limit    = $self->limit;
#
#    # GUARD
#    die "something is wrong, the queue's length shouldn't less than the limit" if scalar @$queue < $limit;
#
#    # find the place that insert new slot (or append)
#    my $new_position       = 0;
#    my $not_ready_position = 0;
#    for my $index (0 .. $#$queue) {
#        $not_ready_position++ if $queue->[$index][0]->is_ready;
#        #backoff the finished slots
#        if ($backoff && $queue->[$index][0]->is_ready) {
#            $queue->[$index][0] = Future->done(time() + $backoff - $self->interval);
#        }
#        next if (($queue->[$index][0]->is_ready || $queue->[$index][2] >= $priority));
#        $new_position = $index;
#        last;
#    }
#    # if no place find, then append
#    $new_position ||= $#$queue + 1;
#
#    @$queue = (@$queue[0 .. $new_position - 1], $new_slot, @$queue[$new_position .. $#$queue]);
#    #if there is backoff, we must rebuild from first slot that are not ready
#    $self->_rebuild_queue($backoff ? $not_ready_position : $new_position);
#    return $queue->[$new_position][0];
}

#sub _rebuild_queue {
#    my ($self, $start) = @_;
#    $start //= 0;
#    weaken(my $queue    = $self->{queue});
#    my $interval = $self->interval;
#    my $loop     = $self->loop;
#
#    my @queue_status = (map { $_->[0]->is_done ? ($_->[0]->get - $self->{_start_time}) : 'u' } @$queue);
#    warn "rebuild from $start to $#$queue\n" if $ENV{RATELIMITER_DEBUG};
#    warn "before rebuild: @queue_status\n"   if $ENV{RATELIMITER_DEBUG};
#
#    for my $index ($start .. $#$queue) {
#        next if $queue->[$index][0]->is_done;
#        weaken(my $prev_slot = $queue->[$index - $self->limit]);
#        weaken(my $slot      = $queue->[$index]);
#        my $limit     = $self->limit;
#        $queue_status[$index] = "slot" . ($index - $self->limit) . "+$interval";
#        # the current request's available time is the execution timestamp of the last $limit request push the interval
#        $slot->[1]->cancel if $slot->[1];
#        $slot->[1] = $prev_slot->[0]->without_cancel->then(
#            sub {
#                my $prev_slot_time = shift;
#
#                # execute after
#                my $after = $prev_slot_time + $interval - time();
#                $queue_status[$index] = time - $self->{_start_time} + $after;
#                $loop->delay_future(after => $after)->on_done(
#                    sub {
#                        # remove old slots before current slot
#                        # and keep enough dummy items
#                        for (0 .. $#$queue - $limit) {
#                            last unless $queue->[0][0]->is_ready;
#                            # if the slot too old
#                            if (time() - $queue->[0][0]->get > $interval) {
#                                shift @$queue;
#                            } else {
#                                last;
#                            }
#                        }
#                        $slot->[0]->done(time());
#                    });
#            });
#    }
#    warn "after rebuild: @queue_status" if $ENV{RATELIMITER_DEBUG};
#}

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

