use utf8;
package Rebus1::Schema::Result::MaterialType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::MaterialType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material_types>

=cut

__PACKAGE__->table("material_types");

=head1 ACCESSORS

=head2 material_type_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 material_type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 50

=cut

__PACKAGE__->add_columns(
  "material_type_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "material_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</material_type_id>

=back

=cut

__PACKAGE__->set_primary_key("material_type_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8x7O9xjhCsImOlcqarSrrg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
