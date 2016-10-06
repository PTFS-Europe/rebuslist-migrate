use utf8;

package Rebus2::Schema::Result::ListMaterial;

=head1 NAME

Rebus2::Schema::Result::ListMaterial

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_material>

=cut

__PACKAGE__->table("list_materials");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 added

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  is_nullable: 0

=head2 dislikes

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 likes

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 category_id

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 note

  data_type: 'text'
  default_value: null
  is_nullable: 1

=head2 source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source_uuid

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "material_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "added",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0},
  "rank",
  {data_type => "integer", is_nullable => 0},
  "dislikes",
  {data_type => "integer", default_value => 0, is_nullable => 0,},
  "likes",
  {data_type => "integer", default_value => 0, is_nullable => 0,},
  "category_id",
  {data_type => "integer", default_value => 0, is_foreign_key => 1, is_nullable => 0,},
  "note",
  {data_type => "text", is_nullable => 1},
  "source_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "source_uuid",
  {data_type => "text", is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=item * L</material_id>

=back

=cut

__PACKAGE__->set_primary_key("list_id", "material_id");

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Rebus2::Schema::Result::Category",
  {id            => "category_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material",
  "Rebus2::Schema::Result::Material",
  {id            => "material_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 frbr_equivalents

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterialFRBR>

=cut

__PACKAGE__->has_many(
  "frbr_equivalents",
  "Rebus2::Schema::Result::ListMaterialFRBR",
  {"foreign.list_id" => "self.list_id", "foreign.material_id" => "self.material_id"},
  {cascade_copy      => 0,              cascade_delete        => 0},
);

=head2 list_alternatives

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterialAlternative>

=cut

__PACKAGE__->has_many(
  "list_alternatives",
  "Rebus2::Schema::Result::ListMaterialAlternative",
  {"foreign.list_id" => "self.list_id", "foreign.material_id" => "self.material_id"},
  {cascade_copy      => 0,              cascade_delete        => 0},
);


=head2 source

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Rebus2::Schema::Result::Source",
  {id            => "source_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
