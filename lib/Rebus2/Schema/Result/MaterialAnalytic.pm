use utf8;

package Rebus2::Schema::Result::MaterialAnalytic;

=head1 NAME

Rebus2::Schema::Result::MaterialAnalytic

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material_analytic>

=cut

__PACKAGE__->table("material_analytic");

=head1 ACCESSORS

=head2 container_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 analytic_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "container_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "analytic_id",  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</container_id>

=item * L</analytic_id>

=back

=cut

__PACKAGE__->set_primary_key("container_id", "analytic_id");

=head1 RELATIONS

=head2 container

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "container",
  "Rebus2::Schema::Result::Material",
  {id            => "container_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 analytic

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "analytic",
  "Rebus2::Schema::Result::Material",
  {id            => "analytic_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

1;
