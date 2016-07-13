use utf8;

package Rebus2::Schema::Result::MaterialFixedFields;

=head1 NAME

Rebus2::Schema::Result::MaterialFixedFields

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material_fixed_fields>

=cut

__PACKAGE__->table("material_fixed_fields");

=head1 ACCESSORS

=head2 material_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 field

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "material_id", {data_type => "integer", is_auto_increment => 0, is_nullable => 0,},
  "field", {data_type => "text", is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L </material_id>

=item * L </field>

=back

=cut

__PACKAGE__->set_primary_key("material_id", "field");

=head1 RELATIONS

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

1;
