use utf8;
package Rebus1::Schema::Result::Permission;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::Permission

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<permissions>

=cut

__PACKAGE__->table("permissions");

=head1 ACCESSORS

=head2 permission_code

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 30

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 permission_level

  data_type: 'integer'
  default_value: 999
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "permission_code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 30 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "permission_level",
  { data_type => "integer", default_value => 999, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</permission_code>

=back

=cut

__PACKAGE__->set_primary_key("permission_code");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5rP+GqA/9Y7c2f+FhGGcxg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
