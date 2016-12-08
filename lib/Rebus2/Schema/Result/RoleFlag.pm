use utf8;

package Rebus2::Schema::Result::RoleFlag;

=head1 NAME

Rebus2::Schema::Result::RoleFlag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<role_flags>

=cut

__PACKAGE__->table("role_flags");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 flag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "role_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "flag_id",     {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=item * L</flag_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id", "flag_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Rebus2::Schema::Result::Role",
  {id            => "role_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 flag

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Flag>

=cut

__PACKAGE__->belongs_to(
  "flag", "Rebus2::Schema::Result::Flag",
  {id            => "flag_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1
