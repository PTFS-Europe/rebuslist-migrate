use utf8;
package Rebus1::Schema::Result::List;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::List

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<lists>

=cut

__PACKAGE__->table("lists");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 org_unit_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 list_name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1024

=head2 published_yn

  data_type: 'set'
  extra: {list => ["y","n","lib"]}
  is_nullable: 1

=head2 no_students

  data_type: 'integer'
  is_nullable: 1

=head2 ratio_books

  data_type: 'integer'
  is_nullable: 1

=head2 ratio_students

  data_type: 'integer'
  is_nullable: 1

=head2 last_updated

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 creation_date

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 course_identifier

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "list_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "org_unit_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "list_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 1024 },
  "published_yn",
  {
    data_type => "set",
    extra => { list => ["y", "n", "lib"] },
    is_nullable => 1,
  },
  "no_students",
  { data_type => "integer", is_nullable => 1 },
  "ratio_books",
  { data_type => "integer", is_nullable => 1 },
  "ratio_students",
  { data_type => "integer", is_nullable => 1 },
  "last_updated",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "creation_date",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "course_identifier",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=back

=cut

__PACKAGE__->set_primary_key("list_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:y5m41LfIdp+U9jvzUp9zXw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
