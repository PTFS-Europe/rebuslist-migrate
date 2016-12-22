#!/home/rebus/.plenv/versions/5.20.2/bin/perl5.20.2

use local::lib ("/home/rebus/.plenv/versions/5.20.2", "/home/rebus/rebus-list/local");
BEGIN { unshift @INC, "/home/rebus/rebus-list/lib" }

use Rebus::Schema;
use DateTime;
use Getopt::Long;
use YAML::XS qw/LoadFile/;

my ($configfile) = (undef);
GetOptions( 'c|config=s' => \$configfile, );

# Load config
my $config = LoadFile($configfile)
  || croak "Cannot load config file: " . $! . "\n";

my $rebus = Rebus2::Schema->connect(
"dbi:Pg:database=$config->{'database2'};host=$config->{'host2'};port=$config->{'port2'}",
    "$config->{'username2'}",
    "$config->{'password2'}",
    { 'pg_enable_utf8' => 1, 'on_connect_do' => ["SET search_path TO list"] }
);

my $listResults = $rebus->resultset('List')->search({level => 0, id => {'!=' => 0}});

for my $listResult ($listResults->all) {
  my $parent_validity_start = {$listResult->level => $listResult->validity_start};
  my $parent_validity_end = {$listResult->level => $listResult->validity_end};
  for my $descendantResult ($listResult->descendants->all) {

    # Set Hash for next cycle
    $parent_validity_start->{$descendantResult->level} = $descendantResult->validity_start;
    $parent_validity_end->{$descendantResult->level} = $descendantResult->validity_end;

    # Fix database value
    my $parent_level = $descendantResult->level - 1;
    if (DateTime->compare($descendantResult->validity_start, $parent_validity_start->{$parent_level}) == 0) {
      $descendantResult->update({validity_start => undef});
    }
    elsif (DateTime->compare($descendantResult->validity_start, $parent_validity_start->{$parent_level}) == -1) {
      print "Oh Noes! Start: " . $descendantResult->validity_start . " lt $parent_validity_start->{$parent_level}\n";
    }
    
    if (DateTime->compare($descendantResult->validity_end, $parent_validity_end->{$parent_level}) == 0) {
      $descendantResult->update({validity_end => undef});
    }
    elsif (DateTime->compare($descendantResult->validity_end, $parent_validity_end->{$parent_level}) == 1) {
      print "Oh Noes! End: " . $descendantResult->validity_end . " gt $parent_validity_end->{$parent_level}\n";
    }
  }
}
