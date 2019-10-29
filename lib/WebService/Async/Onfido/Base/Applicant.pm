package WebService::Async::Onfido::Base::Applicant;

use strict;
use warnings;

use utf8;

# VERSION

=head1 NAME

WebService::Async::Onfido::Base::Applicant - represents data for Onfido

=head1 DESCRIPTION

This is autogenerated from the documentation in L<https://documentation.onfido.com>.

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{onfido}) if $args{onfido};
    bless \%args, $class;
}

=head1 METHODS
=head2 id

The unique identifier for the applicant.

=cut

sub id : method { shift->{ id } }

=head2 created_at

The date and time when this applicant was created.

=cut

sub created_at : method { shift->{ created_at } }

=head2 delete_at

The date and time when this applicant is scheduled to be deleted, or null if the applicant is not scheduled to be deleted.

=cut

sub delete_at : method { shift->{ delete_at } }

=head2 href

The URI of this resource.

=cut

sub href : method { shift->{ href } }

=head2 title

The applicant's title. Valid values are Mr, Mrs, Miss and Ms.

=cut

sub title : method { shift->{ title } }

=head2 first_name

The applicant's first name.

=cut

sub first_name : method { shift->{ first_name } }

=head2 middle_name

The applicant's middle name(s) or initial.

=cut

sub middle_name : method { shift->{ middle_name } }

=head2 last_name

The applicant's surname.

=cut

sub last_name : method { shift->{ last_name } }

=head2 email

The applicant's email address.

=cut

sub email : method { shift->{ email } }

=head2 gender

The applicant's gender. Valid values are male and female.

=cut

sub gender : method { shift->{ gender } }

=head2 dob

The applicant's date of birth in yyyy-mm-dd format.

=cut

sub dob : method { shift->{ dob } }

=head2 telephone

The applicant's landline phone number.

=cut

sub telephone : method { shift->{ telephone } }

=head2 mobile

The applicant's mobile phone number.

=cut

sub mobile : method { shift->{ mobile } }

=head2 country

The country where this applicant will be checked.  This must be a three-letter ISO code e.g. GBR or USA. If not provided the default is GBR..

=cut

sub country : method { shift->{ country } }

=head2 mothers_maiden_name

The applicant's mother's maiden name.

=cut

sub mothers_maiden_name : method { shift->{ mothers_maiden_name } }

=head2 previous_last_name

The applicant's previous surname.

=cut

sub previous_last_name : method { shift->{ previous_last_name } }

=head2 nationality

The applicant's current nationality.  This must be a three-letter ISO code e.g. GBR or USA.

=cut

sub nationality : method { shift->{ nationality } }

=head2 country_of_birth

The applicant's country of birth.  This must be a three-letter ISO code e.g. GBR or USA.

=cut

sub country_of_birth : method { shift->{ country_of_birth } }

=head2 town_of_birth

The applicant's town of birth.

=cut

sub town_of_birth : method { shift->{ town_of_birth } }

=head2 id_numbers

A collection of identification numbers belonging to this applicant.

=cut

sub id_numbers : method { shift->{ id_numbers } }

=head2 addresses

The address history of the applicant.

=cut

sub addresses : method { shift->{ addresses } }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.

