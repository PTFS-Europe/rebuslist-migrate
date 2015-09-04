use utf8;
package Rebus2::Schema::Result::ListMaterial;

=head1 NAME

Rebus2::Schema::Result::ListMaterial

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

=head1 TABLE: C<list_material>

=cut

__PACKAGE__->table("list_materials");

=head1 ACCESSORS

=head2 list

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material

  data_type: 'integer'
  is_foreign_key: 1
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

=head2 category

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 source

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source_uuid

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "material",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "rank",
  { data_type => "integer", is_nullable => 0 },
  "dislikes",
  {
    data_type => "integer",
    default_value => 0,
    is_nullable => 0,
  },
  "likes",
  {
    data_type => "integer",
    default_value => 0,
    is_nullable => 0,
  },
  "category",
  {
    data_type => "integer",
    default_value => 0,
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "source",
  {
    data_type => "integer",
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "source_uuid",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</list>

=item * L</material>

=item * L</category>

=item * L</source>

=back

=cut

__PACKAGE__->set_primary_key("list", "material");

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Rebus2::Schema::Result::Category",
  { id => "category" },
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
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
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

=head2 materials_grouped

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

=cut

__PACKAGE__->has_many(
  "materials_grouped",
  "Rebus2::Schema::Result::MaterialGrouped",
  { "foreign.group" => "self.material", "foreign.list" => "self.list" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 source

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Rebus2::Schema::Result::Source",
  { id => "source" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 materials_grouped_all

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

=cut

sub materials_grouped_all {
    my $self = shift;

    # FIXME: There should be a simple way to use COALESCE, IFNULL, MAX and GROUP BY to strip 
    # out duplicate rows here.  But for now we're going to give up and handle it at 
    # the caller side.
    return $self->material->search_related(
        'material_grouped_groups',
        { 'list' => [ undef, $self->get_column('list') ] },
        { order_by => { '-desc' => 'list' } }
    );
}

1;
