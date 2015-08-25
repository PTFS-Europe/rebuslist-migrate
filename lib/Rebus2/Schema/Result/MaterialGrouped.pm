use utf8;
package Rebus2::Schema::Result::MaterialGrouped;

=head1 NAME

Rebus2::Schema::Result::MaterialGrouped

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<material_grouped>

=cut

__PACKAGE__->table("material_groups");

=head1 ACCESSORS

=head2 group

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 material

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 list

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 gml

  data_type: 'char'
  is_nullable: 0
  size: 11

=cut

__PACKAGE__->add_columns(
  "group",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "material",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "list",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "gml",
  { data_type => "char", is_nullable => 0, size => 11 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gml>

=back

=cut

__PACKAGE__->set_primary_key("gml");

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Rebus2::Schema::Result::Material",
  { id => "group" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list",
  "Rebus2::Schema::Result::List",
  { id => "list" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 list_material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->belongs_to(
  "list_material",
  "Rebus2::Schema::Result::ListMaterial",
  { list => "list", material => "group" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

=head2 material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material",
  "Rebus2::Schema::Result::Material",
  { id => "material" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
