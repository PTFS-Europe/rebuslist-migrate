use utf8;

package Rebus2::Schema::Result::List;

use Mojo::JSON;

=head1 NAME

Rebus2::Schema::Result::List

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::FilterColumn>

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Tree::NestedSet>

=item * L<DBIx::Class::Tree::Inheritance>

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

  data_type: 'enum'
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
  retrieve_on_insert: 1

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

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
  {data_type => "enum", is_nullable => 0, extra => {custom_type_name => 'list_type', list => [qw/unit list sublist/]}},
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
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
  "created",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
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

=head1 COMPONENT DEFINITIONS

=head2 tree_columns

=over 4

=item * L</root_id>

=item * L</lft>

=item * L</rgt>

=item * L</level>

=cut

__PACKAGE__->tree_columns(
  {root_column => 'root_id', left_column => 'lft', right_column => 'rgt', level_column => 'level',});

=head2 inheritable_columns

=over 4

=item * L</no_students>

=item * L</ratio_books>

=item * L</ratio_students>

=item * L</course_identifier>

=item * L</year>

=item * L</validity_start>

=item * L</validity_end>

=item * L</published>

=item * L</summary>

=cut

__PACKAGE__->inheritable_columns(parent =>
    [qw/no_students ratio_books ratio_students course_identifier year validity_start validity_end published summary/]);

=head1 RELATIONS

=head2 buffer

Type: might_have

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->might_have(
  "buffer",
  "Rebus2::Schema::Result::Buffer",
  {"foreign.list_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

=head2 list_materials

Type: has_many

Related object: L<Rebus2::Schema::Result::ListMaterial>

=cut

__PACKAGE__->has_many(
  "list_materials", "Rebus2::Schema::Result::ListMaterial",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 1, cascade_delete => 0},
);

=head2 list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles", "Rebus2::Schema::Result::ListUserRole",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 list_user_roles_inheritance

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles_inheritance", "Rebus2::Schema::Result::ListUserRole",
  {"foreign.inherited_from" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 list_user_roles_assigned

Type: might_have

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles_assigned",
  "Rebus2::Schema::Result::ListUserRole",
  {"foreign.list_id" => "self.id", "foreign.inherited_from" => "self.id"},
  {cascade_copy      => 1,         cascade_delete           => 0},
);

=head2 list_user_roles_inherited

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles_inherited",
  "Rebus2::Schema::Result::ListUserRole",
  sub {
    my $args = shift;
    return (
      {
        "$args->{'foreign_alias'}.list_id"        => {'-ident' => "$args->{'self_alias'}.id"},
        "$args->{'foreign_alias'}.inherited_from" => {'!='     => {'-ident' => "$args->{'self_alias'}.id"}}
      },
      !$args->{self_result_object}
      ? ()
      : {
        "$args->{foreign_alias}.list_id"        => $args->{self_result_object}->id,
        "$args->{foreign_alias}.inherited_from" => {'!=', $args->{'self_result_object'}->id}
      }
    );
  },
  {cascade_copy => 0, cascade_delete => 0},
);

=head2 material_tags

Type: has_many

Related object: L<Rebus2::Schema::Result::MaterialTag>

=cut

__PACKAGE__->has_many(
  "material_tags", "Rebus2::Schema::Result::MaterialTag",
  {"foreign.list_id" => "self.id"}, {cascade_copy => 1, cascade_delete => 0},
);

=head2 source

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Rebus2::Schema::Result::Source",
  {id            => "source_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head1 CUSTOM ACCESSORS

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

=head1 FILTERED COLUMNS

=head2 published

Type: Boolean

=cut

__PACKAGE__->filter_column(
  published => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 inherited_published

Type: Boolean

=cut

__PACKAGE__->filter_column(
  inherited_published => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 wip

Type: Boolean

=cut

__PACKAGE__->filter_column(
  wip => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 moderating

Type: Boolean

=cut

__PACKAGE__->filter_column(
  moderating => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head1 CUSTOM FUNCTIONS

=head2 assign

Given a user and a role, assign said user the given role on this list and ensure inheritance is obeyed

=cut

sub assign {
  my $self = shift;
  my ($userID, $roleID) = @_;

  my $guard = $self->result_source->schema->txn_scope_guard;
  $self->create_related('list_user_roles', {user_id => $userID, role_id => $roleID, inherited_from => $self->id});
  my @descendants = $self->descendants->search(undef, {columns => [qw(id)]})->all;
  for my $descendant (@descendants) {
    $descendant->find_or_create_related('list_user_roles',
      {user_id => $userID, role_id => $roleID, inherited_from => $self->id});
  }
  $guard->commit;

  return $self;
}

=head2 divest

Given a user and a role, divest said user the given role on this list and ensure inheritance is obeyed

=cut

# FIXME: I'm sure this could be done in one query as per List.pm _update_list routine?
sub divest {
  my $self = shift;
  my ($userID, $roleID) = @_;

  my $guard = $self->result_source->schema->txn_scope_guard;
  $self->delete_related('list_user_roles', {user_id => $userID, role_id => $roleID, inherited_from => $self->id});
  my @descendants = $self->descendants->search(undef, {columns => [qw(id)]})->all;
  for my $descendant (@descendants) {
    $descendant->delete_related('list_user_roles',
      {user_id => $userID, role_id => $roleID, inherited_from => $self->id});
  }
  $guard->commit;

  return $self;
}

=head2 clone_branch

Given a list node, clone it and all it's sublist nodes and fix role inheritance on the newly created branch.

=cut

sub clone_branch {
  my $self = shift;

  my $guard       = $self->result_source->schema->txn_scope_guard;
  my $changes     = {created => DateTime->now(time_zone => 'local'), wip => 0, moderating => 0};
  my $cloneResult = $self->take_clone($changes);
  my $code        = $self->result_source->schema->resultset('Source')->find(1)->get_column('name');

  # Fix role inheritance and source_uuid
  my @nodeResults = $cloneResult->descendants->all;
  unshift @nodeResults, $cloneResult;

  for my $nodeResult (@nodeResults) {

    # Fix source_uuid
    if ($nodeResult->source_id == 1) {
      $nodeResult->update({'source_uuid' => $code . "-" . $nodeResult->id});
    }

    # Fix role inheritance
    my @list_user_roles = $nodeResult->list_user_roles_assigned->all;
    for my $list_user_role (@list_user_roles) {
      my @descendants = $nodeResult->descendants->all;
      for my $descendant (@descendants) {
        $descendant->create_related(
          'list_user_roles',
          {
            user_id        => $list_user_role->user_id,
            role_id        => $list_user_role->role_id,
            inherited_from => $nodeResult->id
          }
        );
      }
    }
  }

  $guard->commit;

  $cloneResult->discard_changes;
  return $cloneResult;
}

1;
