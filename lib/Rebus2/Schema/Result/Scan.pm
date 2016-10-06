use utf8;

package Rebus2::Schema::Result::Scan;

=head1 NAME

Rebus2::Schema::Result::Scan

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<scans>

=cut

__PACKAGE__->table("scans");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 material_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 request_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 location

  data_type: 'text'
  is_foreign_key: 0
  is_nullable: 1

=head2 uri

  data_type: 'text'
  is_foreign_key: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",          {data_type => "integer", is_auto_increment => 1, is_nullable => 0,},
  "material_id", {data_type => "integer", is_foreign_key    => 1, is_nullable => 0,},
  "request_id",  {data_type => "integer", is_foreign_key    => 1, is_nullable => 0,},
  "location",    {data_type => "text",    is_nullable       => 1,},
  "uri",         {data_type => "text",    is_nullable       => 1,},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 request

Type: belongs_to

Related object: L<Rebus2::Schema::Result::Request>

=cut

__PACKAGE__->belongs_to(
  "request",
  "Rebus2::Schema::Result::Request",
  {id            => "request_id"},
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

1;
