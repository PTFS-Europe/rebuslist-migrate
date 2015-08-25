use utf8;
package Rebus2::Schema::Result::Material;

=head1 NAME

Rebus2::Schema::Result::Material

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components( qw( FilterColumn InflateColumn::DateTime InflateColumn::Serializer ) );

=head1 TABLE: C<material>

=cut

__PACKAGE__->table("materials");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 in_stock

  data_type: 'tinyint'
  is_nullable: 0

=head2 metadata

  data_type: 'mediumtext'
  is_nullable: 0

=head2 owner

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 owner_uuid

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "in_stock",
  { data_type => "tinyint", is_nullable => 0 },
  "metadata",
  { data_type => "mediumtext", is_nullable => 0, serializer_class => "JSON",  },
  "owner",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "owner_uuid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 list_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials",
  "Rebus2::Schema::Result::ListMaterial",
  { "foreign.material" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_grouped_groups

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

=cut

__PACKAGE__->has_many(
  "material_grouped_groups",
  "Rebus2::Schema::Result::MaterialGrouped",
  { "foreign.group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_grouped_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

=cut

__PACKAGE__->has_many(
  "material_grouped_materials",
  "Rebus2::Schema::Result::MaterialGrouped",
  { "foreign.material" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_tags

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags",
  "Rebus2::Schema::Result::MaterialTag",
  { "foreign.material" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 scan_requests

Type: has_many

Related object: L<Rebus2::Schema::Result::ScanRequest>

=cut

__PACKAGE__->has_many(
  "scan_requests",
  "Rebus2::Schema::Result::ScanRequest",
  { "foreign.material" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->filter_column(
    in_stock => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

=head2 frbr_group

Type: special belongs_to

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

Description: Custom method to return the frbr_parent from a frbr_component 

=cut

sub frbr_group {
    my $self = shift;

    my $result = $self->search_related( 'material_grouped_materials', {},
        { rows => 1 } )->single;
    if ( $result ) {
        return $result->group;
    } else {
        return;
    }
}

=head2 frbr_siblings

Type: special has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

Description: Custom method to return the frbr_siblings from a frbr_component 

=cut

sub frbr_siblings {
    my $self = shift;

    return $self->frbr_group->search_related(
        'material_grouped_groups',
        { list     => undef },
        { prefetch => 'material' }
    );
}

=head2 frbr_components

Type: special has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

Description: Custom method to return the frbr_components from a frbr_parent

=cut

sub frbr_components {
    my $self = shift;

    return $self->search_related(
        'material_grouped_groups',
        { list     => undef },
        { prefetch => 'material' }
    );
}

1;
