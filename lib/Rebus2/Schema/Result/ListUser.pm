use utf8;
package Rebus2::Schema::Result::ListUser;

=head1 NAME

Rebus2::Schema::Result::ListUser

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components( qw(InflateColumn::DateTime FilterColumn) );

=head1 TABLE: C<list_user>

=cut

__PACKAGE__->table("list_users");

=head1 ACCESSORS

=head2 list

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 role

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 inherited

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "role",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "inherited",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</list>

=item * L</user>

=item * L</role>

=back

=cut

__PACKAGE__->set_primary_key("list", "user", "role");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list",
  "Rebus2::Schema::Result::List",
  { id => "list" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 role

Type: belongs_to

Related object: L<Rebus2::Schema::Result::ListRole>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Rebus2::Schema::Result::ListRole",
  { id => "role" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 user

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Rebus2::Schema::Result::User",
  { id => "user" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

__PACKAGE__->filter_column(
    inherited => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

1;
