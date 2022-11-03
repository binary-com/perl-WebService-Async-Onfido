package WebService::Async::Onfido::Base::Photo;

use strict;
use warnings;

use utf8;

# VERSION

=head1 NAME

WebService::Async::Onfido::Base::Photo - represents data for Onfido

=head1 DESCRIPTION

This is autogenerated from the documentation in L<https://documentation.onfido.com>.

=cut

sub new {
    my ($class, %args) = @_;
    Scalar::Util::weaken($args{onfido}) if $args{onfido};
    return bless \%args, $class;
}

=head1 METHODS
=head2 id

The unique identifier of the live photo.

=cut

sub id : method {return shift->{ id } }

=head2 created_at

The date and time at which the live photo was uploaded.

=cut

sub created_at : method {return shift->{ created_at } }

=head2 href

The URI of this resource.

=cut

sub href : method {return shift->{ href } }

=head2 download_href

The URI that can be used to download the live photo.

=cut

sub download_href : method {return shift->{ download_href } }

=head2 file_name

The name of the uploaded file.

=cut

sub file_name : method {return shift->{ file_name } }

=head2 file_type

The file type of the uploaded file.

=cut

sub file_type : method {return shift->{ file_type } }

=head2 file_size

The size of the file in bytes.

=cut

sub file_size : method {return shift->{ file_size } }

1;

__END__

=head1 AUTHOR

binary.com C<< BINARY@cpan.org >>

=head1 LICENSE

Copyright binary.com 2019. Licensed under the same terms as Perl itself.

