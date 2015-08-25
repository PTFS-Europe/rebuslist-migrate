use utf8;
package Rebus1::Schema::Result::Sequence;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::Sequence

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<sequence>

=cut

__PACKAGE__->table("sequence");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 rank

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "material_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "rank",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fNG/N10ff1uqziIlnVZkpw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
