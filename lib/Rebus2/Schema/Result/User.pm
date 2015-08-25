use utf8;
package Rebus2::Schema::Result::User;

=head1 NAME

Rebus2::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components( qw( FilterColumn InflateColumn::DateTime ) );

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 system_role

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 secret

  data_type: 'integer'
  is_nullable: 1

=head2 login

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 active

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "system_role",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "secret",
  { data_type => "integer", is_nullable => 1 },
  "login",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<login>

=over 4

=item * L</login>

=back

=cut

__PACKAGE__->add_unique_constraint("login", ["login"]);

=head1 RELATIONS

=head2 buffers

Type: has_many

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->has_many(
  "buffers",
  "Rebus2::Schema::Result::Buffer",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 list_users

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUser>

=cut

__PACKAGE__->has_many(
  "list_users",
  "Rebus2::Schema::Result::ListUser",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 scan_requests

Type: has_many

Related object: L<Rebus2::Schema::Result::ScanRequest>

=cut

__PACKAGE__->has_many(
  "scan_requests",
  "Rebus2::Schema::Result::ScanRequest",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_role

Type: belongs_to

Related object: L<Rebus2::Schema::Result::SystemRole>

=cut

__PACKAGE__->belongs_to(
  "system_role",
  "Rebus2::Schema::Result::SystemRole",
  { id => "system_role" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

__PACKAGE__->filter_column(
    active => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

1;
