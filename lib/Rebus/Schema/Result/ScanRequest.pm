use utf8;
package Rebus::Schema::Result::ScanRequest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus::Schema::Result::ScanRequest

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<scan_requests>

=cut

__PACKAGE__->table("scan_requests");

=head1 ACCESSORS

=head2 scan_request_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=head2 status

  data_type: 'set'
  default_value: 'New'
  extra: {list => ["New","Complete","Deleted"]}
  is_nullable: 0

=head2 requested_date

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "scan_request_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "material_id",
  { data_type => "integer", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "status",
  {
    data_type => "set",
    default_value => "New",
    extra => { list => ["New", "Complete", "Deleted"] },
    is_nullable => 0,
  },
  "requested_date",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</scan_request_id>

=back

=cut

__PACKAGE__->set_primary_key("scan_request_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZS+g4avRcBycesx07MUJdA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
