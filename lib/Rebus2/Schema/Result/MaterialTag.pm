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

=head2 material

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 list

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "material",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tag",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "list",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 composite

=over 4

=item * L</material>

=item * L</tag>

=item * L</list>

=back

=cut

__PACKAGE__->add_unique_constraint(
    composite => [ qw/material tag list/ ]
);

=head1 RELATIONS

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
  { join_type => 'left' }
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

=head2 tag

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "Rebus2::Schema::Result::Tag",
  { id => "tag" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
