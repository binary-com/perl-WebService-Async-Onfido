package WebService::Async::Onfido::RateLimiter;

use strict;
use warnings;

use Scalar::Util qw(refaddr);
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

my $start_time = time();

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
        die "Invalid value for $k: $args->{$k}" unless int($args->{$k}) > 0;
        $self->{$k} = delete $args->{$k};
    }

    $self->{backoff_min} = delete $args->{backoff_min} // 30;
    $self->{backoff_max} = delete $args->{backoff_max} // 300;

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
    $self->{backoff} //= Algorithm::Backoff->new(min => $self->{backoff_min}, max => $self->{backoff_max});
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
    my $self = shift;
    my $priority = shift // 0;
    my $need_backoff = shift;
    my $queue = $self->{queue};


    my $backoff = 0;
    if($need_backoff){
        if ($self->backoff->limit_reached){
            # cancel all delay futures;
            for my $slot (@$queue){
                $slot->[1]->cancel if $slot->[1] && !$slot->[1]->is_ready
            }
            return Future->fail('backoff reached the limit!');
        }
        $backoff = $self->backoff->next_value;
    }
    else{
        $self->backoff->reset_value;
    }

    my $loop     = $self->loop;
    my $new_slot = [Future->new, Future->new , $priority];
    $new_slot->[0]->on_cancel(sub{print $new_slot->[0] . "canceled........\n"});
    my $limit = $self->limit;

    # GUARD
    die "something is wrong, the queue's length shouldn't less than the limit" if scalar @$queue < $limit;

    my $new_position = 0;
    my $not_ready_position = 0;
    for my $index (0..$#$queue){
        $not_ready_position++ if $queue->[$index][0]->is_ready;
        if($backoff && $queue->[$index][0]->is_ready){
            $queue->[$index][0] = Future->done(time() + $backoff - $self->interval);
        }
        next if (($queue->[$index][0]->is_ready || $queue->[$index][2] >= $priority));
        $new_position = $index;
        last;
    }
    $new_position ||= $#$queue + 1;

    @$queue = (@$queue[0..$new_position-1], $new_slot, @$queue[$new_position..$#$queue]);
    $self->_rebuild_queue($backoff ? $not_ready_position : $new_position);
    return $queue->[$new_position][0];
}

sub _rebuild_queue {
    my ($self, $start) = @_;
    # GUARD, shouldn't happen
    die "start should always no less than the limit" if $start < $self->limit;
    my $queue = $self->{queue};
    my $interval = $self->interval;
    my $loop = $self->loop;

    #my @tmp = (map {$_->[0]->is_done ? ($_->[0]->get - $start_time) : 'u'} @$queue);
    #warn "rebuild from $start to $#$queue\n";
    #warn "before rebuild: @tmp\n";

    for my $index ($start .. $#$queue){
        my $prev_slot     = $queue->[$index-$self->limit];
        my $slot = $queue->[$index];
        my $limit = $self->limit;
        #$tmp[$index] = "slot" . ($index-$self->limit) . "+$interval";
        # the current request's available time is the execution timestamp of the last $limit request push the interval
        $slot->[1]->cancel if $slot->[1];
        $slot->[1] = $prev_slot->[0]->without_cancel->then(
            sub {
                my $prev_slot_time = shift;

                # execute after
                my $after = $prev_slot_time + $interval - time();
                #$tmp[$index] = time - $start_time + $after;
                $loop->delay_future(after => $after)->on_done(
                    sub {
                        # remove old slots before current slot
                        # and keep enough dummy items
                        for (0 .. $#$queue - $limit) {
                        #for (0 .. $#$queue) {
                            last unless $queue->[0][0]->is_ready;
                            # if the slot too old
                            if (time() - $queue->[0][0]->get > $interval) {
                                shift @$queue;
                            } else {
                                last;
                            }
                        }
                        #warn "future " . $slot->[0] . " is done\n";
                        $slot->[0]->done(time());
                    });
            });
    }
    #warn "after rebuild: @tmp";
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

