use utf8;
package Rebus2::Schema::Result::ListRole;

=head1 NAME

Rebus2::Schema::Result::ListRole

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

=head1 TABLE: C<list_role>

=cut

__PACKAGE__->table("list_roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 permissive

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "permissive",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 list_users

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUser>

=cut

__PACKAGE__->has_many(
  "list_users",
  "Rebus2::Schema::Result::ListUser",
  { "foreign.role" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->filter_column(
    permissive => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

1;
