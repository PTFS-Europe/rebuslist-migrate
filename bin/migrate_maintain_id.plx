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
use DateTime;
use DateTime::Duration;
use Term::ProgressBar 2.00;

use Mojo::JSON qw(decode_json encode_json);
use Data::Printer colored => 1;

use Getopt::Long;
use YAML::XS qw/LoadFile/;

my ($configfile) = (undef);
GetOptions( 'c|config=s' => \$configfile, );

# Load config
my $config = LoadFile($configfile)
  || croak "Cannot load config file: " . $! . "\n";

my $rebus1 = Rebus1::Schema->connect(
"dbi:mysql:database=$config->{'database'};host=$config->{'host'};port=$config->{'port'}",
    "$config->{'username'}", "$config->{'password'}"
);

my $rebus2 = Rebus2::Schema->connect(
"dbi:Pg:database=$config->{'database2'};host=$config->{'host2'};port=$config->{'port2'}",
    "$config->{'username2'}",
    "$config->{'password2'}",
    { 'pg_enable_utf8' => 1, 'on_connect_do' => ["SET search_path TO list"] }
);

say "Beggining migration...";
my $dt    = DateTime->now;
my $start = DateTime->new(
    year   => 2016,
    month  => 9,
    day    => 1,
    hour   => 1,
    minute => 1,
    second => 1
);
my $end = DateTime->new(
    year   => 2016,
    month  => 8,
    day    => 31,
    hour   => 23,
    minute => 59,
    second => 59
);

# Add lists
my $total = $rebus1->resultset('List')->count;
my $list_progress =
  Term::ProgressBar->new( { name => "Importing lists", count => $total } );
$list_progress->minor(0);
my $next_update  = 0;
my $current_line = 0;

my $list_links;
my $parent_links;
my $rl1_listResults = $rebus1->resultset('List')
  ->search( undef, { order_by => { -asc => [qw/list_id/] } } );
for my $rl1_list ( $rl1_listResults->all ) {

    # Update Progress
    $current_line++;
    $next_update = $list_progress->update($current_line)
      if $current_line > $next_update;

    # Add child list
    my $rl2_list = $rebus2->resultset('List')->find_or_create(
        {
            id                  => $rl1_list->list_id,
            root_id             => 0,
            name                => $rl1_list->list_name,
            no_students         => $rl1_list->no_students,
            ratio_books         => $rl1_list->ratio_books,
            ratio_students      => $rl1_list->ratio_students,
            updated             => $dt,
            created             => $dt,
            source_id           => 1,
            course_identifier   => $rl1_list->course_identifier,
            published           => $rl1_list->published_yn eq 'y' ? 1 : 0,
            inherited_published => $rl1_list->published_yn eq 'y' ? 1 : 0,
            validity_start =>
              $start->set_year( $rl1_list->year )->subtract( years => 1 ),
            inherited_validity_start =>
              $start->set_year( $rl1_list->year )->subtract( years => 1 ),
            validity_end           => $end->set_year( $rl1_list->year ),
            inherited_validity_end => $end->set_year( $rl1_list->year )
        },
        { key => 'primary' }
    );

    $rl2_list->update(
        {
            'source_uuid' => $config->{'code'} . "-" . $rl2_list->id
        }
    );

    # Add to lookup table
    $list_links->{ $rl1_list->list_id } = $rl2_list->id;
    push @{ $parent_links->{ $rl1_list->org_unit_id } }, $rl2_list->id;
}

# Update Sequence
$rebus2->storage->dbh_do(
    sub {
        $_[1]->do(
            "SELECT SETVAL('lists_id_seq', COALESCE(MAX(id), 1) ) FROM lists;");
    }
);

# Add units
$start = $dt->clone->subtract( years => 5 );
$end = $dt->clone->add( years => 5 );
print "Importing units...\n";
my $current_level = 0;

recurse( [0], {} );

