use utf8;

package Rebus2::Schema::Result::Flag;

=head1 NAME

Rebus2::Schema::Result::Flag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<flag>

=cut

__PACKAGE__->table("flags");

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

=head2 list_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListRoleFlag>

=cut

__PACKAGE__->has_many(
  "list_roles",
  "Rebus2::Schema::Result::ListRoleFlag",
  {"foreign.flag_id" => "self.id"},
  {cascade_copy      => 0, cascade_delete => 0},
);

1
