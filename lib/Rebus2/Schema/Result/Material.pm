use utf8;

package Rebus2::Schema::Result::Material;

use Mojo::JSON;

=head1 NAME

Rebus2::Schema::Result::Material

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

=head2 electronic

  data_type: 'tinyint'
  is_nullable: 0
  default_value: 0

=head2 web_link

  data_type: 'text'
  is_nullable: 1

=head2 lms_link

  data_type: 'text'
  is_nullable: 1

=head2 status_link

  data_type: 'text'
  is_nullable: 1

=head2 fulltext_link

  data_type: 'text'
  is_nullable: 1

=head2 delayed_link

  data_type: 'text'
  is_nullable: 1

=head2 id_map

  data_type: 'jsonb'
  is_nullable: 1

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

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
  "electronic",
  {data_type => "tinyint", is_nullable => 0, default_value => 0},
  "frbr_id",
  {data_type => "text", is_nullable => 1},
  "web_link",
  {data_type => "text", is_nullable => 1},
  "lms_link",
  {data_type => "text", is_nullable => 1},
  "status_link",
  {data_type => "text", is_nullable => 1},
  "fulltext_link",
  {data_type => "text", is_nullable => 1},
  "delayed_link",
  {data_type => "text", is_nullable => 1},
  "id_map",
  {data_type => "jsonb", is_nullable => 1, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "created",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
  "updated",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
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

=head2 fixed_fields

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialFixedFields>

=cut

__PACKAGE__->has_many(
  "fixed_fields",
  "Rebus2::Schema::Result::MaterialFixedFields",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 removed_fields

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialRemovedFields>

=cut

__PACKAGE__->has_many(
  "removed_fields",
  "Rebus2::Schema::Result::MaterialRemovedFields",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 list_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials", "Rebus2::Schema::Result::ListMaterial",
  {"foreign.material_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 material_tags

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags",
  "Rebus2::Schema::Result::MaterialTag",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 scans

Type: has_many

Related object: L<Rebus2::Schema::Result::Scan>

=cut

__PACKAGE__->has_many(
  "scans", "Rebus2::Schema::Result::Scan",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 1},
);

=head2 purchases

Type: has_many

Related object: L<Rebus2::Schema::Result::Purchase>

=cut

__PACKAGE__->has_many(
  "purchases",
  "Rebus2::Schema::Result::Purchase",
  {"foreign.material_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 1},
);

=head2 container

Type: might_have

Related object: L<Rebus2::Schema::Result::MaterialAnalytic>

=cut

__PACKAGE__->might_have(container => 'Rebus2::Schema::Result::MaterialAnalytic', {'foreign.analytic_id' => 'self.id'},);

=head2 analytics

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialAnalytic>

=cut

__PACKAGE__->has_many(analytics => 'Rebus2::Schema::Result::MaterialAnalytic', {'foreign.container_id' => 'self.id'},);

=head2 frbr_equivalents

Type: has_many

Related object: L<Rebus2::Schema::Result::Material>

Description: Custom has_many self join relationship

=cut

__PACKAGE__->has_many(
  "frbr_equivalents",
  "Rebus2::Schema::Result::Material",
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

Related object: L<Rebus2::Schema::Result::ListMaterialFRBR>

=cut

__PACKAGE__->has_many(
  "frbr_list_materials", "Rebus2::Schema::Result::ListMaterialFRBR",
  {"foreign.equivalent_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 list_material_alternatives

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterialAlternative>

=cut

__PACKAGE__->has_many(
  "list_material_alternatives", "Rebus2::Schema::Result::ListMaterialAlternative",
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
    frbr_id    => $self->frbr_id,
    electronic => $self->electronic
  };

  $material->{web_link}      = $self->web_link      if defined($self->web_link);
  $material->{lms_link}      = $self->lms_link      if defined($self->lms_link);
  $material->{status_link}   = $self->status_link   if defined($self->status_link);
  $material->{fulltext_link} = $self->fulltext_link if defined($self->fulltext_link);
  $material->{delayed_link}  = $self->delayed_link  if defined($self->delayed_link); 
  $material->{id_map}        = $self->id_map        if defined($self->id_map);

  return $material;
}

=head1 FILTERS

=head2 in_stock

Type: boolean filter

=cut

__PACKAGE__->filter_column(
  in_stock => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 electronic

Type: boolean filter

=cut

__PACKAGE__->filter_column(
  electronic => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
