use utf8;

package Rebus2::Schema::Result::MaterialTag;

=head1 NAME

Rebus2::Schema::Result::MaterialTag

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

=head1 TABLE: C<material_tag>

=cut

__PACKAGE__->table("material_tags");

=head1 ACCESSORS

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0
  default_value: 0

=cut

__PACKAGE__->add_columns(
  "material_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "tag_id",      {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "list_id",     {data_type => "integer", is_foreign_key => 1, is_nullable => 0, default_value => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</material_id>

=item * L</tag_id>

=item * L</list_id>

=back

=cut

__PACKAGE__->set_primary_key("material_id", "tag_id", "list_id");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, join_type => "LEFT", on_delete => "CASCADE", on_update => "RESTRICT",},
  {join_type     => 'left'}
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

=head2 tag

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag", "Rebus2::Schema::Result::Tag",
  {id            => "tag_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
