use utf8;

package Rebus::Schema::Result::ListUserRole;

use Mojo::JSON;

=head1 NAME

Rebus::Schema::Result::ListUserRole

=cut

use strict;
use warnings;

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::FilterColumn>

=back

=cut

__PACKAGE__->load_components(qw(FilterColumn));

use base 'DBIx::Class::Core';

=head1 TABLE: C<list_user_roles>

=cut

__PACKAGE__->table("list_user_roles");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 inherited

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",   {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "user_id",   {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "role_id",   {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "inherited", {data_type => "tinyint", default_value  => 0, is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=item * L</user_id>

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("list_id", "user_id", "role_id");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 role

Type: belongs_to

Related object: L<Rebus::Schema::Result::ListRole>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Rebus::Schema::Result::ListRole",
  {id            => "role_id"},
  {is_deferrable => 1, on_delete => "CASCADE"},
);

=head2 user

Type: belongs_to

Related object: L<Rebus::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user", "Rebus::Schema::Result::User",
  {id            => "user_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

__PACKAGE__->filter_column(
  inherited => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
