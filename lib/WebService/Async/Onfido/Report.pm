package WebService::Async::Onfido::Report;

use strict;
use warnings;

use parent qw(WebService::Async::Onfido::Base::Report);

# VERSION

=head1 NAME

WebService::Async::Onfido::Report - represents data for Onfido

=head1 DESCRIPTION

=cut

sub as_string {
    my ($self) = @_;
    sprintf 'Report %s %s, result was %s (created %s as ID %s)', $self->name, $self->status, $self->result, $self->created_at, $self->id
}

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.

