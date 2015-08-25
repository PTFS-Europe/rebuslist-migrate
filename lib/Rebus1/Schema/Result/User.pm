use utf8;
package Rebus1::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Rebus1::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 512

=head2 login

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 password

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 type_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 512 },
  "login",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "password",
  { data_type => "char", is_nullable => 1, size => 32 },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "type_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-05-21 18:17:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t+sAaXoVWDc4rTV4AFs1Jg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
