#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Carp;
use Rebus1::Schema;
use Rebus2::Schema;
use DBIx::Class::Tree::NestedSet;
use Authen::Passphrase::SaltedDigest;
use List::Util qw/any/;
use Scalar::Util 'looks_like_number';
use DateTime;
use DateTime::Duration;
use HTML::Entities qw/decode_entities/;
use Term::ProgressBar 2.00;

use Mojo::JSON qw(decode_json encode_json);
use JSON::Validator;
use Data::Printer colored => 1;

use Getopt::Long;
use YAML::XS qw/LoadFile/;

my ($configfile) = (undef);
GetOptions('c|config=s' => \$configfile,);

# Load config
my $config = LoadFile($configfile) || croak "Cannot load config file: " . $! . "\n";

my $rebus1
  = Rebus1::Schema->connect("dbi:mysql:database=$config->{'database'};host=$config->{'host'};port=$config->{'port'}",
  "$config->{'username'}", "$config->{'password'}", {});


my $rl1_listResult = $rebus1->resultset('Material')->find({material_id => 18017});
my $expanded = {$rl1_listResult->get_columns};
p($expanded);
