use utf8;

package Rebus::Schema::Result::Tag;

=head1 NAME

Rebus::Schema::Result::Tag

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

=head1 TABLE: C<tag>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 text

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "text", {data_type => "text", is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=over 4

=item * L</text>

=back

=cut

__PACKAGE__->add_unique_constraint(tag => [qw/text/]);

=head1 RELATIONS

=head2 material_tags

Type: has_many

Related object: L<Rebus::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags", "Rebus::Schema::Result::MaterialTag",
  {"foreign.tag_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

1;