sub recurse {
    my $parents    = shift;
    my $unit_links = shift;

    my @rl1_unitResults =
      $rebus1->resultset('OrgUnit')->search( { parent => $parents },
        { order_by => { -asc => [qw/parent org_unit_id/] } } )->all;

    if (@rl1_unitResults) {
        my $new_parents;

        for my $rl1_unit (@rl1_unitResults) {

            my $rl2_unit;
            if ( $rl1_unit->parent == 0 ) {

                # Find next root
                my $rootResult =
                  $rebus2->resultset('List')
                  ->search( {}, { order_by => 'root_id', rows => '1' } )
                  ->single;
                my $rootID;
                if ( defined($rootResult) ) {
                    $rootID = $rootResult->root_id;
                }
                else {
                    $rootID = 0;
                }
                $rootID = $rootID - 1;

                # Add new tree
                $rl2_unit = $rebus2->resultset('List')->create(
                    {
                        name                     => $rl1_unit->name,
                        source_id                => 1,
                        published                => 1,
                        inherited_published      => 1,
                        root_id                  => $rootID,
                        validity_start           => $start,
                        inherited_validity_start => $start,
                        validity_end             => $end,
                        inherited_validity_end   => $end
                    }
                );

                $rl2_unit->update(
                    {
                        'source_uuid' => $config->{'code'} . "-"
                          . $rl2_unit->id
                    }
                );

                # Add to lookup table
                $unit_links->{ $rl1_unit->org_unit_id } = $rl2_unit->id;
                push @{$new_parents}, $rl1_unit->org_unit_id
                  unless any { $_ == $rl1_unit->org_unit_id } @{$new_parents};
                $rl2_unit->discard_changes;
            }
            else {
                # Get existing parent
                my $parentResult = $rebus2->resultset('List')
                  ->find( { id => $unit_links->{ $rl1_unit->parent } } );

                # Add rightmost child to existing node
                $rl2_unit = $parentResult->create_rightmost_child(
                    {
                        name                     => $rl1_unit->name,
                        source                   => 1,
                        published                => 1,
                        inherited_published      => 1,
                        validity_start           => $start,
                        inherited_validity_start => $start,
                        validity_end             => $end,
                        inherited_validity_end   => $end

                    }
                );

                $rl2_unit->update(
                    {
                        'source_uuid' => $config->{'code'} . "-"
                          . $rl2_unit->id
                    }
                );

                # Add to lookup table
                $unit_links->{ $rl1_unit->org_unit_id } = $rl2_unit->id;
                push @{$new_parents}, $rl1_unit->org_unit_id
                  unless any { $_ == $rl1_unit->org_unit_id } @{$new_parents};
                $rl2_unit->discard_changes;
            }

            # Add lists
            $parent_links->{ $rl1_unit->org_unit_id } ||= [];
            my @rl2_listResults = $rebus2->resultset('List')->search(
                {
                    id => { '-in' => $parent_links->{ $rl1_unit->org_unit_id } }
                },
                { order_by => { -asc => [qw/id/] } }
            )->all;

            for my $rl2_list (@rl2_listResults) {

                unless ( $rl2_list->name eq 'Hidden List' ) {

                    # Attach list
                    $rl2_unit->attach_rightmost_child($rl2_list);

                    $rl2_list->discard_changes;
                    $rl2_unit->discard_changes;
                }
            }
        }
        recurse( $new_parents, $unit_links );
    }
    else {
        return $unit_links;
    }
}

# User, UserType
$total = $rebus1->resultset('User')->count;
my $user_progress =
  Term::ProgressBar->new( { name => "Importing Users", count => $total } );
$user_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my $user_links;
my @rl1_userResults = $rebus1->resultset('User')
  ->search( undef, { order_by => { -asc => [qw/type_id name/] } } )->all;

my $role_map = {
    1 => 'librarian',
    2 => 'staff',
    3 => 'public',
    4 => 'admin'
};

for my $rl1_user (@rl1_userResults) {

    # Update Progress
    $current_line++;
    $next_update = $user_progress->update($current_line)
      if $current_line > $next_update;

    unless ( defined( $rl1_user->password ) ) {
        $rl1_user->password('38a4eae20c7e4de6560116e722229e50');
    }

    # Add user
    my $system_role =
      defined( $role_map->{ $rl1_user->type_id } )
      ? $role_map->{ $rl1_user->type_id }
      : 'public';
    my $rl2_user = $rebus2->resultset('User')->find_or_create(
        {
            name        => $rl1_user->name,
            system_role => { name => $system_role },
            login       => $rl1_user->login,
            password    => $rl1_user->password,
            email       => $rl1_user->email_address,
            active      => 1
        }
    );

    # Convert Password Hash
    my $ppr = Authen::Passphrase::SaltedDigest->new(
        algorithm => "MD5",
        hash_hex  => $rl1_user->password
    );
    my $pass_string = $ppr->as_rfc2307;
    $rl2_user->store_column( password => $pass_string );
    $rl2_user->make_column_dirty('password');
    $rl2_user->update;

    # Add to lookup table
    $user_links->{ $rl1_user->user_id } = $rl2_user->id;
}
say "Users loaded...\n";

