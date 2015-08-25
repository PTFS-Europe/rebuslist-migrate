use utf8;
package Rebus1::Schema::Result::OwnersLink;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::OwnersLink

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<owners_link>

=cut

__PACKAGE__->table("owners_link");

=head1 ACCESSORS

=head2 owner_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 list_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 leader_yn

  data_type: 'set'
  default_value: 'n'
  extra: {list => ["y","n"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "owner_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "list_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "leader_yn",
  {
    data_type => "set",
    default_value => "n",
    extra => { list => ["y", "n"] },
    is_nullable => 0,
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9mcHfYTYsZhmhKSB+mdvUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
