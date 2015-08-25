use utf8;
package Rebus::Schema::Result::Material;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus::Schema::Result::Material

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material>

=cut

__PACKAGE__->table("material");

=head1 ACCESSORS

=head2 material_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 material_type_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 secondary_title

  data_type: 'text'
  is_nullable: 1

=head2 authors

  data_type: 'text'
  is_nullable: 1

=head2 secondary_authors

  data_type: 'text'
  is_nullable: 1

=head2 edition

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 volume

  data_type: 'integer'
  is_nullable: 1

=head2 issue

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 spage

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 epage

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 year

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 publisher

  data_type: 'text'
  is_nullable: 1

=head2 publication_place

  data_type: 'text'
  is_nullable: 1

=head2 publication_date

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 metadata_source_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 print_control_no

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 elec_control_no

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 erbo_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 1

=head2 in_stock_yn

  data_type: 'set'
  default_value: 'y'
  extra: {list => ["y","n","na"]}
  is_nullable: 0

=head2 created_by

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 created_date

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 modified_by

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 modified_date

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 print_sysno

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 elec_sysno

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 url

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "material_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "material_type_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "secondary_title",
  { data_type => "text", is_nullable => 1 },
  "authors",
  { data_type => "text", is_nullable => 1 },
  "secondary_authors",
  { data_type => "text", is_nullable => 1 },
  "edition",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "volume",
  { data_type => "integer", is_nullable => 1 },
  "issue",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "spage",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "epage",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "year",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "publisher",
  { data_type => "text", is_nullable => 1 },
  "publication_place",
  { data_type => "text", is_nullable => 1 },
  "publication_date",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "metadata_source_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "print_control_no",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "elec_control_no",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "erbo_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "note",
  { data_type => "text", is_nullable => 1 },
  "in_stock_yn",
  {
    data_type => "set",
    default_value => "y",
    extra => { list => ["y", "n", "na"] },
    is_nullable => 0,
  },
  "created_by",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "created_date",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "modified_by",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "modified_date",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "print_sysno",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "elec_sysno",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "url",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</material_id>

=back

=cut

__PACKAGE__->set_primary_key("material_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:11mgApNhip8/kPnbSRwuxA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