# Erbo
$total = $rebus1->resultset('Erbo')->count;
my $category_progress =
  Term::ProgressBar->new( { name => "Importing Categories", count => $total } );
$category_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my $erbo_links;
my @rl1_erboResults = $rebus1->resultset('Erbo')
  ->search( undef, { order_by => { -asc => [qw/rank erbo/] } } )->all;

my $rank = 0;
$rebus2->resultset('Category')->delete;
for my $rl1_erbo (@rl1_erboResults) {

    # Update Progress
    $current_line++;
    $next_update = $category_progress->update($current_line)
      if $current_line > $next_update;

    # Add category
    my $rl2_erbo = $rebus2->resultset('Category')->create(
        {
            category  => $rl1_erbo->erbo,
            rank      => $rank++,
            source_id => 1
        }
    );
    $rl2_erbo->update(
        {
            'source_uuid' => $config->{'code'} . "-" . $rl2_erbo->id
        }
    );

    # Add to lookup table
    $erbo_links->{ $rl1_erbo->erbo_id } = $rl2_erbo->id;
}

# Update preference table
my $rl2_categoriesResult =
  $rebus2->resultset('Category')->search( undef, { order_by => 'rank' } );
my @rl2_categoriesArray = $rl2_categoriesResult->get_column('category')->all;
my $rl2_categories_json = encode_json \@rl2_categoriesArray;
my $rl2_preferenceResult =
  $rebus2->resultset('Preference')->find( { code => 'categories' } );
$rl2_preferenceResult->update( { content => $rl2_categories_json } );
say "Categories loaded...\n";

# Sequence, Material, MaterialType, MaterialRating, MaterialLabel, Tag, TagLink, MetadataSource
$total = $rebus1->resultset('Sequence')->count;
my $material_progress =
  Term::ProgressBar->new( { name => "Importing Materials", count => $total } );
$material_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my @rl1_sequenceResults = $rebus1->resultset('Sequence')
  ->search( undef, { order_by => { -asc => [qw/list_id rank/] } } )->all;

for my $rl1_sequence (@rl1_sequenceResults) {

    # Update Progress
    $current_line++;
    $next_update = $material_progress->update($current_line)
      if $current_line > $next_update;

    if ( exists( $list_links->{ $rl1_sequence->list_id } ) ) {

        # Get material
        my $rl1_material = $rebus1->resultset('Material')
          ->find( { material_id => $rl1_sequence->material_id } );

        if ( defined($rl1_material) ) {

            # Map Material to CSL
            my $csl = mapCSL($rl1_material);

            my ( $owner, $owner_uuid );
            if (
                (
                       defined( $rl1_material->print_sysno )
                    && $rl1_material->print_sysno ne ''
                    && !( $rl1_material->print_sysno =~ /^\s*$/ )
                )
                || (   defined( $rl1_material->elec_sysno )
                    && $rl1_material->elec_sysno ne ''
                    && !( $rl1_material->elec_sysno =~ /^\s*$/ ) )
              )
            {
                $owner      = $config->{'connector'};
                $owner_uuid = $rl1_material->print_sysno;
                $owner_uuid //= $rl1_material->elec_sysno;

            }
            else {
                print "Adding owner as code\n";

                # FIXME - This has changed in the RL2 Schema recently
                $owner      = $config->{'code'};
                $owner_uuid = '1-' . $user_links->{ $rl1_sequence->list_id };
            }

            # Add material
            my $rl2_material =
              addMaterial( $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
                $csl, $owner, $owner_uuid );

            # Get rating
            my $rl1_rating = $rebus1->resultset('MaterialRating')
              ->find( { material_id => $rl1_sequence->material_id } );

            # Link material to list
            my $rl2_sequence =
              $rebus2->resultset('ListMaterial')->find_or_create(
                {
                    list_id     => $list_links->{ $rl1_sequence->list_id },
                    material_id => $rl2_material->id,
                    rank        => $rl1_sequence->rank,
                    dislikes    => defined($rl1_rating)
                    ? $rl1_rating->not_likes
                    : 0,
                    likes => defined($rl1_rating) ? $rl1_rating->likes : 0,
                    category_id => $erbo_links->{ $rl1_material->erbo_id },
                    source_id   => 1,
                    source_uuid => $config->{'code'} . '-' . $rl2_material->id
                },
                { key => 'primary' }
              );

            # Get material tags
            my $rl1_tagResults = $rebus1->resultset('TagLink')
              ->search( { material_id => $rl1_sequence->material_id } );

            for my $rl1_tagResult ( $rl1_tagResults->all ) {

                # Get tag
                my $rl1_tag =
                  $rebus1->resultset('Tag')
                  ->find( { tag_id => $rl1_tagResult->tag_id } );

                # Add tag
                my $rl2_tag = addTag( { text => $rl1_tag->tag } );

                # Link tag to material in list
                my $rl2_link_tag =
                  $rebus2->resultset('MaterialTag')->find_or_create(
                    {
                        material_id => $rl2_material->id,
                        tag_id      => $rl2_tag->id,
                        list_id     => $list_links->{ $rl1_sequence->list_id }
                    },
                    { key => 'primary' }
                  );
            }
        }
    }
}

