#!/usr/bin/env perl

use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use utf8;                          # so literals and identifiers can be in UTF-8
use v5.12;                         # or later to get "unicode_strings" feature
use strict;                        # quote strings, declare variables
use warnings;                      # on by default
use warnings qw(FATAL utf8);       # fatalize encoding glitches
use open qw(:std :utf8);           # undeclared streams in UTF-8
use charnames qw(:full :short);    # unneeded in v5.16

use Carp;
use Encode qw{decode encode from_to is_utf8 encode_utf8};

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
use Encode::Guess;
use Encoding::FixLatin qw(fix_latin);

my ($configfile) = (undef);
GetOptions('c|config=s' => \$configfile,);

# Load config
my $config = LoadFile($configfile) || croak "Cannot load config file: " . $! . "\n";

my $rebus1
  = Rebus1::Schema->connect("dbi:mysql:database=$config->{'database'};host=$config->{'host'};port=$config->{'port'}",
  "$config->{'username'}", "$config->{'password'}");

my $rebus2
  = Rebus2::Schema->connect("dbi:Pg:database=$config->{'database2'};host=$config->{'host2'};port=$config->{'port2'}",
  "$config->{'username2'}", "$config->{'password2'}",
  {'pg_enable_utf8' => 1, 'on_connect_do' => ["SET search_path TO list"]});

my $rl2_listResult = $rebus2->resultset('List')->find({id => 1598});
my $rl1_listResult = $rebus1->resultset('Material')->find({material_id => 18017});
my $title = $rl1_listResult->title;
my $fixed = fix_latin($title);
my $string = decode("iso-8859-1", $title);
my $string2 = encode_utf8($title);
utf8::upgrade($title);
my $decoder = Encode::Guess->guess($string2);
use Data::Printer;
p $decoder;
p $title;
p $fixed;

$rl2_listResult->update({name => $fixed});

#say $title;
#my $bool = is_utf8 $title;
#say "without processing: " . $bool;
#print "\n\n";
#
#my $title2 = $title;
#my $bytes2 = utf8::upgrade($title2);
#say $title2;
#my $bool6 = is_utf8 $title2;
#say "after upgrade: ".$bool6;
#print "\n\n";
#
#
#my $new_title = decode('ISO-8859-16', $title);
#say $new_title;
#my $bool2 = is_utf8 $new_title;
#say "after decode: " . $bool2;
#print "\n\n";
#
#my $new_title2 = encode('UTF-8', $new_title);
#say $new_title2;
#my $bool4 = is_utf8 $new_title2;
#say "after decode then encode: " . $bool4;
#print "\n\n";
#
#my $bytes = utf8::upgrade($new_title);
#say $new_title;
#my $bool5 = is_utf8 $new_title;
#say "after decode then upgrade: ".$bool5;
#print "\n\n";
#
#from_to($title, 'ISO-8859-16', 'utf8');
#say $title;
#my $bool3 = is_utf8 $title;
#say "after from_to: " . $bool3;
#print "\n\n";

#for my $key (keys %{$expanded}) {
#    from_to($data, "ISO-8859-16", "utf8"); #1
#    $data = decode("ISO-8859-16", $data);  #2
#    #from_to($expanded->{$key}, "ISO-8859-16", "utf8");
#    from_to($expanded->{$key}, "utf8", "ISO-8859-16");
#}
#say $expanded->{'title'};
