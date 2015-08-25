use utf8;
package Rebus2::Schema::Result::List;

=head1 NAME

Rebus2::Schema::Result::List

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components( qw( InflateColumn::DateTime Tree::NestedSet Tree::Inheritance FilterColumn ) );

=head1 TABLE: C<list>

=cut

__PACKAGE__->table("lists");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'integer'
  is_nullable: 0

=head2 root_id

  data_type: 'integer'
  is_nullable: 1

=head2 lft

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 rgt

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 level

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 1024

=head2 no_students

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 ratio_books

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 ratio_students

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 source

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 source_uuid

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 course_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 year

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 validity_start

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 validity_end

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 published

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 wip

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 moderating

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 summary

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=head2 material_count

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 inherited_validity_start

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 inherited_validity_end

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 inherited_published

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "type",
  { data_type => "integer", is_nullable => 1 },
  "root_id",
  { data_type => "integer", is_nullable => 1 },
  "lft",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "rgt",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "level",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 1024 },
  "no_students",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "ratio_books",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "ratio_students", 
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "source",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "source_uuid",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "course_identifier",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "year",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "validity_start",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "validity_end",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "published",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "wip",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "moderating",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "summary",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
  "material_count",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "inherited_validity_start",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "inherited_validity_end",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "inherited_published",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tree_columns

Type: special

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->tree_columns(
    {
        root_column  => 'root_id',
        left_column  => 'lft',
        right_column => 'rgt',
        level_column => 'level',
    }
);

=head2 buffer

Type: might_have

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->might_have(
  "buffer",
  "Rebus2::Schema::Result::Buffer",
  { "foreign.list" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 list_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials",
  "Rebus2::Schema::Result::ListMaterial",
  { "foreign.list" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 list_users

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUser>

=cut

__PACKAGE__->has_many(
  "list_users",
  "Rebus2::Schema::Result::ListUser",
  { "foreign.list" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 material_tags

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags",
  "Rebus2::Schema::Result::MaterialTag",
  { "foreign.list" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 materials_grouped

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialGrouped>

=cut

__PACKAGE__->has_many(
  "materials_grouped",
  "Rebus2::Schema::Result::MaterialGrouped",
  { "foreign.list" => "self.id" },
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

__PACKAGE__->filter_column(
    published => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

__PACKAGE__->filter_column(
    inherited_published => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

__PACKAGE__->filter_column(
    wip => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);


__PACKAGE__->filter_column(
    moderating => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

=head2 users

Type: many_to_many

Composing rels: L</list_users> -> user

=cut

__PACKAGE__->many_to_many("users" => "list_users", "user");

=head2 materials

Type: many_to_many

Composing rels: L</list_materials> -> material

=cut

sub materials {
    my $self = shift;

    return $self->search_related(
        'list_materials',
        {},
        {
            'join' => 'material',
            'select' => [qw/category rank likes dislikes/],
            'as' => [qw/category rank likes dislikes/],
            'order_by' => [qw/category rank/],
            '+select' => [qw/material.id material.in_stock material.metadata/],
            '+as' => [qw/id in_stock metadata/],
        }
    );
}

=head2 list_materials_sorted

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

Description: Custom addition to list_materials to ensure resultset is always sorted as expected; by category rank, and rank.

=cut

sub list_materials_sorted {
    my $self = shift;
    my $tags = shift;

    my $prefetch_material;
    if ( $tags ) {
        $prefetch_material = { 'material' => 'material_tags' };
    } else {
        $prefetch_material = 'material';
    }

    # NOTE: Are these prefetches best done here or further up the execution path?
    return $self->search_related(
        'list_materials',
        {},
        {
            'prefetch' =>
              [ 'category', $prefetch_material, { 'materials_grouped' => 'material' } ],
            'order_by' => [qw/category.rank me.rank/]
        }
    );
}


__PACKAGE__->inheritable_columns(
    parent => [
        qw/no_students ratio_books ratio_students course_identifier year validity_start validity_end published summary/
    ]
);

1;