# Update counts
say "Updating material counts...\n";
my $rl2_listResults = $rebus2->resultset('List')->search(
    undef,
    {
        '+select' => [ { count => 'list_materials.list_id' } ],
        '+as'     => ['counted'],
        group_by  => 'me.id',
        join      => 'list_materials'
    }
);
for my $rl2_listResult ( $rl2_listResults->all ) {
    $rl2_listResult->update(
        { material_count => $rl2_listResult->get_column('counted') } );
}
say "Counts updated...\n";

# Permission, UserListPermission, UserOrgUnitPermission
say "Importing permissions...";
say "Permissions loaded...\n";

# Routines
sub addMaterial {
    my ( $in_stock, $metadata, $owner, $owner_uuid ) = @_;

    my @materialResults = $rebus2->resultset('Material')->search(
        {
            owner      => $owner,
            owner_uuid => $owner_uuid
        }
    );

    unless (@materialResults) {
        $metadata->{'id'} = $owner_uuid;
        my $new_material = $rebus2->resultset('Material')->create(
            {
                in_stock   => $in_stock,
                metadata   => $metadata,
                owner      => $owner,
                owner_uuid => $owner_uuid
            }
        );

        return $new_material;
    }

    return $materialResults[0];
}

sub addTag {
    my $text = shift;

    $text = lc($text);
    $text =~ s/\s/-/g;

    my @tagResults =
      $rebus2->resultset('Tag')->search( { text => $text } )->all;

    unless (@tagResults) {
        my $new_tag = $rebus2->resultset('Tag')->create( { text => $text } );
        return $new_tag;
    }

    return $tagResults[0];
}

