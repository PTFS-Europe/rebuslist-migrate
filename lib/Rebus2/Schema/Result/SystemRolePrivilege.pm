use utf8;

package Rebus2::Schema::Result::SystemRolePrivilege;

=head1 NAME

Rebus2::Schema::Result::SystemRolePrivilege

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::FilterColumn>

=back

=cut

__PACKAGE__->load_components(qw( FilterColumn ));

=head1 TABLE: C<user_privileges>

=cut

__PACKAGE__->table("system_role_privileges");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 privilege_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 global

  data_type: 'integer'
  is_foreign_key: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "role_id",      {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "privilege_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "global",       {data_type => "integer", is_foreign_key => 0, is_nullable => 1,},
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=item * L</privilege_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id", "privilege_id");

=head1 RELATIONS

=head2 system_role

Type: belongs_to

Related object: L<Rebus2::Schema::Result::SystemRole>

=cut

__PACKAGE__->belongs_to(
  "system_role",
  "Rebus2::Schema::Result::SystemRole",
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

=head1 FILTERS

=head2 global

Type: Boolean

Related column: L<global>

=cut

__PACKAGE__->filter_column(
  global => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1
