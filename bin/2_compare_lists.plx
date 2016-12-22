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
  "$config->{'username'}", "$config->{'password'}");

my $rebus2
  = Rebus2::Schema->connect("dbi:Pg:database=$config->{'database2'};host=$config->{'host2'};port=$config->{'port2'}",
  "$config->{'username2'}", "$config->{'password2'}",
  {'pg_enable_utf8' => 1, 'on_connect_do' => ["SET search_path TO list"]});

my @rl1_sequenceResults
  = $rebus1->resultset('Sequence')->search(undef, {order_by => {-asc => [qw/list_id rank/]}})->all;

my $results;
my $last_list;
for my $rl1_sequence (@rl1_sequenceResults) {
  if (!defined($last_list) || ($last_list != $rl1_sequence->list_id)) {
    $results->{$rl1_sequence->list_id}->{'public_notes'}  = 0;
    $results->{$rl1_sequence->list_id}->{'private_notes'} = 0;
    $results->{$rl1_sequence->list_id}->{'rl1_materials'} = 0;
    $results->{$rl1_sequence->list_id}->{'rl2_materials'}
      = $rebus2->resultset('ListMaterial')->search({list_id => $rl1_sequence->list_id})->count;

    if (defined($last_list)) {
      $results->{$last_list}->{'match'}
        = ($results->{$last_list}->{'rl1_materials'} - $results->{$last_list}->{'rl2_materials'}) ? 0 : 1;
    }

    $last_list = $rl1_sequence->list_id;
  }

  # Get material
  my $rl1_material = $rebus1->resultset('Material')->find({material_id => $rl1_sequence->material_id});

  if (defined($rl1_material)) {
    if ($rl1_material->material_type_id == 12) {
      $results->{$rl1_sequence->list_id}->{'public_notes'}++;
    }
    elsif ($rl1_material->material_type_id == 13) {
      $results->{$rl1_sequence->list_id}->{'private_notes'}++;
    }
    else {
      $results->{$rl1_sequence->list_id}->{'rl1_materials'}++;
    }
  }
}

# Calculate Last comparison
$results->{$last_list}->{'match'}
  = ($results->{$last_list}->{'rl1_materials'} - $results->{$last_list}->{'rl2_materials'}) ? 0 : 1;

print "list, match, rl1_materials, rl2_materials, public_notes, private_notes\n";
for my $list (keys %{$results}) {
  print "$list, "
    . "$results->{$list}->{'match'}, "
    . "$results->{$list}->{'rl1_materials'}, "
    . "$results->{$list}->{'rl2_materials'}, "
    . "$results->{$list}->{'public_notes'}, "
    . "$results->{$list}->{'private_notes'}\n";
}
