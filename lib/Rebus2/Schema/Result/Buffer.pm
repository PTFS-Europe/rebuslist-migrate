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

__PACKAGE__->load_components( qw(InflateColumn::DateTime InflateColumn::Serializer FilterColumn) );

=head1 TABLE: C<buffer>

=cut

__PACKAGE__->table("buffers");

=head1 ACCESSORS

=head2 list

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 version

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 model

  data_type: 'mediumtext'
  is_nullable: 0

=head2 moderating

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 unlocked

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "list",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "version",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "model",
  { data_type => "mediumtext", is_nullable => 0, serializer_class => "JSON", serializer_options => { canonical => 1, utf8 => 1 } },
  "moderating",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "unlocked",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</list>

=back

=cut

__PACKAGE__->set_primary_key("list");

=head1 RELATIONS

=head2 list

Type: belongs_to

Related object: L<Rebus2::Schema::Result::List>

=cut

__PACKAGE__->belongs_to(
  "list",
  "Rebus2::Schema::Result::List",
  { id => "list" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 user

Type: belongs_to

Related object: L<Rebus2::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Rebus2::Schema::Result::User",
  { id => "user" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


__PACKAGE__->filter_column(
    moderating => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

__PACKAGE__->filter_column(
    unlocked => {
        filter_to_storage   => sub { $_[1] ? 1  : 0 },
        filter_from_storage => sub { $_[1] ? \1 : \0 }
    }
);

1;
