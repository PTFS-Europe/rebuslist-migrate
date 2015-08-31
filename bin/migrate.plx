#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Rebus1::Schema;
use Rebus2::Schema;
use DBIx::Class::Tree::NestedSet;
use Authen::Passphrase::SaltedDigest;

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

    # Convert Password Hash
    my $ppr = Authen::Passphrase::SaltedDigest->new(
            algorithm => "MD5",
            hash_hex => $rl1_user->password
        );
    my $pass_string = $ppr->as_rfc2307;
    $rl2_user->store_column(password => $pass_string);
    $rl2_user->make_column_dirty(password);
    $rl2_user->update;

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

    # Get material
    my $rl1_material = $rebus1->resultset('Material')
      ->find( { material_id => $rl1_sequence->material_id } );

    # Map Material to CSL
    my $csl = mapCSL($rl1_material);

    my ( $owner, $owner_uuid );
    if ( defined($rl1_material->print_sysno) || defined($rl1_material->elec_sysno) ) {
        $owner = $config->{'connector'};
        $owner_uuid = $rl1_material->print_sysno;
        $owner_uuid //= $rl1_material->elec_sysno;

    } else {
        $owner = $config->{code};
        $owner = 1;
    }

    # Add material
    my $rl2_material = addMaterial(
        {
            in_stock => $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
            metadata => $csl,
            owner    => $owner,
            owner_uuid => $owner_uuid
        }
    );

    # Get rating
    my $rl1_rating = $rebus1->resultset('MaterialRating')
      ->find( { material_id => $rl1_sequence->material_id } );

    # Link material to list
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

    # Get material tags
    my $rl1_tagResults = $rebus1->resultset('TagLink')
      ->find( { material_id => $rl1_sequence->material_id } );

    # Get tag
    my $rl1_tag =
      $rebus1->resultset('Tag')->find( { tag_id => $rl1_tagResult->tag_id } );

    # Add tag
    my $rl2_tag = addTag( { text => $rl1_tag->tag } );

    # Link tag to material in list
    my $rl2_link_tag = $rebus2->resultset('MaterialTag')->create(
        {
            material => $rl2_material->id,
            tag      => $rl2_tag->id,
            list     => $rl2_list->id
        }
    );

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

    my @tagResults = $rebus2->resultset('Tag')->search( { text => $text } );

    unless (@tagResults) {
        my $new_tag = $rebus2->resultset('Tag')->create( { text => $text } );
        return $new_tag;
    }

    return $tagResults[0];
}

sub mapCSL {
    my $result = shift;
    my $csl;

    $csl->{'title'} = $result->title;
    $csl->{'author'} = [ { literal => $result->authors }, { literal => $result->secondary_authors } ];
    $csl->{'edition'} = $result->edition;
    $csl->{'volume'} = $result->volume;
    $csl->{'issue'} = $result->issue;
    $csl->{'publisher'} = $result->publisher;
    $csl->{'issued'} = { raw => $result->publication_date };
    $csl->{'publisher-place'} = $result->publication_place;
    $csl->{'note'} = $result->note;
    $csl->{'URL'} = $result->url;

    # Types: 1=Book, 2=Chapter, 3=Journal, 4=Article, 5=Scan, 7=Link, 9=Other, 10=eBook, 11=AV, 12=Note, 13=Private Note
    if ( $result->material_type_id == 1 ) {
        $csl->{'type'} = 'book';
        $csl->{'collection-title'} = $result->secondary_title;
        $csl->{'number-of-pages'} = $result->spage;
        $csl->{'ISBN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 2 ) {
        $csl->{'type'} = 'chapter';
        $csl->{'container-title'} = $result->secondary_title;
        $csl->{'page-first'} = $result->spage;
        $csl->{'number-of-pages'} = $result->epage - $result->spage;
        $csl->{'ISBN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 3 ) {
        $csl->{'type'} = 'journal'; #CUSTOM
        $csl->{'ISSN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 4 ) {
        $csl->{'type'} = 'article';
        $csl->{'container-title'} = $result->secondary_title;
        $csl->{'page-first'} = $result->spage;
        $csl->{'number-of-pages'} = $result->epage - $result->spage;
        $csl->{'ISSN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 5 ) {
        $csl->{'type'} = 'entry';
        $csl->{'container-title'} = $result->secondary_title;
        $csl->{'page-first'} = $result->spage;
        $csl->{'number-of-pages'} = $result->epage - $result->spage;
        $csl->{'ISBN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 7 ) {
        $csl->{'type'} = 'webpage';
        $csl->{'container-title'} = $result->secondary_title;
    }
    if ( $result->material_type_id == 9 ) {
        $csl->{'type'} = 'entry';
        $csl->{'container-title'} = $result->secondary_title;
        $csl->{'page-first'} = $result->spage;
        $csl->{'number-of-pages'} = $result->epage - $result->spage;
        $csl->{'ISBN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 10 ) {
        $csl->{'type'} = 'book';
        $csl->{'container-title'} = $result->secondary_title;
        $csl->{'number-of-pages'} = $result->spage
        $csl->{'ISBN'} = $result->print_control_no //= $result->elec_control_no;
    }
    if ( $result->material_type_id == 11 ) {
        $csl->{'type'} = 'broadcast';
        $csl->{'collection-title'} = $result->secondary_title;
    }
    # 12=Note and 13=Private Note are handled prior to this

    return $csl;
}