sub mapCSL {
    my $result = shift;
    my $csl;

    if (   defined( $result->title )
        && $result->title ne ''
        && !( $result->title =~ /^\s*$/ ) )
    {
        $csl->{'title'} = $result->title;
    }
    if (   defined( $result->authors )
        && $result->authors ne ''
        && !( $result->authors =~ /^\s*$/ )
        || defined( $result->secondary_authors )
        && $result->secondary_authors ne ''
        && !( $result->secondary_authors =~ /^\s*$/ ) )
    {

        $csl->{'author'} = [];
        if ( defined( $result->authors ) ) {
            push @{ $csl->{'author'} }, { literal => $result->authors };
        }
        if ( defined( $result->secondary_authors ) ) {
            push @{ $csl->{'author'} },
              { literal => $result->secondary_authors };
        }
    }
    if (   defined( $result->edition )
        && $result->edition ne ''
        && !( $result->edition =~ /^\s*$/ ) )
    {
        $csl->{'edition'} = $result->edition;
    }
    if (   defined( $result->volume )
        && $result->volume ne ''
        && !( $result->volume =~ /^\s*$/ ) )
    {
        $csl->{'volume'} = $result->volume;
    }
    if (   defined( $result->issue )
        && $result->issue ne ''
        && !( $result->issue =~ /^\s*$/ ) )
    {
        $csl->{'issue'} = $result->issue;
    }
    if (   defined( $result->publisher )
        && $result->publisher ne ''
        && !( $result->publisher =~ /^\s*$/ ) )
    {
        $csl->{'publisher'} = $result->publisher;
    }
    if (   defined( $result->publication_date )
        && $result->publication_date ne ''
        && !( $result->publication_date =~ /^\s*$/ ) )
    {
        $csl->{'issued'} = { raw => $result->publication_date };
    }
    if (   defined( $result->publication_place )
        && $result->publication_place ne ''
        && !( $result->publication_place =~ /^\s*$/ ) )
    {
        $csl->{'publisher-place'} = $result->publication_place;
    }
    if (   defined( $result->note )
        && $result->note ne ''
        && !( $result->note =~ /^\s*$/ ) )
    {
        $csl->{'note'} = $result->note;
    }
    if (   defined( $result->url )
        && $result->url ne ''
        && !( $result->url =~ /^\s*$/ ) )
    {
        $csl->{'URL'} = $result->url;
    }

    my $epage;
    if (   defined( $result->epage )
        && $result->epage ne ''
        && !( $result->epage =~ /^\s*$/ ) )
    {
        $epage = $result->epage;
    }
    my $spage;
    if (   defined( $result->spage )
        && $result->spage ne ''
        && !( $result->spage =~ /^\s*$/ ) )
    {
        $spage = $result->spage;
    }
    if ( defined($epage) ) {
        $epage =~ s/pp\.//g;
        $epage =~ s/\D+//g;
    }
    if ( defined($spage) ) {
        $spage =~ s/pp\.//g;
        $spage =~ s/\D+//g;
    }

    my $secondary_title;
    if (   defined( $result->secondary_title )
        && $result->secondary_title ne ''
        && !( $result->secondary_title =~ /^\s*$/ ) )
    {
        $secondary_title = $result->secondary_title;
    }

    # Types:
    # 1=Book,
    # 2=Chapter,
    # 3=Journal,
    # 4=Article,
    # 5=Scan,
    # 7=Link,
    # 9=Other,
    # 10=eBook,
    # 11=AV,
    # 12=Note,
    # 13=Private Note
    if ( $result->material_type_id == 1 ) {
        $csl->{'type'} = 'book';
        if ( defined($secondary_title) ) {
            $csl->{'collection-title'} = $result->secondary_title;
        }
        $csl->{'number-of-pages'} = $spage if defined($spage);
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISBN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 2 ) {
        $csl->{'type'} = 'chapter';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
        $csl->{'page-first'} = $spage if defined($spage);
        $csl->{'number-of-pages'} = $epage - $spage
          if ( defined($epage) && defined($spage) );
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISBN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 3 ) {
        $csl->{'type'} = 'journal';    #CUSTOM
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISSN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 4 ) {
        $csl->{'type'} = 'article';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
        $csl->{'page-first'} = $spage if defined($spage);
        $csl->{'number-of-pages'} = $epage - $spage
          if ( defined($epage) && defined($spage) );
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISSN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 5 ) {
        $csl->{'type'} = 'entry';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
        $csl->{'page-first'} = $result->spage if defined($spage);
        $csl->{'number-of-pages'} = $epage - $spage
          if defined($epage) && defined($spage);
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISBN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 7 ) {
        $csl->{'type'} = 'webpage';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
    }
    if ( $result->material_type_id == 9 ) {
        $csl->{'type'} = 'entry';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
        $csl->{'page-first'} = $result->spage if defined($spage);
        $csl->{'number-of-pages'} = $epage - $spage
          if defined($epage) && defined($spage);
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISBN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 10 ) {
        $csl->{'type'} = 'book';
        if ( defined($secondary_title) ) {
            $csl->{'container-title'} = $result->secondary_title;
        }
        $csl->{'number-of-pages'} = $result->spage if defined($spage);
        if (   defined( $result->print_control_no )
            || defined( $result->elec_control_no ) )
        {
            $csl->{'ISBN'} =
              defined( $result->print_control_no )
              ? $result->print_control_no
              : $result->elec_control_no;
        }
    }
    if ( $result->material_type_id == 11 ) {
        $csl->{'type'} = 'broadcast';
        if ( defined($secondary_title) ) {
            $csl->{'collection-title'} = $result->secondary_title;
        }
    }

    # 12=Note and 13=Private Note are handled prior to this

    return $csl;
}
