use utf8;

package Rebus2::Schema::Result::Buffermessage;

=head1 NAME

Rebus2::Schema::Result::Buffermessage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::FilterColumn>

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components(qw( InflateColumn::DateTime FilterColumn ));

=head1 TABLE: C<buffermessage>

=cut

__PACKAGE__->table("buffermessages");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 buffer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 added

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 text

  data_type: 'text'
  is_nullable: 0

=head2 important

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "buffer_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "user_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0,},
  "added",
  {data_type => "timestamp", datetime_undef_if_invalid => 1, default_value => \"current_timestamp", is_nullable => 0},
  "text",
  {data_type => "text", is_nullable => 0},
  "important",
  {data_type => "tinyint", default_value => 0, is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 buffer

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Buffer>

=cut

__PACKAGE__->belongs_to(
  "buffer",
  "Rebus2::Schema::Result::Buffer",
  {"foreign.list_id" => "self.buffer_id"},
  {is_deferrable     => 1, on_delete => "CASCADE"},
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

=head1 FILTERED COLUMNS

=head2 important

Type: Boolean

=cut

__PACKAGE__->filter_column(
  important => {
    filter_to_storage => sub { $_[1] ? 1 : 0 },
    filter_from_storage => sub { $_[1] ? Mojo::JSON->true : Mojo::JSON->false }
  }
);

1;
