use utf8;
package Rebus1::Schema::Result::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::Config

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 config_code

  data_type: 'varchar'
  default_value: 0
  is_nullable: 0
  size: 30

=head2 config_content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "config_code",
  { data_type => "varchar", default_value => 0, is_nullable => 0, size => 30 },
  "config_content",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</config_code>

=back

=cut

__PACKAGE__->set_primary_key("config_code");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fKjDZyaVG9PNBRMv5gjwqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
