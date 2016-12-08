use utf8;

package Rebus2::Schema::Result::ListAction;

=head1 NAME

Rebus2::Schema::Result::ListAction

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

=head1 TABLE: C<list_action>

=cut

__PACKAGE__->table("list_actions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 action_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 undertaken

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "list_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "user_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "action_name",
  {data_type => "text", is_foreign_key => 1, is_nullable => 0,},
  "undertaken",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {"foreign.id"  => "self.list_id"},
  {is_deferrable => 1, on_delete => "CASCADE", is_foreign_key_constraint => 1},
);

=head2 buffer

Type: might_have

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->might_have(
  "buffer",
  "Rebus2::Schema::Result::Buffer",
  {"foreign.list_id"         => "self.list_id"},
  {is_foreign_key_constraint => 0},
);

=head2 user

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user", "Rebus2::Schema::Result::User",
  {id            => "user_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 action

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Action>

=cut

__PACKAGE__->belongs_to(
  "action",
  "Rebus2::Schema::Result::Action",
  {"foreign.name" => "self.action_name"},
  {is_deferrable  => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

1;
