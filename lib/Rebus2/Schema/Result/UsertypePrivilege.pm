use utf8;

package Rebus2::Schema::Result::UsertypePrivilege;

=head1 NAME

Rebus2::Schema::Result::UsertypePrivilege

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<usertype_privileges>

=cut

__PACKAGE__->table("usertype_privileges");

=head1 ACCESSORS

=head2 usertype_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 privilege_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "usertype_id",    {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "privilege_name", {data_type => "text",    is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</usertype_id>

=item * L</privilege_name>

=back

=cut

__PACKAGE__->set_primary_key("usertype_id", "privilege_name");

=head1 RELATIONS

=head2 usertype

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Usertype>

=cut

__PACKAGE__->belongs_to(
  "usertype",
  "Rebus2::Schema::Result::Usertype",
  {"foreign.id"  => "self.usertype_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

=head2 privilege

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Privilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "Rebus2::Schema::Result::Privilege",
  {"foreign.name" => "self.privilege_name"},
  {is_deferrable  => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

1;
