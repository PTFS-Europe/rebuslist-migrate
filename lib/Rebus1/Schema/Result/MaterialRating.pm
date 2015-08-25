use utf8;
package Rebus1::Schema::Result::MaterialRating;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::MaterialRating

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material_ratings>

=cut

__PACKAGE__->table("material_ratings");

=head1 ACCESSORS

=head2 material_id

  data_type: 'integer'
  is_nullable: 0

=head2 likes

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 not_likes

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "material_id",
  { data_type => "integer", is_nullable => 0 },
  "likes",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "not_likes",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<material_id>

=over 4

=item * L</material_id>

=back

=cut

__PACKAGE__->add_unique_constraint("material_id", ["material_id"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fKf8/HP7nCAHKi8hkl7n9Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
