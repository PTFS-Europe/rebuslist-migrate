use utf8;

package Rebus2::Schema::Result::Privilege;

=head1 NAME

Rebus2::Schema::Result::Privilege

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<privilege>

=cut

__PACKAGE__->table("privileges");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",        {data_type => "text", is_nullable => 0},
  "description", {data_type => "text", is_nullable => 1},
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 user_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::UserPrivileges>

=cut

__PACKAGE__->has_many(
  "user_privileges",
  "Rebus2::Schema::Result::UserPrivilege",
  {"foreign.privilege_name" => "self.name"},
  {cascade_copy             => 0, cascade_delete => 0},
);

=head2 users

Type: many_to_many

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->many_to_many("users" => "user_privileges", "user");

=head2 usertype_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::UsertypePrivilege>

=cut

__PACKAGE__->has_many(
  "usertype_privileges", "Rebus2::Schema::Result::UsertypePrivilege",
  {"foreign.privilege_name" => "self.name"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 usertypes

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Usertype>

=cut

__PACKAGE__->many_to_many("usertypes" => "usertype_privileges", "usertype");

=head2 responsibility_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::ResponsibilityPrivilege>

=cut

__PACKAGE__->has_many(
  "responsibility_privileges", "Rebus2::Schema::Result::ResponsibilityPrivilege",
  {"foreign.privilege_name" => "self.name"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 responsibilities

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Responsibility>

=cut

__PACKAGE__->many_to_many("responsibilities" => "responsibility_privileges", "responsibility");

=head2 role_privilege

Type: has_many

Related object: L<Rebus2::Schema::Result::RolePrivilege>

=cut

__PACKAGE__->has_many(
  "role_privileges",
  "Rebus2::Schema::Result::RolePrivilege",
  {"foreign.privilege_name" => "self.name"},
  {cascade_copy             => 0, cascade_delete => 0},
);

=head2 roles

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Role>

=cut

__PACKAGE__->many_to_many("roles" => "role_privileges", "role");

1;
