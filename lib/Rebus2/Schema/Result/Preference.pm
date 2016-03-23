use utf8;

package Rebus2::Schema::Result::Preference;

=head1 NAME

Rebus2::Schema::Result::Preference

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

=head1 TABLE: C<preferences>

=cut

__PACKAGE__->table("preferences");

=head1 ACCESSORS

=head2 code

  data_type: 'text'
  is_nullable: 0

=head2 content

  data_type: 'text'
  is_nullable: 1
  default_value: '""'

=head2 group

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 json_schema

  data_type: 'jsonb'
  is_nullable: 0

=head2 json_form

  data_type: 'jsonb'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "code",
  {data_type => "text", is_nullable => 0},
  "content",
  {
    data_type          => "text",
    default_value      => '""',
    is_nullable        => 0,
    serializer_class   => "JSON",
    serializer_options => {allow_nonref => 1, utf8 => 1}
  },
  "group",
  {data_type => "integer", default_value => 1, is_nullable => 1,},
  "json_schema",
  {data_type => "jsonb", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}},
  "json_form",
  {data_type => "jsonb", is_nullable => 0, serializer_class => "JSON", serializer_options => {utf8 => 1}},
);

=head1 PRIMARY KEY

=over 4

=item * L</code>

=back

=cut

__PACKAGE__->set_primary_key("code");

1;
