package Rebus::Schema::ResultSet::User;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 OVERLOADS

=head2 search

We have overloaded the search function such that unless explicitely asked for, 
the public user (id = 0) will never be returned.

=cut

#FIXME: This is apparently a bad idea, and as such I've ended up calling != 0 all over the codebase instead.
# I still wonder if this overload may yeild cleaner code upstream (though it needs some work to account for all
# things that can be passed to search as $cond.
#sub search {
#  my ($class, $cond, $attrs) = @_;
#  use Data::Dumper;
#  warn Dumper($cond);
#
#  $cond->{id} = { '!=' => 0 } unless defined $cond->{id};
#
#  return $class->next::method($cond, $attrs);
#}
#
1;
