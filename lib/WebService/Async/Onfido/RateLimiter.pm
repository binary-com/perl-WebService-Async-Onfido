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
    $self->{queue} //= do {
        my $queue = [];
        push @$queue, [Future->done(time - $self->{interval}), Future->done] for (1 .. $self->{limit});
        $queue;
    };

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
    return (
        !($self->{queue}[-$self->limit][0]->is_ready)
            #  or is ready but passed no more than interval seconds
            || (time() - $self->{queue}[-$self->limit][0]->get < $self->interval)) ? 1 : 0;
}

=head2 acquire

Method checks availability for free slot.
It returns future, when slot will be available, then future will be resolved.

=cut

sub acquire {
    my ($self, %args)         = @_;
    my $priority     = $args{priority} // 0;
    my $reset_backoff = $args{reset_backoff} // 1;
    die "Invalid value for priority: $priority" unless int($priority) eq $priority;
    my $queue        = $self->{queue};

    my $restore_backoff_cancelled_slots = 0;
    if($reset_backoff){
        $self->backoff->reset_value;
    }

    #we still need to fetch next_value even if we needn't use backoff
    # because the backoff 'next_value' is started from 0,
    my $backoff = $self->backoff->next_value;

    my $loop     = $self->loop;
    my $new_slot = [$loop->new_future->new, $loop->new_future, $priority];
    weaken(my $f = $new_slot->[0]);
    weaken(my $weak_self = $self);
    $f->on_cancel(sub{
                      my $slot = first {$_->[0] eq $f} $self->{queue}->@*;
                      $slot->[1]->cancel unless $slot->[1]->is_ready;
                      $self->{queue}->@* = (grep {$_->[0] ne $f} $self->{queue}->@*);
                      $self->_rebuild_queue();
                  });
    my $limit    = $self->limit;

    # GUARD
    die "something is wrong, the queue's length shouldn't less than the limit" if scalar @$queue < $limit;

    my $new_position       = 0;
    my $not_ready_position = 0;
    for my $index (0 .. $#$queue) {
        $not_ready_position++ if $queue->[$index][0]->is_ready;
        #backoff the finished slots
        #TODO filter out the cancelled slots[0]
        if ($backoff && $queue->[$index][0]->is_ready) {
            $queue->[$index][0] = Future->done(time() + $backoff - $self->interval);
        }
        next if (($queue->[$index][0]->is_ready || $queue->[$index][2] >= $priority));
        $new_position = $index;
        last;
    }
    $new_position ||= $#$queue + 1;

    @$queue = (@$queue[0 .. $new_position - 1], $new_slot, @$queue[$new_position .. $#$queue]);
    $self->_rebuild_queue(($backoff || $restore_backoff_cancelled_slots) ? $not_ready_position : $new_position);
    return $queue->[$new_position][0];
}

sub _rebuild_queue {
    my ($self, $start) = @_;
    $start //= 0;
    weaken(my $queue    = $self->{queue});
    my $interval = $self->interval;
    my $loop     = $self->loop;

    my @queue_status = (map { $_->[0]->is_done ? ($_->[0]->get - $self->{_start_time}) : 'u' } @$queue);
    warn "rebuild from $start to $#$queue\n" if $ENV{RATELIMITER_DEBUG};
    warn "before rebuild: @queue_status\n"   if $ENV{RATELIMITER_DEBUG};

    for my $index ($start .. $#$queue) {
        next if $queue->[$index][0]->is_done;
        weaken(my $prev_slot = $queue->[$index - $self->limit]);
        weaken(my $slot      = $queue->[$index]);
        my $limit     = $self->limit;
        $queue_status[$index] = "slot" . ($index - $self->limit) . "+$interval";
        # the current request's available time is the execution timestamp of the last $limit request push the interval
        $slot->[1]->cancel if $slot->[1];
        $slot->[1] = $prev_slot->[0]->without_cancel->then(
            sub {
                my $prev_slot_time = shift;

                # execute after
                my $after = $prev_slot_time + $interval - time();
                $queue_status[$index] = time - $self->{_start_time} + $after;
                $loop->delay_future(after => $after)->on_done(
                    sub {
                        # remove old slots before current slot
                        # and keep enough dummy items
                        for (0 .. $#$queue - $limit) {
                            last unless $queue->[0][0]->is_ready;
                            # if the slot too old
                            if (time() - $queue->[0][0]->get > $interval) {
                                shift @$queue;
                            } else {
                                last;
                            }
                        }
                        $slot->[0]->done(time());
                    });
            });
    }
    warn "after rebuild: @queue_status" if $ENV{RATELIMITER_DEBUG};
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

