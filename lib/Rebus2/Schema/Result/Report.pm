use utf8;

package Rebus2::Schema::Result::Report;

=head1 NAME

Rebus2::Schema::Result::Report

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw(InflateColumn::DateTime FilterColumn));

=head1 TABLE: C<report>

=cut

__PACKAGE__->table("reports");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

=head2 creator_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 pending

  data_type: 'tinyint'
  is_nullable: 0

=head2 active

  data_type: 'tinyint'
  is_nullable: 0

=head2 query

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "name",
  {data_type => "text", is_nullable => 0},
  "updated",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
  "creator_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "pending",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
  "active",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
  "query",
  {data_type => "text", default_value => '""', is_nullable => 0}
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 creator

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "creator", "Rebus2::Schema::Result::User",
  {"foreign.id"  => "self.creator_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 runs

Type: has_many

Related object: L<Rebus2::Schema::Result::ReportRun>

=cut

__PACKAGE__->has_many(
  "runs",
  "Rebus2::Schema::Result::ReportRun",
  {"foreign.report_id" => "self.id"},
  {cascade_copy        => 0, cascade_delete => 0},
);

=head2 last_run

Type: special case of 'runs'

Related object: L<Rebus2::Schema::Result::ReportRun>

=cut

sub last_run {
  my $self = shift;
  return $self->search_related('runs', undef, {rows => 1, order_by => {'-desc' => [qw(completed)]}})->single;
}

=head1 FILTERS

=head2 booleans

Related fields: active

=cut 

__PACKAGE__->filter_column(
  active => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
