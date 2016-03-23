use utf8;

package Rebus::Schema::Result::Material;

use Mojo::JSON;

=head1 NAME

Rebus::Schema::Result::Material

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::Serializer>

=item * L<DBIx::Class::FilterColumn>

=back

=cut

__PACKAGE__->load_components(qw( FilterColumn InflateColumn::Serializer ));

=head1 TABLE: C<material>

=cut

__PACKAGE__->table("materials");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 in_stock

  data_type: 'tinyint'
  is_nullable: 0

=head2 metadata

  data_type: 'jsonb'
  is_nullable: 0

=head2 owner

  data_type: 'text'
  is_nullable: 1

=head2 owner_uuid

  data_type: 'text'
  is_nullable: 1

=head2 frbr_id

  data_type: 'text'
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "in_stock",
  {data_type => "tinyint", is_nullable => 0},
  "metadata",
  {data_type => "jsonb", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "owner",
  {data_type => "text", is_nullable => 1},
  "owner_uuid",
  {data_type => "text", is_nullable => 1},
  "frbr_id",
  {data_type => "text", is_nullable => 1},
  "updated",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=over 4

=item * L</owner>

=item * L</owner_uuid>

=back

=cut

__PACKAGE__->add_unique_constraint(owner => [qw/owner owner_uuid/]);

=head1 RELATIONS

=head2 list_materials

Type: has_many

Related object: L<Rebus::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials", "Rebus::Schema::Result::ListMaterial",
  {"foreign.material_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 material_tags

Type: has_many

Related object: L<Rebus::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags",
  "Rebus::Schema::Result::MaterialTag",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 scan_requests

Type: has_many

Related object: L<Rebus::Schema::Result::ScanRequest>

=cut

__PACKAGE__->has_many(
  "scan_requests",
  "Rebus::Schema::Result::ScanRequest",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

__PACKAGE__->filter_column(
  in_stock => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 frbr_equivalents

Type: has_many

Related object: L<Rebus::Schema::Result::Material>

Description: Custom has_many self join relationship

=cut

__PACKAGE__->has_many(
  "frbr_equivalents",
  "Rebus::Schema::Result::Material",
  sub {
    my $args = shift;
    return {
      "$args->{'foreign_alias'}.frbr_id" => {'-ident' => "$args->{'self_alias'}.frbr_id"},
      "$args->{'foreign_alias'}.id"      => {'!='     => {'-ident' => "$args->{'self_alias'}.id"}}
    };
  }
);

=head2 frbr_list_materials

Type: has_many

Related object: L<Rebus::Schema::Result::ListMaterialFRBR>

=cut

__PACKAGE__->has_many(
  "frbr_list_materials", "Rebus::Schema::Result::ListMaterialFRBR",
  {"foreign.equivalent_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 list_material_alternatives

Type: has_many

Related object: L<Rebus::Schema::Result::ListMaterialAlternative>

=cut

__PACKAGE__->has_many(
  "list_material_alternatives", "Rebus::Schema::Result::ListMaterialAlternative",
  {"foreign.alternative_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head1 EXPANSIONS

=head2 as_hash

Description: Returns material as a hash

=cut

sub as_hash {
  my $self     = shift;
  my $material = {
    id         => $self->id,
    in_stock   => $self->in_stock,
    metadata   => $self->metadata,
    owner      => $self->owner,
    owner_uuid => $self->owner_uuid,
    frbr_id    => $self->frbr_id
  };

  return $material;
}

1;
