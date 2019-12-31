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

use Carp qw();
use Future;
use mro;

use parent qw(IO::Async::Notifier);

=head1 NAME

WebService::Async::CustomerIO::RateLimitter - This class provide possibility to limit amount
of request in time interval

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

sub _init {
    my ($self, $args) = @_;
    for my $k (qw(limit interval)) {
        die "Missing required argument: $k" unless exists $args->{$k};
        die "Invalid value for $k: $args->{$k}" unless int($args->{$k}) > 0;
        $self->{$k} = delete $args->{$k} if exists $args->{$k};
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

sub is_limited {
    my $self = shift;
    # the number of slots is less.
    return scalar($self->{queue}->@*) >= $self->limit
        # the item of [-$limit] is not ready or is ready but passed no more than interval seconds
        && (!($self->{queue}[-$self->limit]->is_ready) || (time() - $self->{queue}[-$self->limit]->get < $self->interval));
}

sub acquire {
    my $self = shift;
    my $slot;
    my $queue = $self->{queue};
    if (scalar $queue->@* < $self->limit) {
        push @$queue, Future->done(time());
        return $queue->[-1];
    }

    my $item     = $queue->[-$self->limit];
    my $interval = $self->interval;
    my $loop     = $self->loop;
    push @$queue, $item->then(
        sub {
            my $item_time = shift;
            # execute after
            my $after = $item_time + $interval - time();
            #say "after is $after";
            $loop->delay_future(after => $after)->then(
                sub {
                    # remove old slots before current slot
                    for (0 .. $#$queue) {
                        last unless $queue->[0]->is_ready;
                        # if the slot too old
                        if (time() - $queue->[0]->get > $interval) {
                            shift @$queue;
                        } else {
                            last;
                        }
                    }
                    Future->done(time());
                });
        });
    return $queue->[-1];
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

