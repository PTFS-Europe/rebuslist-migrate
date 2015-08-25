use utf8;
package Rebus1::Schema::Result::TagLink;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::TagLink

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tag_links>

=cut

__PACKAGE__->table("tag_links");

=head1 ACCESSORS

=head2 material_id

  data_type: 'integer'
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "material_id",
  { data_type => "integer", is_nullable => 0 },
  "tag_id",
  { data_type => "integer", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kbCNfe30GTs3//p1PwLYcg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
