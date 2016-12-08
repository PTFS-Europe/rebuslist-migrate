use utf8;

package Rebus2::Schema::Result::Usertype;

=head1 NAME

Rebus2::Schema::Result::Usertype

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<usertypes>

=cut

__PACKAGE__->table("usertypes");

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
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id", {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "name",        {data_type => "text", is_nullable => 0},
  "description", {data_type => "text", is_nullable => 0},
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

__PACKAGE__->add_unique_constraint(usertype_name => [qw/name/]);

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users", "Rebus2::Schema::Result::User",
  {"foreign.usertype_id" => "self.id"},
  {cascade_copy          => 0, cascade_delete => 0},
);

=head2 usertype_privileges

Type: has_many

Related object: L<Rebus2::Schema::Result::UsertypePrivilege>

=cut

__PACKAGE__->has_many(
  "usertype_privileges", "Rebus2::Schema::Result::UsertypePrivilege",
  {"foreign.usertype_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 1},
);

=head2 privileges

Type: many_to_many

Related object: L<Rebus2::Schema::Result::Privilege>

=cut

__PACKAGE__->many_to_many("privileges" => "usertype_privileges", "privilege");

1;
