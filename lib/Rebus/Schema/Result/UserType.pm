use utf8;
package Rebus::Schema::Result::UserType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus::Schema::Result::UserType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<user_types>

=cut

__PACKAGE__->table("user_types");

=head1 ACCESSORS

=head2 type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=head2 permission_level

  data_type: 'integer'
  default_value: 999
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
  "permission_level",
  { data_type => "integer", default_value => 999, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</type_id>

=back

=cut

__PACKAGE__->set_primary_key("type_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mhACw/qlg/rwsmv6xXMLnA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
