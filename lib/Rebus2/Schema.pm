use utf8;

package Rebus2::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

our $VERSION = 60;

__PACKAGE__->load_namespaces(default_resultset_class => 'ResultSet');

1;
