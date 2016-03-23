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

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "name",        {data_type => "text", is_nullable => 0},
  "description", {data_type => "text", is_nullable => 1},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint(name => [qw/name/]);

=head1 RELATIONS

=head2 user_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::UserPrivileges>

=cut

__PACKAGE__->has_many(
  "users",
  "Rebus2::Schema::Result::UserPrivilege",
  {"foreign.privilege_id" => "self.id"},
  {cascade_copy           => 0, cascade_delete => 0},
);

=head2 system_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::SystemRolePrivilege>

=cut

__PACKAGE__->has_many(
  "system_roles",
  "Rebus2::Schema::Result::SystemRolePrivilege",
  {"foreign.privilege_id" => "self.id"},
  {cascade_copy           => 0, cascade_delete => 0},
);

=head2 list_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListRolePrivilege>

=cut

__PACKAGE__->has_many(
  "list_roles",
  "Rebus2::Schema::Result::ListRolePrivilege",
  {"foreign.privilege_id" => "self.id"},
  {cascade_copy           => 0, cascade_delete => 0},
);

1
