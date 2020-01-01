package WebService::Async::Onfido::RateLimiter;

use strict;
use warnings;

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
        die "Invalid value for $k: $args->{$k}" unless int($args->{$k}) > 0;
        $self->{$k} = delete $args->{$k};
    }

    $self->{queue}   = [];
    $self->{counter} = 0;    ## TODO remove ?

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

sub is_limited {
    my $self = shift;
    # the number of slots is less.
    return scalar($self->{queue}->@*) >= $self->limit
        # the item of [-$limit] is not ready
        && (
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
    my $queue = $self->{queue};

    my $loop     = $self->loop;
    my $slot = [$loop->new_future->new];
    # if the queue is not filled enough, then it is available
    if (scalar $queue->@* < $self->limit) {
        push @$queue, $slot;
        $slot->[1] = $loop->new_future->done;
        $slot->[0]->done(time);
        return $queue->[-1][0];
    }

    # else , the current request's available time is the execution timestamp of the last $limit request push the interval
    my $prev_slot     = $queue->[-$self->limit];
    my $interval = $self->interval;
    $slot->[1] = $prev_slot->[0]->then(
        sub {
            my $prev_slot_time = shift;
            # execute after
            my $after = $prev_slot_time + $interval - time();
            $loop->delay_future(after => $after)->on_ready(
                sub {
                    # remove old slots before current slot
                    for (0 .. $#$queue) {
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
    push @$queue, $slot;
    return $queue->[-1][0];
}

sub acquire_high_priority {
    my $self = shift;
    my $queue = $self->{queue};

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

