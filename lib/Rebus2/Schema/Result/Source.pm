use utf8;

package Rebus2::Schema::Result::Source;

=head1 NAME

Rebus2::Schema::Result::Source

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

=head1 TABLE: C<source>

=cut

__PACKAGE__->table("sources");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "name", {data_type => "text", is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 categories

Type: has_many

Related object: L<Rebus2::Schema::Result::Category>

=cut

__PACKAGE__->has_many(
  "categories",
  "Rebus2::Schema::Result::Category",
  {"foreign.source_id" => "self.id"},
  {cascade_copy        => 0, cascade_delete => 0},
);

=head2 list_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials", "Rebus2::Schema::Result::ListMaterial",
  {"foreign.source_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 lists

Type: has_many

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->has_many(
  "lists", "Rebus2::Schema::Result::List",
  {"foreign.source_id" => "self.id"},
  {cascade_copy        => 0, cascade_delete => 0},
);

1;
