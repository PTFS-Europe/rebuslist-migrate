use utf8;
package Rebus1::Schema::Result::MaterialLabel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::MaterialLabel

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<material_labels>

=cut

__PACKAGE__->table("material_labels");

=head1 ACCESSORS

=head2 label_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 material_type_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 secondary_title

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 authors

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 secondary_authors

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 edition

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 volume

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 issue

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 spage

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 epage

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 year

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 publisher

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 publication_date

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 publication_place

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 print_control_no

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 elec_control_no

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 note

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 print_sysno

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 elec_sysno

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "label_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "material_type_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "secondary_title",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "authors",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "secondary_authors",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "edition",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "volume",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "issue",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "spage",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "epage",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "year",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "publisher",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "publication_date",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "publication_place",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "print_control_no",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "elec_control_no",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "note",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "print_sysno",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "elec_sysno",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);

=head1 PRIMARY KEY

=over 4

=item * L</label_id>

=back

=cut

__PACKAGE__->set_primary_key("label_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iwZdcUHqzwHKVCfGNWx/Uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
