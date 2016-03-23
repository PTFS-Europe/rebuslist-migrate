use utf8;

package Rebus2::Schema::Result::ListRolePrivilege;

=head1 NAME

Rebus2::Schema::Result::ListRolePrivilege

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_role_privileges>

=cut

__PACKAGE__->table("list_role_privileges");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 privilege_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "role_id",      {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "privilege_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</role>

=item * L</privilege>

=back

=cut

__PACKAGE__->set_primary_key("role_id", "privilege_id");

=head1 RELATIONS

=head2 list_role

Type: belongs_to

Related object: L<Rebus2::Schema::Result::SystemRole>

=cut

__PACKAGE__->belongs_to(
  "list_role",
  "Rebus2::Schema::Result::ListRole",
  {id            => "role_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 privilege

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Privilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "Rebus2::Schema::Result::Privilege",
  {id            => "privilege_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1
