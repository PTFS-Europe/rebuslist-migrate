use utf8;
package Rebus1::Schema::Result::MetadataSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::MetadataSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<metadata_sources>

=cut

__PACKAGE__->table("metadata_sources");

=head1 ACCESSORS

=head2 metadata_source_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metadata_source

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 metadata_source_code

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "metadata_source_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "metadata_source",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "metadata_source_code",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</metadata_source_id>

=back

=cut

__PACKAGE__->set_primary_key("metadata_source_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YUZATjxP5wMGhhEWN+OYVA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
