use utf8;

package Rebus2::Schema::Result::Request;

=head1 NAME

Rebus2::Schema::Result::Request

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

=head1 TABLE: C<request>

=cut

__PACKAGE__->table("requests");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 requester_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 assignee_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 medium

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 audience

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 status

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

=head2 created

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0
  retrieve_on_insert: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "requester_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "assignee_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 1,},
  "material_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "list_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 1,},
  "medium",
  {data_type => "text", is_nullable => 0,},
  "audience",
  {data_type => "text", is_nullable => 0,},
  "status",
  {data_type => "text", is_nullable => 0,},
  "updated",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
  "created",
  {
    data_type                 => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value             => \"current_timestamp",
    is_nullable               => 0,
    retrieve_on_insert        => 1
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assignee

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "assignee", "Rebus2::Schema::Result::User",
  {id            => "assignee_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 requester

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "requester", "Rebus2::Schema::Result::User",
  {id            => "requester_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 material

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Material>

=cut

__PACKAGE__->belongs_to(
  "material",
  "Rebus2::Schema::Result::Material",
  {id            => "material_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 scan

Type: might_have

Related object: L<Rebus2::Schema::Result::Scan>

=cut

__PACKAGE__->might_have(scan => 'Rebus2::Schema::Result::Scan', {'foreign.request_id' => 'self.id'},);

=head2 purchase

Type: might_have

Related object: L<Rebus2::Schema::Result::Purchase>

=cut

__PACKAGE__->might_have(purchase => 'Rebus2::Schema::Result::Purchase', {'foreign.request_id' => 'self.id'},);

1;
