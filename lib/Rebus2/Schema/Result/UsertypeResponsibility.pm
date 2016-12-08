use utf8;

package Rebus2::Schema::Result::UsertypeResponsibility;

=head1 NAME

Rebus2::Schema::Result::UsertypeResponsibility

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

=head1 TABLE: C<usertype_responsibilities>

=cut

__PACKAGE__->table("usertype_responsibilities");

=head1 ACCESSORS

=head2 usertype_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 responsibility_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "usertype_id",           {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "responsibility_id", {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
);

=head1 PRIMARY KEY

=over 4

=item * L</usertype_id>

=item * L</responsibility_id>

=back

=cut

__PACKAGE__->set_primary_key("usertype_id", "responsibility_id");

=head1 RELATIONS

=head2 usertype

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Usertype>

=cut

__PACKAGE__->belongs_to(
  "type", "Rebus2::Schema::Result::Usertype",
  {id            => "usertype_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 responsibility

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Responsibility>

=cut

__PACKAGE__->belongs_to(
  "responsibility",
  "Rebus2::Schema::Result::Responsibility",
  {id            => "responsibility_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
