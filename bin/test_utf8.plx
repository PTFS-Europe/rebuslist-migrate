#!/usr/bin/env perl
use utf8;

use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Carp;
use Encode qw{decode encode from_to is_utf8};

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
  "$config->{'username'}", "$config->{'password'}");

my $rl1_listResult = $rebus1->resultset('Material')->find({material_id => 18017});
my $expanded       = {$rl1_listResult->get_columns};
my $utf8           = is_utf8 $expanded->{'title'};
say $utf8;
my $title = $expanded->{'title'};
say $title;
my $bool = is_utf8 $title;
say $bool;
my $new_title = decode('iso-8859-1', $title);
say "after decode: ";
say $new_title;
my $bool2 = is_utf8 $new_title;
say "is utf8: " . $bool2;

from_to($title, 'iso-8859-1', 'utf8');
my $bool3 = is_utf8 $title;
say "after from_to: ";
say $title;
say "is utf8: " . $bool3;

#for my $key (keys %{$expanded}) {
#    from_to($data, "iso-8859-1", "utf8"); #1
#    $data = decode("iso-8859-1", $data);  #2
#    #from_to($expanded->{$key}, "iso-8859-1", "utf8");
#    from_to($expanded->{$key}, "utf8", "iso-8859-1");
#}
#say $expanded->{'title'};
