use utf8;

package Rebus2::Schema::Result::ResponsibilityPrivilege;

=head1 NAME

Rebus2::Schema::Result::ResponsibilityPrivilege

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<responsibility_privileges>

=cut

__PACKAGE__->table("responsibility_privileges");

=head1 ACCESSORS

=head2 responsibility_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 privilege_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "responsibility_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "privilege_name",    {data_type => "text",    is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</responsibility_id>

=item * L</privilege_name>

=back

=cut

__PACKAGE__->set_primary_key("responsibility_id", "privilege_name");

=head1 RELATIONS

=head2 responsibility

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Responsibility>

=cut

__PACKAGE__->belongs_to(
  "responsibility",
  "Rebus2::Schema::Result::Responsibility",
  {"foreign.id"  => "self.responsibility_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 privilege

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Privilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "Rebus2::Schema::Result::Privilege",
  {"foreign.name" => "self.privilege_name"},
  {is_deferrable  => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
