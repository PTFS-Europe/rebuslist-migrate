#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Rebus1::Schema;
use Rebus2::Schema;
use DBIx::Class::Tree::NestedSet;

use Getopt::Long;
use YAML::XS qw/LoadFile/;

my ($configfile) = (undef);
GetOption( 'c|config=s' => \$configfile, );

# Load config
my $config = LoadFile($configfile) || croak "Cannot load config file: $!\n";

my $rebus1 =
  Rebus1::Schema->connect( "dbi:mysql:database=$database;host=$host;port=$port",
    "$username", "$password" );

my $rebus2 =
  Rebus2::Schema->connect( "dbi:mysql:database=$database;host=$host;port=$port",
    "$username", "$password" );

say "Beggining migration...";

# OrgUnit, List
say "Importing lists";
my @rl1_unitResults = $rebus1->resultset('OrgUnit')
  ->search( undef, { order_by => { -asc => [qw/parent org_unit_id/] } } )->all;
my $unit_links;
my $list_links;
for my $rl1_unit (@rl1_unitResults) {

    # Add org units
    if ( $rl1_unit->parent == 0 ) {

        # Find next root
        my $rootResult =
          $rebus2->resultset('List')
          ->search( {}, { order_by => 'root_id', rows => '1' } )->single;
        $rootID = $rootResult->root_id;
        $rootID = $rootID - 1;

        # Add new tree
        my $rl2_unit = $rebus2->resultset('List')->create(
            {
                name      => $rl1_unit->name,
                source    => $config->{code},
                published => 1,
                root_id   => $rootID
            }
        );

        $rl2_unit->update(
            {
                'source_uuid' => $config->{code} . "-" . $rl2_unit->id
            }
        );

        # Add to lookup table
        $unit_links{ $rl1_unit->org_unit_id } = $rl2_unit->id;
        $rl2_unit->discard_changes;
    }
    else {
        # Add rightmost child to existing node
        my $rl2_unit = $rebus2->resultset('List')->create_rightmost_child(
            {
                name      => $rl1_unit->name,
                source    => $config->{code},
                published => 1,
            }
        );

        $rl2_unit->update(
            {
                'source_uuid' => $config->{code} . "-" . $rl2_unit->id
            }
        );

        # Add to lookup table
        $unit_links{ $rl1_unit->org_unit_id } = $rl2_unit->id;
        $rl2_unit->discard_changes;
    }

    # Add lists
    my @rl1_listResults = $rebus1->resultset('List')->search(
        { org_unit_id => $rl1_unit->org_unit_id },
        { order_by    => { -asc => [qw/list_name year/] } }
    )->all;

    for my $rl1_list (@rl2_listResults) {

        # Add child list
        my $rl2_list = $rl2_unit->create_rightmost_child(
            {
                name              => $rl1_list->list_name,
                no_students       => $rl1->no_students,
                ratio_books       => $rl1->ratio_books,
                ratio_students    => $rl1->ration_students,
                updated           => $rl1->last_updated,
                created           => $rl1->creation_date,
                source            => $config->{code},
                course_identifier => $rl1->course_identifier,
                published         => $rl1->published_yn eq 'y' ? 1 : 0
            }
        );

        $rl2_list->update(
            {
                'source_uuid' => $config->{code} . "-" . $rl2_list->id
            }
        );

        # Add to lookup table
        $list_links{ $rl1_list->list_id } = $rl2_list->id;
        $rl2_list->discard_changes;
        $rl2_unit->discard_changes;
    }
}
say "Lists loaded...\n";

# User, UserType
say "Importing users...";
my $user_links;
my @rl1_userResults = $rebus1->resultset('User')
  ->search( undef, { order_by => { -asc => [qw/type_id name/] } } )->all;

my $role_map = {
    1 => 30,
    2 => 20,
    3 => 10,
    4 => 40
};

for my $rl1_user (@rl1_userResults) {

    # Add user
    my $rl2_user = $rebus2->resultset('User')->create(
        {
            name        => $rl1_user->name,
            system_role => $role_map->{ $rl1->type_id },
            login       => $rl1_user->login,
            password    => $rl1_user->password,
            email       => $rl1_user->email_address,
            active      => 1
        }
    );

    # Add to lookup table
    $user_links{ $rl1_user->user_id } = $rl2_user->id;
}
say "Users loaded...\n";

# Erbo
say "Importing categories...";
my $erbo_links;
my @rl1_erboResults = $rebus1->resultset('Erbo')
  ->search( undef, { order_by => { -asc => [qw/rank erbo/] } } )->all;

my $rank = 0;
for my $rl1_erbo (@rl1_erboResults) {

    # Add category
    my $rl2_erbo = $rebus2->resultset('Category')->create(
        {
            category => $rl1_erbo->erbo,
            rank     => $rank++,
            source   => $config->{code}
        }
    );
    $rl2_erbo->update(
        {
            'source_uuid' => $config->{code} . "-" . $rl2_erbo->id
        }
    );

    # Add to lookup table
    $erbo_links{ $rl1_erbo->erbo_id } = $rl2_erbo->id;
}
say "Categories loaded...\n";

# Sequence, Material, MaterialType, MaterialRating, MaterialLabel, Tag, TagLink, MetadataSource
say "Importing materials...";
my @rl1_sequenceResults = $rebus1->resultset('Sequence')
  ->search( undef, { order_by => { -asc => [qw/list_id rank/] } } )->all;

for my $rl1_sequence (@rl1_sequenceResults) {

    my $rl1_material = $rebus1->resultset('Material')
      ->find( { material_id => $rl1_sequence->material_id } );

    my $rl2_material = addMaterial(
        {
            in_stock => $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
            metadata =>, #MAP MATERIAL HERE
            owner =>,    # Connector/User
            owner_uuid =>    # ConnnectorID/UserID
        }
    );

    my $rl1_rating = $rebus1->resultset('MaterialRating')
      ->find( { material_id => $rl1_sequence->material_id } );

    my $rl2_sequence = $rebus2->resultset('ListMaterial')->create(
        {
            list        => $list_links->{ $rl1_sequence->list },
            material    => $rl2_material->id,
            rank        => $rl1_sequence->rank,
            dislikes    => $rl1_rating->not_likes,
            likes       => $rl1_rating->likes,
            category    => $erbo_links->{ $rl1_material->erbo_id },
            source      => $config->{code},
            source_uuid => $config->{code} . '-' . $rl2_material->id
        }
    );

    my $rl1_tagResults = $rebus1->resultset('TagLink')
      ->find( { material_id => $rl1_sequence->material_id } );

    my $rl1_tag =
      $rebus1->resultset('Tag')->find( { tag_id => $rl1_tagResult->tag_id } );

    my $rl2_tag = addTag( { text => $rl1_tag->tag } );

    # Link Tag HERE

}
say "Materials loaded...\n";

# Permission, UserListPermission, UserOrgUnitPermission
say "Importing permissions...";
say "Permissions loaded...\n";

sub addMaterial {

}

sub addTag {
    my $text = shift;

    $text = lc($text);
    $text =~ s/\s/-/g;

    my @tagResults = $rebus2->resultset('Tag')->search({ text => $text });

    unless (@tagResults) {
        my $new_tag = $rebus2->resultset('Tag')->create({ text => $text });
        return $new_tag;
    }

    return $tagResults[0];
}
