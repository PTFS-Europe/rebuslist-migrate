use utf8;

package Rebus::Schema::Result::ListRole;

use Mojo::JSON;

=head1 NAME

Rebus::Schema::Result::ListRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_role>

=cut

__PACKAGE__->table("list_roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "name", {data_type => "text", is_nullable => 0},
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

Related object: L<Rebus::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles",
  "Rebus::Schema::Result::ListUserRole",
  {"foreign.role_id" => "self.id"},
  {cascade_delete    => 1},
);

=head2 privileges

Type: has_many

Related object: L<Rebus::Schema::Result::ListRolePrivilege>

=cut

__PACKAGE__->has_many(
  "privileges", "Rebus::Schema::Result::ListRolePrivilege",
  {"foreign.role_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 flags

Type: has_many

Related object: L<Rebus::Schema::Result::ListRoleFlag>

=cut

__PACKAGE__->has_many(
  "flags",
  "Rebus::Schema::Result::ListRoleFlag",
  {"foreign.role_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

1;
