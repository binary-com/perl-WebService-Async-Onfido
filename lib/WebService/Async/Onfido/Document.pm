package WebService::Async::Onfido::Document;

use strict;
use warnings;

use parent qw(WebService::Async::Onfido::Base::Document);

# VERSION

=head1 NAME

WebService::Async::Onfido::Document - represents data for Onfido

=head1 DESCRIPTION

=cut

sub as_string {
    my ($self) = @_;
    return sprintf '%s %d byte %s, %s %s (ID %s)',
        $self->file_name,
        $self->file_size,
        uc($self->file_type),
        $self->side // 'single',
        $self->type,
        $self->id;
}

sub onfido {return shift->{onfido} }
sub applicant {return shift->{applicant} }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.

