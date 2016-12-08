use utf8;

package Rebus2::Schema::Result::Action;

=head1 NAME

Rebus2::Schema::Result::Action

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<action>

=cut

__PACKAGE__->table("actions");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",        {data_type => "text", is_nullable => 0},
  "description", {data_type => "text", is_nullable => 1},
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

1;
