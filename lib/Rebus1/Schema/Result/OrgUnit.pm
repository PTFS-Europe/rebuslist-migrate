use utf8;
package Rebus1::Schema::Result::OrgUnit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::OrgUnit

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<org_units>

=cut

__PACKAGE__->table("org_units");

=head1 ACCESSORS

=head2 org_unit_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 parent

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "org_unit_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "parent",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</org_unit_id>

=back

=cut

__PACKAGE__->set_primary_key("org_unit_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gIa9XU2PO14eq3Itvt2gfQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
