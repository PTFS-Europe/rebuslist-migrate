use utf8;

package Rebus2::Schema::Result::ListMaterialRating;

=head1 NAME

Rebus2::Schema::Result::ListMaterialRating

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_material_rating>

=cut

__PACKAGE__->table("list_material_ratings");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",     {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "material_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "user_id",     {data_type => "integer", default_value  => 0, is_nullable => 0,},
  "type",        {data_type => "text",    is_nullable    => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=item * L</material_id>

=item * L</user_id>

=item * L</type>

=back

=cut

__PACKAGE__->set_primary_key("list_id", "material_id", "user_id", "type");

=head1 RELATIONS

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

=head2 user

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user", "Rebus2::Schema::Result::User",
  {id            => "user_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
