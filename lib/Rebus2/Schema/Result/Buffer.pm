use utf8;

package Rebus2::Schema::Result::Buffer;

=head1 NAME

Rebus2::Schema::Result::Buffer

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw(InflateColumn::DateTime InflateColumn::Serializer FilterColumn));

=head1 TABLE: C<buffers>

=cut

__PACKAGE__->table("buffers");

=head1 ACCESSORS

=head2 list_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

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

=head2 version

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 model

  data_type: 'jsonb'
  is_nullable: 0

=head2 moderating

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 unlocked

  data_type: 'smallint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "user_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
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
  "version",
  {data_type => "integer", default_value => 0, is_nullable => 0,},
  "model",
  {data_type => "JSONB", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "moderating",
  {data_type => "smallint", default_value => 0, is_nullable => 0},
  "unlocked",
  {data_type => "smallint", default_value => 1, is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</list_id>

=back

=cut

__PACKAGE__->set_primary_key("list_id");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list", "Rebus2::Schema::Result::List",
  {id            => "list_id"},
  {is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT"},
);

=head2 user

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user", "Rebus2::Schema::Result::User",
  {id            => "user_id"},
  {is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT"},
);

=head2 list_user_roles

Type: has_many

Related object: L<Rebus2::Schema::Result::ListUserRole>

=cut

__PACKAGE__->has_many(
  "list_user_roles", "Rebus2::Schema::Result::ListUserRole",
  {"foreign.list_id" => "self.list_id"}, {cascade_copy => 0, cascade_delete => 0},
);


__PACKAGE__->filter_column(
  moderating => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

__PACKAGE__->filter_column(
  unlocked => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
