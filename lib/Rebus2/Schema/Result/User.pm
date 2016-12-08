use utf8;

package Rebus2::Schema::Result::User;

use Mojo::JSON;

=head1 NAME

Rebus2::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw( FilterColumn InflateColumn::DateTime PassphraseColumn ));

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 usertype_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 login

  data_type: 'text'
  is_nullable: 1

=head2 remote

  data_type: 'tinyint'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'tinyint'
  is_nullable: 0

=head2 reset_guid

  data_type: 'text'
  is_nullable: 1

=head2 reset_request

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "name",
  {data_type => "text", is_nullable => 0},
  "usertype_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 1,},
  "login",
  {data_type => "text", is_nullable => 1},
  "remote",
  {data_type => "tinyint", is_nullable => 0, default_value => 0},
  "password",
  {
    data_type               => "text",
    is_nullable             => 1,
    passphrase              => 'rfc2307',
    passphrase_class        => 'BlowfishCrypt',
    passphrase_args         => {cost => '8', salt_random => 1,},
    passphrase_check_method => 'check_passphrase',
  },
  "email",
  {data_type => "text", is_nullable => 1},
  "active",
  {data_type => "tinyint", is_nullable => 0},
  "reset_guid",
  {data_type => "text", is_nullable => 1},
  "reset_request",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, is_nullable => 1},

);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<login>

=over 4

=item * L</login>

=back

=cut

__PACKAGE__->add_unique_constraint("login", ["login"]);

=head1 RELATIONS

=head2 privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::UserPrivilege>

=cut

__PACKAGE__->has_many(
  "privileges", "Rebus2::Schema::Result::UserPrivilege",
  {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 buffers

Type: has_many

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->has_many(
  "buffers",
  "Rebus2::Schema::Result::Buffer",
  {"foreign.user_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

=head2 list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles", "Rebus2::Schema::Result::ListUserRole",
  {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 explicit_list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "explicit_list_user_roles",
  "Rebus2::Schema::Result::ListUserRole",
  sub {
    my $args = shift;

    return (
      {
        "$args->{foreign_alias}.user_id" => {'-ident' => "$args->{self_alias}.id"},
        "$args->{foreign_alias}.list_id" => {'-ident' => "$args->{self_alias}.inherited_from"},
      },
      !$args->{self_result_object}
      ? ()
      : {
        "$args->{foreign_alias}.user_id" => $args->{self_result_object}->id,
        "$args->{foreign_alias}.list_id" => {'-ident' => "$args->{foreign_alias}.inherited_from"},
      },
      !$args->{foreign_values} ? () : {"$args->{self_alias}.id" => $args->{foreign_values}{user_id}}
    );
  },
  {cascade_copy => 0, cascade_delete => 0},
);

=head2 implicit_list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "implicit_list_user_roles",
  "Rebus2::Schema::Result::ListUserRole",
  sub {
    my $args = shift;

    return (
      {
        "$args->{foreign_alias}.user_id" => {-ident => "$args->{self_alias}.id"},
        "$args->{foreign_alias}.list_id" => {'!=' => {'-ident' => "$args->{self_alias}.inherited_from"}},
      },
      !$args->{self_result_object}
      ? ()
      : {
        "$args->{foreign_alias}.user_id" => $args->{self_result_object}->id,
        "$args->{foreign_alias}.list_id" => {'!=' => {'-ident' => "$args->{foreign_alias}.inherited_from"}},
      },
      !$args->{foreign_values} ? () : {"$args->{self_alias}.id" => $args->{foreign_values}{user_id}}
    );
  },
  {cascade_copy => 0, cascade_delete => 0},
);

=head2 lists

Type: many_to_many

Composing rels:  L</list_user_roles> -> list

=cut

__PACKAGE__->many_to_many("lists" => "list_user_roles", "list");

=head2 requests

Type: has_many

Related object: L<Rebus2::Schema::Result::Request>

=cut

__PACKAGE__->has_many(
  "requests",
  "Rebus2::Schema::Result::Request",
  {"foreign.requester_id" => "self.id"},
  {cascade_copy           => 0, cascade_delete => 0},
);

=head2 assigned_requests

Type: has_many

Related object: L<Rebus2::Schema::Result::Request>

=cut

__PACKAGE__->has_many(
  "assigned_requests",
  "Rebus2::Schema::Result::Request",
  {"foreign.assignee_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 usertype

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Usertype>

=cut

__PACKAGE__->belongs_to(
  "usertype",
  "Rebus2::Schema::Result::Usertype",
  {id            => "usertype_id"},
  {is_deferrable => 1, join_type => "LEFT", on_delete => "RESTRICT", on_update => "RESTRICT",},
);

=head1 FILTERS

=head2 active

Type: filter_column
Action: Boolean filter

=cut

__PACKAGE__->filter_column(
  active => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

=head2 remote

Type: filter_column
Action: Boolean filter

=cut

__PACKAGE__->filter_column(
  remote => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
