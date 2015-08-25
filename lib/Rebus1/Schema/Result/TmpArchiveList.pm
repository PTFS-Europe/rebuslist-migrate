use utf8;
package Rebus1::Schema::Result::TmpArchiveList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::TmpArchiveList

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tmp_archive_lists>

=cut

__PACKAGE__->table("tmp_archive_lists");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("list_id", { data_type => "integer", is_nullable => 0 });

=head1 UNIQUE CONSTRAINTS

=head2 C<list_id>

=over 4

=item * L</list_id>

=back

=cut

__PACKAGE__->add_unique_constraint("list_id", ["list_id"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ykv+i+mEuElcLtut3hEZlA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
