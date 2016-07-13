use utf8;

package Rebus2::Schema::Result::ReportRun;

=head1 NAME

Rebus2::Schema::Result::ReportRun

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw(InflateColumn::DateTime InflateColumn::Serializer));


=head1 TABLE: C<report_runs>

=cut

__PACKAGE__->table("report_runs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 report_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 parameters

  data_type: 'jsonb'
  is_nullable: 1

=head2 completed

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 headers

  data_type: 'jsonb'
  is_nullable: 0

=head2 result

  data_type: 'jsonb'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "report_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "parameters",
  {data_type => "jsonb", is_nullable => 1, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "completed",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0},
  "headers",
  {data_type => "jsonb", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "result",
  {data_type => "jsonb", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}}
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 report

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Report>

=cut

__PACKAGE__->belongs_to(
  "report",
  "Rebus2::Schema::Result::Report",
  {"foreign.id"  => "self.report_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

1;
