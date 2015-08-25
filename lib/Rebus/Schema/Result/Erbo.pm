use utf8;
package Rebus::Schema::Result::Erbo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus::Schema::Result::Erbo

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<erbo>

=cut

__PACKAGE__->table("erbo");

=head1 ACCESSORS

=head2 erbo_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 erbo

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 rank

  data_type: 'integer'
  default_value: 999
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "erbo_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "erbo",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "rank",
  { data_type => "integer", default_value => 999, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</erbo_id>

=back

=cut

__PACKAGE__->set_primary_key("erbo_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EHIolRO/NAlppZm4Dqa3QA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
