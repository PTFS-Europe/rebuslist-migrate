#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Rebus1::Schema;
use Rebus2::Schema;
use Getopt::Long;
use YAML::XS qw/LoadFile/;

my ( $configfile ) = ( undef );
GetOption(
    'c|config=s' => \$configfile,
);

# Load config
my $config = LoadFile($configfile) || croak "Cannot load config file: $!\n";

my $rebus1 =
  Rebus1::Schema->connect( "dbi:mysql:database=$database;host=$host;port=$port",
    "$username", "$password" );

my $rebus2 =
  Rebus2::Schema->connect( "dbi:mysql:database=$database;host=$host;port=$port",
    "$username", "$password" );


say "Beggining migration...";
say "Importing organisational units";
my @rl1_unitResults = $rebus1->resultset(OrgUnits)->search( undef, { order_by => { -asc => [qw/parent org_unit_id/] } } )->all;
my $unit_links;
while my $rl1_unit ( @rl1_unitResults ) {
    my $rl2_unit = $rebus2->resultset(List)->create
}

while ( my $row = $csv->getline_hr($fh) ) {

    # Count for progress
    $line++;

    # Skip empty lines
    $csv->is_missing(0) and next;    # This was an empty line

    # Build list hash
    my $list = {
        org_unit_id       => '9',
        list_name         => $row->{'LIST_NAME'},
        year              => $row->{'YEAR'},
        published_yn      => 'n',
        no_students       => '0',
        ratio_books       => '0',
        ratio_students    => '0',
        course_identifier => $row->{'COURSE_IDENTIFIER'}
    };

    # Add lists to rebus
    my $listID = addList($list);
}
close $fh;
say "Lists loaded...";

sub addList {
    my $list = shift;

    # Check if list already exists
    my @lists =
      $rebus->resultset('List')
      ->search(
        { course_identifier => $list->{'course'}, year => $list->{'year'} } );

    # Add list if it does not already exist
    unless (@lists) {
        my $new_list = $rebus->resultset('List')->create(
            {
                org_unit_id       => $list->{org_unit_id},
                year              => $list->{year},
                list_name         => "$list->{course_identifier} - $list->{list_name}",
                published_yn      => $list->{published_yn},
                no_students       => $list->{no_students},
                ratio_books       => $list->{ratio_books},
                ratio_students    => $list->{ratio_students},
                last_updated      => time(),
                creation_date     => time(),
                course_identifier => $list->{course_identifier}
            }
        );
        my $listID = $new_list->list_id;    #Check This
        return $listID;
    }

    # Update list if it already exists
    else {
        my $listID = $lists[0]->list_id;
        my $name   = "$list->{course_identifier} - $list->{list_name}";

        # Update object
        $lists[0]->year("$list->{year}");
        $lists[0]->list_name("$name");
        $lists[0]->last_updated( time() );

        # Commit to database
        $lists[0]->update if $lists[0]->is_changed;

        return $listID;
    }
}
