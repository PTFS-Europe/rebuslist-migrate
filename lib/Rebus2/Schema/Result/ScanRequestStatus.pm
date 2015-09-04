use utf8;
package Rebus2::Schema::Result::ScanRequestStatus;

=head1 NAME

Rebus2::Schema::Result::ScanRequestStatus

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<scan_request_status>

=cut

__PACKAGE__->table("scan_request_statuses");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 status

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "status",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 scan_requests

Type: has_many

Related object: L<Rebus2::Schema::Result::ScanRequest>

=cut

__PACKAGE__->has_many(
  "scan_requests",
  "Rebus2::Schema::Result::ScanRequest",
  { "foreign.status" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
