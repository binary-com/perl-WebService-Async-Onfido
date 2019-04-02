package WebService::Async::Onfido::Applicant;

use strict;
use warnings;

use parent qw(WebService::Async::Onfido::Base::Applicant);

# VERSION

=head1 NAME

WebService::Async::Onfido::Applicant - represents data for Onfido

=head1 DESCRIPTION

=cut

sub as_string {
    my ($self) = @_;
    sprintf '%s %s (ID %s)', $self->first_name, $self->last_name, $self->id
}

sub onfido { shift->{onfido} }

sub documents {
    my ($self, %args) = @_;
    $self->onfido->document_list(
        applicant_id => $self->id,
        %args
    )->map(sub { $_->{applicant} = $self; $_ });
}

sub delete : method {
    my ($self, %args) = @_;
    return $self->onfido->applicant_delete(
        applicant_id => $self->id,
        %args
    );
}

sub get : method {
    my ($self) = @_;
    return $self->onfido->applicant_get(
        applicant_id => $self->id,
    );
}

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.

