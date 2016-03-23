use utf8;

package Rebus::Schema::Result::List;

use Mojo::JSON;

=head1 NAME

Rebus::Schema::Result::List

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw( InflateColumn::DateTime Tree::NestedSet Tree::Inheritance FilterColumn ));

=head1 TABLE: C<list>

=cut

__PACKAGE__->table("lists");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
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
  is_nullable: 0

=head2 rgt

  data_type: 'integer'
  is_nullable: 0

=head2 level

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 no_students

  data_type: 'integer'
  is_nullable: 1

=head2 ratio_books

  data_type: 'integer'
  is_nullable: 1

=head2 ratio_students

  data_type: 'integer'
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

=head2 source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source_uuid

  data_type: 'text'
  is_nullable: 1

=head2 course_identifier

  data_type: 'text'
  is_nullable: 1

=head2 year

  data_type: 'integer'
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

  data_type: 'text'
  is_nullable: 1

=head2 public_note

  data_type: 'text'
  is_nullable: 1

=head2 private_note

  data_type: 'text'
  is_nullable: 1

=head2 material_count

  data_type: 'integer'
  default_value: 0
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
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "type",
  {data_type => "integer", is_nullable => 1},
  "root_id",
  {data_type => "integer", is_nullable => 1},
  "lft",
  {data_type => "integer", is_nullable => 0},
  "rgt",
  {data_type => "integer", is_nullable => 0},
  "level",
  {data_type => "integer", is_nullable => 0},
  "name",
  {data_type => "text", is_nullable => 0},
  "no_students",
  {data_type => "integer", is_nullable => 1},
  "ratio_books",
  {data_type => "integer", is_nullable => 1},
  "ratio_students",
  {data_type => "integer", is_nullable => 1},
  "updated",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0},
  "created",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0},
  "source_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "source_uuid",
  {data_type => "text", is_nullable => 1},
  "course_identifier",
  {data_type => "text", is_nullable => 1},
  "year",
  {data_type => "integer", is_nullable => 1},
  "validity_start",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, is_nullable => 1},
  "validity_end",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, is_nullable => 1},
  "published",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
  "wip",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
  "moderating",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
  "summary",
  {data_type => "text", is_nullable => 1},
  "public_note",
  {data_type => "text", is_nullable => 1},
  "private_note",
  {data_type => "text", is_nullable => 1},
  "material_count",
  {data_type => "integer", default_value => 0, is_nullable => 0},
  "inherited_validity_start",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, is_nullable => 0},
  "inherited_validity_end",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, is_nullable => 0},
  "inherited_published",
  {data_type => "tinyint", is_nullable => 0},
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

Related object: L<Rebus::Schema::Result::List>

=cut

__PACKAGE__->tree_columns(
  {root_column => 'root_id', left_column => 'lft', right_column => 'rgt', level_column => 'level',});

=head2 buffer

Type: might_have

Related object: L<Rebus::Schema::Result::Buffer>

=cut

__PACKAGE__->might_have(
  "buffer",
  "Rebus::Schema::Result::Buffer",
  {"foreign.list_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

=head2 list_materials

Type: has_many

Related object: L<Rebus::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials", "Rebus::Schema::Result::ListMaterial",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 list_user_roles

Type: has_many

Related object: L<Rebus::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles", "Rebus::Schema::Result::ListUserRole",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 material_tags

Type: has_many

Related object: L<Rebus::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags", "Rebus::Schema::Result::MaterialTag",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 source

Type: belongs_to

Related object: L<Rebus::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Rebus::Schema::Result::Source",
  {id            => "source_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 users

Type: many_to_many

Composing rels: L</list_user_roles> -> user

=cut

sub users {
  my $self = shift;

  return $self->search_related('list_user_roles', {})->search_related('user', {});
}

#__PACKAGE__->many_to_many("users" => "list_user_roles", "user");

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
      'join'     => 'material',
      'select'   => [qw/category rank likes dislikes note/],
      'as'       => [qw/category rank likes dislikes note/],
      'order_by' => [qw/category rank/],
      '+select'  => [qw/material.id material.in_stock material.metadata/],
      '+as'      => [qw/id in_stock metadata/],
    }
  );
}

__PACKAGE__->filter_column(
  published => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

__PACKAGE__->filter_column(
  inherited_published => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

__PACKAGE__->filter_column(
  wip => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);


__PACKAGE__->filter_column(
  moderating => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

__PACKAGE__->inheritable_columns(parent =>
    [qw/no_students ratio_books ratio_students course_identifier year validity_start validity_end published summary/]);

1;
