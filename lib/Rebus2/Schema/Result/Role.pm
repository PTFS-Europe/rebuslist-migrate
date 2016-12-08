use utf8;

package Rebus2::Schema::Result::Role;

use Mojo::JSON;

=head1 NAME

Rebus2::Schema::Result::Role

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("roles");

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
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
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

=head2 list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles",
  "Rebus2::Schema::Result::ListUserRole",
  {"foreign.role_id" => "self.id"},
  {cascade_delete    => 1},
);

=head2 role_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::RolePrivilege>

=cut

__PACKAGE__->has_many(
  "role_privileges", "Rebus2::Schema::Result::RolePrivilege",
  {"foreign.role_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 privileges

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Privilege>

=cut

__PACKAGE__->many_to_many("privileges" => "role_privileges", "privilege");

=head2 role_flags

Type: has_many

Related object: L<Rebus2::Schema::Result::RoleFlag>

=cut

__PACKAGE__->has_many(
  "role_flags",
  "Rebus2::Schema::Result::RoleFlag",
  {"foreign.role_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

=head2 flags

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Flag>

=cut

__PACKAGE__->many_to_many("flags" => "role_flags", "flag");

1;
