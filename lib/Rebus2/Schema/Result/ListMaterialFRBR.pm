use utf8;

package Rebus2::Schema::Result::ListMaterialFRBR;

=head1 NAME

Rebus2::Schema::Result::ListMaterialFRBR

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_material_frbr>

=cut

__PACKAGE__->table("list_material_frbr");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 equivalent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",       {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "material_id",   {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "equivalent_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=item * L</material_id>

=item * L</equivalent_id>

=back

=cut

__PACKAGE__->set_primary_key("list_id", "material_id", "equivalent_id");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, join_type => "LEFT", on_delete => "CASCADE", on_update => "RESTRICT",},
);

=head2 material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material",
  "Rebus2::Schema::Result::Material",
  {id            => "material_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 equivalent

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "equivalent",
  "Rebus2::Schema::Result::Material",
  {id            => "equivalent_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 list_material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->belongs_to(
  "list_material",
  "Rebus2::Schema::Result::ListMaterial",
  {'foreign.list_id' => 'self.list_id', 'foreign.material_id' => 'self.material_id'},
  {is_deferrable => 1, join_type => "LEFT", on_delete => "CASCADE", on_update => "RESTRICT"},
);

1;
