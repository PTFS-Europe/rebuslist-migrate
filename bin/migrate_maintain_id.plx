#!/usr/bin/env perl
use strict;
use warnings;
use feature qw( say );
use utf8;

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
use Encoding::FixLatin qw(fix_latin);
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

my $rebus2
  = Rebus2::Schema->connect("dbi:Pg:database=$config->{'database2'};host=$config->{'host2'};port=$config->{'port2'}",
  "$config->{'username2'}", "$config->{'password2'}",
  {'pg_enable_utf8' => 1, 'on_connect_do' => ["SET search_path TO list"]});

# Load Validator
my $validator = JSON::Validator->new;
$validator->schema('/home/rebus/rebus-list/specification/definitions/csl-rebus.json');

# Begin Migration
say "Beggining migration...";
my $dt = DateTime->now(time_zone => 'local');
my $start
  = DateTime->new(year => 2010, month => 9, day => 1, hour => 1, minute => 1, second => 1, time_zone => 'local');
my $end
  = DateTime->new(year => 2020, month => 8, day => 31, hour => 23, minute => 59, second => 59, time_zone => 'local');

# Add lists
my $total = $rebus1->resultset('List')->count;
my $list_progress = Term::ProgressBar->new({name => "Importing lists", count => $total});
$list_progress->minor(0);
my $next_update  = 0;
my $current_line = 0;

my $list_links;
my $parent_links;
my $rl1_listResults = $rebus1->resultset('List')->search(undef, {order_by => {'-asc' => [qw/list_id/]}});
for my $rl1_list ($rl1_listResults->all) {

  # Update Progress
  $current_line++;
  $next_update = $list_progress->update($current_line) if $current_line > $next_update;

  # Add child list
  my $list_name = decode_entities($rl1_list->list_name);
  $list_name = 'BLANK' if $list_name eq '';
  my $start_clone = $start->clone;
  my $end_clone   = $end->clone;
  my $rl2_list    = $rebus2->resultset('List')->find_or_create(
    {
      id                => $rl1_list->list_id,
      root_id           => $rl1_list->list_id,
      name              => $list_name,
      no_students       => $rl1_list->no_students,
      ratio_books       => $rl1_list->ratio_books,
      ratio_students    => $rl1_list->ratio_students,
      updated           => $dt,
      created           => $dt,
      source_id         => 1,
      course_identifier => defined($rl1_list->course_identifier)
      ? fix_latin(decode_entities($rl1_list->course_identifier))
      : undef,
      year                     => $rl1_list->year,
      suppressed               => $rl1_list->published_yn eq 'y' ? 0 : 1,
      inherited_suppressed     => $rl1_list->published_yn eq 'y' ? 0 : 1,
      validity_start           => $start_clone->set_year($rl1_list->year),
      inherited_validity_start => $start_clone->set_year($rl1_list->year),
      validity_end           => $end_clone->set_year($rl1_list->year)->add(years => 1),
      inherited_validity_end => $end_clone->set_year($rl1_list->year)->add(years => 1),
      type                   => 'list'
    },
    {key => 'primary'}
  );

  $rl2_list->update({'source_uuid' => $config->{'code'} . "-" . $rl2_list->id});

  # Add to lookup table
  $list_links->{$rl1_list->list_id} = $rl2_list->id;
  push @{$parent_links->{$rl1_list->org_unit_id}}, $rl2_list->id;
}

# Update Sequence
$rebus2->storage->dbh_do(
  sub {
    $_[1]->do("SELECT SETVAL('lists_id_seq', COALESCE(MAX(id), 1) ) FROM lists;");
  }
);

# Add units
print "Importing units...\n";
my $current_level = 0;

my $unit_links = recurse([0], {});

sub recurse {
  my $parents    = shift;
  my $unit_links = shift;

  my @rl1_unitResults
    = $rebus1->resultset('OrgUnit')->search({parent => $parents}, {order_by => {'-asc' => [qw/parent org_unit_id/]}})
    ->all;

  if (@rl1_unitResults) {
    my $new_parents;

    for my $rl1_unit (@rl1_unitResults) {

      my $rl2_unit;
      if ($rl1_unit->parent == 0) {

        # Find next root
        my $rootResult
          = $rebus2->resultset('List')->search({}, {order_by => {'-asc' => [qw/root_id/]}, rows => '1'})->single;
        my $rootID;
        if (defined($rootResult)) {
          $rootID = $rootResult->root_id;
        }
        else {
          $rootID = 0;
        }
        $rootID = $rootID - 1;

        # Add new tree
        $rl2_unit = $rebus2->resultset('List')->create(
          {
            name                     => fix_latin(decode_entities($rl1_unit->name)),
            updated                  => $dt,
            created                  => $dt,
            source_id                => 1,
            suppressed               => 0,
            inherited_suppressed     => 0,
            root_id                  => $rootID,
            validity_start           => $start,
            inherited_validity_start => $start,
            validity_end             => $end,
            inherited_validity_end   => $end,
            type                     => 'unit'
          }
        );

        $rl2_unit->update({'source_uuid' => $config->{'code'} . "-" . $rl2_unit->id});

        # Ensure Unit it refetched
        $rl2_unit->discard_changes;

        # Add to lookup table
        $unit_links->{$rl1_unit->org_unit_id} = $rl2_unit->id;
        push @{$new_parents}, $rl1_unit->org_unit_id unless any { $_ == $rl1_unit->org_unit_id } @{$new_parents};
      }
      else {
        # Get existing parent
        my $parentResult = $rebus2->resultset('List')->find({id => $unit_links->{$rl1_unit->parent}});

        # Add rightmost child to existing node
        $rl2_unit = $parentResult->create_rightmost_child(
          {
            name                     => fix_latin(decode_entities($rl1_unit->name)),
            updated                  => $dt,
            created                  => $dt,
            source_id                => 1,
            suppressed               => 0,
            inherited_suppressed     => 0,
            validity_start           => $start,
            inherited_validity_start => $start,
            validity_end             => $end,
            inherited_validity_end   => $end,
            type                     => 'unit'
          }
        );

        $rl2_unit->update({'source_uuid' => $config->{'code'} . "-" . $rl2_unit->id});

        # Ensure Unit it refetched
        $rl2_unit->discard_changes;

        # Add to lookup table
        $unit_links->{$rl1_unit->org_unit_id} = $rl2_unit->id;
        push @{$new_parents}, $rl1_unit->org_unit_id unless any { $_ == $rl1_unit->org_unit_id } @{$new_parents};
      }

      # Add lists
      $parent_links->{$rl1_unit->org_unit_id} ||= [];
      my $rl2_listResults = $rebus2->resultset('List')
        ->search({id => {'-in' => $parent_links->{$rl1_unit->org_unit_id}}}, {order_by => {-asc => [qw/id/]}});

      while (my $rl2_list = $rl2_listResults->next) {

        # Attach list
        $rl2_unit->discard_changes;
        $rl2_unit->attach_rightmost_child($rl2_list);
        $rl2_list->discard_changes;
        $rl2_unit->discard_changes;
      }
    }
    recurse($new_parents, $unit_links);
  }
  else {
    return $unit_links;
  }
}

# User, UserType
$total = $rebus1->resultset('User')->count;
my $user_progress = Term::ProgressBar->new({name => "Importing Users", count => $total});
$user_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my $user_links;
my @rl1_userResults = $rebus1->resultset('User')->search(undef, {order_by => {-asc => [qw/type_id name/]}})->all;

my $role_map = {1 => 'librarian', 2 => 'staff', 3 => 'public', 4 => 'admin'};

for my $rl1_user (@rl1_userResults) {

  # Update Progress
  $current_line++;
  $next_update = $user_progress->update($current_line) if $current_line > $next_update;

  unless (defined($rl1_user->password)) {
    $rl1_user->password('38a4eae20c7e4de6560116e722229e50');
  }

  my $email = defined($rl1_user->email_address) ? $rl1_user->email_address : 'me@myemail.com';
  my $login = defined($rl1_user->login)         ? $rl1_user->login         : 'login' . $current_line;

  # Add user
  my $usertype_name = defined($role_map->{$rl1_user->type_id}) ? $role_map->{$rl1_user->type_id} : 'public';
  my $rl2_user = $rebus2->resultset('User')->find_or_create(
    {
      name     => $rl1_user->name,
      usertype => {name => $usertype_name},
      login    => $login,
      password => $rl1_user->password,
      email    => $email,
      active   => 1,
      remote   => 0
    }
  );

  # Convert Password Hash
  my $hashedPassword = defined($rl1_user->password)
    && $rl1_user->password ne "" ? $rl1_user->password : 'acd2dd34b761c2f1ecc66982c874b2b3';
  my $ppr = Authen::Passphrase::SaltedDigest->new(algorithm => "MD5", hash_hex => $hashedPassword);
  my $pass_string = $ppr->as_rfc2307;
  $rl2_user->store_column(password => $pass_string);
  $rl2_user->make_column_dirty('password');
  $rl2_user->update;

  # Add to lookup table
  $user_links->{$rl1_user->user_id} = $rl2_user->id;
}
say "Users loaded...\n";

# Erbo
$total = $rebus1->resultset('Erbo')->count;
my $category_progress = Term::ProgressBar->new({name => "Importing Categories", count => $total});
$category_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my $erbo_links;
my @rl1_erboResults = $rebus1->resultset('Erbo')->search(undef, {order_by => {-asc => [qw/rank erbo/]}})->all;

my $rank = 0;
$rebus2->resultset('Category')->delete;
for my $rl1_erbo (@rl1_erboResults) {

  # Update Progress
  $current_line++;
  $next_update = $category_progress->update($current_line) if $current_line > $next_update;

  # Add category
  my $rl2_erbo = $rebus2->resultset('Category')->create({category => $rl1_erbo->erbo, rank => $rank++, source_id => 1});
  $rl2_erbo->update({'source_uuid' => $config->{'code'} . "-" . $rl2_erbo->id});

  # Add to lookup table
  $erbo_links->{$rl1_erbo->erbo_id} = $rl2_erbo->id;
}

# Update preference table
my $rl2_categoriesResult = $rebus2->resultset('Category')->search(undef, {order_by => 'rank'});
my @rl2_categoriesArray  = $rl2_categoriesResult->get_column('category')->all;
my $rl2_categories_json  = encode_json \@rl2_categoriesArray;
my $rl2_preferenceResult = $rebus2->resultset('Preference')->find({code => 'categories'});
$rl2_preferenceResult->update({content => $rl2_categories_json});
say "Categories loaded...\n";

# Sequence, Material, MaterialType, MaterialRating, MaterialLabel, Tag, TagLink, MetadataSource
$total = $rebus1->resultset('Sequence')->count;
my $material_progress = Term::ProgressBar->new({name => "Importing Materials", count => $total});
$material_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my @rl1_sequenceResults
  = $rebus1->resultset('Sequence')->search(undef, {order_by => {-asc => [qw/list_id rank/]}})->all;
my $sublistID;
my $lastListID;

# Work through RL1 `sequence` table
for my $rl1_sequence (@rl1_sequenceResults) {

  # Update Progress
  $current_line++;
  $next_update = $material_progress->update($current_line) if $current_line > $next_update;

  # Reset list tracking variables
  if (!defined($lastListID) || ($lastListID != $rl1_sequence->list_id)) {
    $sublistID = undef;
  }
  $lastListID = $rl1_sequence->list_id;

  # Work on material if list exists in rl2 (sequence is not properly cleared down when a `list` is deleted in RL1)
  if (exists($list_links->{$rl1_sequence->list_id})) {

    # Get material from RL1
    my $rl1_material = $rebus1->resultset('Material')->find({material_id => $rl1_sequence->material_id});

    # Check material exists (sequence is not properly cleared down when a `material` is deleted in RL1)
    if (defined($rl1_material)) {

      # Handle Note/Private Note
      if ($rl1_material->material_type_id == 12 || $rl1_material->material_type_id == 13) {

        # Find list in RL2
        my $listResult = $rebus2->resultset('List')->find({id => $list_links->{$rl1_sequence->list_id}});

        # Fetch note content
        my $note = defined($rl1_material->title) ? fix_latin(decode_entities($rl1_material->title)) : '';

        if ($rl1_material->material_type_id == 12) {

          # Public Note
          if (defined($config->{'split_on_notes'}) && $config->{'split_on_notes'}) {

            # Add rightmost child sublist to list parent
            my $rl2_sublistResult = $listResult->create_rightmost_child(
              {
                name                     => $note,
                source_id                => 1,
                suppressed               => 0,
                inherited_suppressed     => 0,
                validity_start           => $listResult->validity_start,
                inherited_validity_start => $listResult->inherited_validity_start,
                validity_end             => $listResult->validity_end,
                inherited_validity_end   => $listResult->inherited_validity_end,
                type                     => 'sublist'
              }
            );
            $rl2_sublistResult->update({'source_uuid' => $config->{'code'} . "-" . $rl2_sublistResult->id});

            $sublistID = $rl2_sublistResult->id;
          }
          elsif (defined($config->{'has_notes'}) && $config->{'has_notes'}) {

            my $materialRecord = {
              in_stock      => 0,
              metadata      => {type => 'note', title => $note},
              owner         => $config->{code},
              owner_uuid    => '1-',
              electronic    => undef,
              web_link      => undef,
              lms_link      => undef,
              status_link   => undef,
              fulltext_link => undef,
              delayed_link  => undef
            };

            # Add `note` material
            my $rl2_material = addMaterial($materialRecord, undef);

            # Link to list in appropriate location
            my $rl1_note = $rl1_material->note;    #believe it or not, in rl1 you could add a note to a note!
            my $rl1_rating = $rebus1->resultset('MaterialRating')->find({material_id => $rl1_sequence->material_id});
            $rebus2->resultset('ListMaterial')->create(
              {
                list_id     => $list_links->{$rl1_sequence->list_id},
                material_id => $rl2_material->id,
                rank        => $rl1_sequence->rank,                    #FIXME: We cannot rely on rl1 rank being correct!
                dislikes => defined($rl1_rating) ? $rl1_rating->not_likes : 0,
                likes => defined($rl1_rating) ? $rl1_rating->likes : 0,
                note => $rl1_note,
                category_id => $erbo_links->{$rl1_material->erbo_id},
                source_id   => 1,
                source_uuid => $config->{'code'} . '-' . $rl2_material->id
              },
              {key => 'primary'}
            );
          }
          else {
            if (defined($listResult->public_note)) {
              $listResult->update({public_note => $listResult->public_note . "\n\n" . $note});
            }
            else {
              $listResult->update({public_note => $note});
            }
          }
        }
        else {

          # Private Note
          if (defined($listResult->private_note)) {
            $listResult->update({private_note => $listResult->private_note . "\n\n" . $note});
          }
          else {
            $listResult->update({private_note => $note});
          }
        }
      }

      # Handle Everything Else
      else {

        # Map Material to CSL
        my $csl = mapCSL($rl1_material);

        # Array up CSL
        $csl = arrayCSL($csl);

        # Clean up CSL
        $csl = cleanCSL($csl);

        # Identify RL1 Local, Article and Chapter Type Materials
        my ($owner, $owner_uuid, $container_uuid);

        # Article/Chapter (Local unless Summon/EDS)
        if ( ($config->{'connector'} !~ m/.*_summon|.*_eds/ && $csl->{type} eq 'article')
          || ($config->{'connector'} !~ m/.*_eds/ && $csl->{type} eq 'chapter'))
        {
          $owner          = $config->{'code'};
          $owner_uuid     = '1-';
          $container_uuid = $rl1_material->elec_sysno
            if (defined($rl1_material->elec_sysno)
            && $rl1_material->elec_sysno ne ''
            && !($rl1_material->elec_sysno =~ /^\s*$/));
          $container_uuid = $rl1_material->print_sysno
            if (defined($rl1_material->print_sysno)
            && $rl1_material->print_sysno ne ''
            && !($rl1_material->print_sysno =~ /^\s*$/));
        }

        # Remote from print_sysno
        elsif (defined($rl1_material->print_sysno)
          && $rl1_material->print_sysno ne ''
          && !($rl1_material->print_sysno =~ /^\s*$/))
        {
          $owner      = $config->{'connector'};
          $owner_uuid = $rl1_material->print_sysno;
        }

        # Remote from elec_sysno
        elsif (defined($rl1_material->elec_sysno)
          && $rl1_material->elec_sysno ne ''
          && !($rl1_material->elec_sysno =~ /^\s*$/))
        {
          $owner      = $config->{'connector'};
          $owner_uuid = $rl1_material->elec_sysno;
        }

        # Remote from _eds URL
        elsif (
             $config->{'connector'} =~ m/|.*_eds/
          && defined($rl1_material->url)
          && ( $rl1_material->url =~ m/^.*&db=(.*)&AN=(.*)&.*$/
            || $rl1_material->url =~ m/^.*&amp;db=(.*)&amp;AN=(.*)&amp;*$/)
          )
        {
          $owner      = $config->{'connector'};
          $owner_uuid = $1 . "," . $2;
        }

        # Local
        else {
          $owner      = $config->{'code'};
          $owner_uuid = '1-';
        }

        # eBook?
        my $eBook = ($rl1_material->material_type_id == 10) ? 1 : 0;

        # Add Links
        my ($web, $lms, $full, $delayed) = undef;
        $lms = $config->{'opac_url'} . $rl1_material->print_sysno
          if (defined($rl1_material->print_sysno)
          && $rl1_material->print_sysno ne ''
          && !($rl1_material->print_sysno =~ /^\s*$/));

        $lms = $config->{'opac_url'} . $rl1_material->elec_sysno
          if (defined($rl1_material->elec_sysno)
          && $rl1_material->elec_sysno ne ''
          && !($rl1_material->elec_sysno =~ /^\s*$/));

        $web = $rl1_material->url
          if (defined($rl1_material->url) && $rl1_material->url ne '' && !($rl1_material->url =~ /^\s*$/));

        my $materialRecord = {
          in_stock => $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
          metadata => $csl,
          owner    => $owner,
          owner_uuid    => $owner_uuid,
          electronic    => $eBook,
          web_link      => $web,
          lms_link      => $lms,
          status_link   => undef,
          fulltext_link => $full,
          delayed_link  => $delayed
        };

        # Add material
        my $rl2_material = addMaterial($materialRecord, $container_uuid);

        # Get list note
        my $rl1_note = $rl1_material->note;

        # Get rating
        my $rl1_rating = $rebus1->resultset('MaterialRating')->find({material_id => $rl1_sequence->material_id});

        # Link material to list (ensuring no loses due to duplicate misidentification)
        my $rl2_sequence = $rebus2->resultset('ListMaterial')->find(
          {
            list_id => defined($sublistID) ? $sublistID : $list_links->{$rl1_sequence->list_id},
            material_id => $rl2_material->id
          },
          {key => 'primary'}
        );

        # If Exists, create new 'local' copy
        if (defined($rl2_sequence)) {

          my $original_materialID = $rl2_material->id;

          my @set = ('0' .. '9', 'A' .. 'F');
          my $str = join '' => map $set[rand @set], 1 .. 8;

          # Add duplicate material as a manual entry :(
          # If the material is a dupe it's most likely an analytic where the detail is in the note field; As such we
          # should convert the material to a 'chapter', moving the note into the title.

          $csl->{'container-title'} = $csl->{'title'} if exists($csl->{'title'});
          delete($csl->{'title'});
          $csl->{'title'}
            = defined($rl1_material->note)
            ? $rl1_material->note . "|" . $str . "|"
            : "Analytic Placeholder|" . $str . "|";
          $csl->{'container-title-short'} = $csl->{'title-short'} if exists($csl->{'title-short'});
          delete($csl->{'title-short'});
          $csl->{'container-author'} = $csl->{'author'} if exists($csl->{'author'});
          delete($csl->{'author'});
          $csl->{'type'} = 'chapter';
          delete($csl->{'id'});

          my $materialRecord = {
            in_stock => $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
            metadata => $csl,
            owner    => $config->{code},
            owner_uuid    => '1-',
            electronic    => $eBook,
            web_link      => $web,
            lms_link      => $lms,
            status_link   => undef,
            fulltext_link => $full,
            delayed_link  => $delayed
          };

          $rl2_material = addMaterial($materialRecord, undef);

          $rl2_sequence = $rebus2->resultset('ListMaterial')->find_or_create(
            {
              list_id => defined($sublistID) ? $sublistID : $list_links->{$rl1_sequence->list_id},
              material_id => $rl2_material->id,
              rank        => $rl1_sequence->rank,    #FIXME: We cannot rely on rl1 rank being correct!
              dislikes => defined($rl1_rating) ? $rl1_rating->not_likes : 0,
              likes => defined($rl1_rating) ? $rl1_rating->likes : 0,
              note => $rl1_note,
              category_id => $erbo_links->{$rl1_material->erbo_id},
              source_id   => 1,
              source_uuid => $config->{'code'} . '-' . $rl2_material->id
            },
            {key => 'primary'}
          );
        }

        # Else add to list as is
        else {

          $rl2_sequence = $rebus2->resultset('ListMaterial')->create(
            {
              list_id => defined($sublistID) ? $sublistID : $list_links->{$rl1_sequence->list_id},
              material_id => $rl2_material->id,
              rank        => $rl1_sequence->rank,    #FIXME: We cannot rely on rl1 rank being correct!
              dislikes => defined($rl1_rating) ? $rl1_rating->not_likes : 0,
              likes => defined($rl1_rating) ? $rl1_rating->likes : 0,
              note => $rl1_note,
              category_id => $erbo_links->{$rl1_material->erbo_id},
              source_id   => 1,
              source_uuid => $config->{'code'} . '-' . $rl2_material->id
            },
            {key => 'primary'}
          );
        }

        # Add material analytic link (if chapter or article)
        if ($csl->{type} eq 'article' || $csl->{type} eq 'chapter') {
          $owner      = $config->{'connector'};
          $owner_uuid = undef;
          if ( defined($rl1_material->print_sysno)
            && $rl1_material->print_sysno ne ''
            && !($rl1_material->print_sysno =~ /^\s*$/))
          {
            $owner_uuid = $rl1_material->print_sysno;
            $owner_uuid =~ s/\^/,/g;    # Convert `^` to `,` for EDS records
          }
          elsif (defined($rl1_material->elec_sysno)
            && $rl1_material->elec_sysno ne ''
            && !($rl1_material->elec_sysno =~ /^\s*$/))
          {
            $owner_uuid = $rl1_material->elec_sysno;
            $owner_uuid =~ s/\^/,/g;    # Convert `^` to `,` for EDS records
          }
          if (defined($owner_uuid)) {
            my $containerResult = $rebus2->resultset('Material')->find({owner => $owner, owner_uuid => $owner_uuid});

            if (defined($containerResult)) {
              $rebus2->resultset('MaterialAnalytic')
                ->find_or_create({container_id => $containerResult->id, analytic_id => $rl2_material->id});
            }
            else {
              my $metadata = {id => [$owner_uuid], type => 'unknown', title => 'Skelital Container Record'};
              $containerResult
                = $rebus2->resultset('Material')
                ->find_or_create(
                {in_stock => 1, metadata => $metadata, owner => $owner, owner_uuid => $owner_uuid, electronic => 0},
                {key => 'owner'});

              $rebus2->resultset('MaterialAnalytic')
                ->find_or_create({container_id => $containerResult->id, analytic_id => $rl2_material->id});
            }
          }
        }

        # Get material tags
        my $rl1_tagResults = $rebus1->resultset('TagLink')->search({material_id => $rl1_sequence->material_id});

        for my $rl1_tagResult ($rl1_tagResults->all) {

          # Get tag
          my $rl1_tag = $rebus1->resultset('Tag')->find({tag_id => $rl1_tagResult->tag_id});

          # Add tag
          my $rl2_tag = addTag($rl1_tag->tag);

          # Link tag to material in list
          if ($rl2_tag) {
            my $rl2_link_tag = $rebus2->resultset('MaterialTag')->find_or_create(
              {
                material_id => $rl2_material->id,
                tag_id      => $rl2_tag->id,
                list_id     => defined($sublistID) ? $sublistID : $list_links->{$rl1_sequence->list_id}
              },
              {key => 'primary'}
            );
          }
        }

        # Add alternatives when found
        if (
          (
               defined($rl1_material->print_sysno)
            && $rl1_material->print_sysno ne ''
            && !($rl1_material->print_sysno =~ /^\s*$/)
          )
          && ( defined($rl1_material->elec_sysno)
            && $rl1_material->elec_sysno ne ''
            && !($rl1_material->elec_sysno =~ /^\s*$/))
          && ($rl1_material->print_sysno ne $rl1_material->elec_sysno)
          )
        {
          $owner      = $config->{'connector'};
          $owner_uuid = $rl1_material->elec_sysno;
          $lms        = $config->{'opac_url'} . $rl1_material->elec_sysno;

          my $materialRecord = {
            in_stock => $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
            metadata => $csl,
            owner    => $owner,
            owner_uuid    => $owner_uuid,
            electronic    => $eBook,
            web_link      => $web,
            lms_link      => $lms,
            status_link   => undef,
            fulltext_link => $full,
            delayed_link  => $delayed
          };

          # Add material
          my $rl2_alt_material = addMaterial($materialRecord, $container_uuid);

          # Link material as alternative
          my $rl2_sequence = $rebus2->resultset('ListMaterialAlternative')->create(
            {
              list_id => defined($sublistID) ? $sublistID : $list_links->{$rl1_sequence->list_id},
              material_id    => $rl2_material->id,
              alternative_id => $rl2_alt_material->id
            },
            {key => 'primary'}
          );
        }
      }
    }
  }
}

# Update counts
say "Updating material counts...\n";
my $rl2_listResults = $rebus2->resultset('List')->search(
  undef,
  {
    '+select' => [{count => 'list_materials.list_id'}],
    '+as'     => ['counted'],
    group_by  => 'me.id',
    join      => 'list_materials'
  }
);
for my $rl2_listResult ($rl2_listResults->all) {
  $rl2_listResult->update({material_count => $rl2_listResult->get_column('counted')});
}
say "Counts updated...\n";

# Clean up material titles
say "Cleaning up material titles...\n";
my $type_json          = {type => 'chapter'};
my $json_type          = encode_json $type_json;
my $rl2_chapterResults = $rebus2->resultset('Material')->search({metadata => {'@>' => $json_type}});
for my $rl2_chapterResult ($rl2_chapterResults->all) {
  my $metadata = $rl2_chapterResult->metadata;
  if (defined($metadata->{'title'}) && ($metadata->{'title'} =~ m/\|(?:\d|[A-F]){8}\|/)) {
    $metadata->{'title'} =~ s/\|(?:\d|[A-F]){8}\|//g;
    $rl2_chapterResult->update({metadata => $metadata});
  }
}

# Permission, UserListPermission, UserOrgUnitPermission
# 'Permission' handled in User import above
$total = $rebus1->resultset('UserOrgUnitPermission')->count;
$total = $total + $rebus1->resultset('UserListPermission')->count;
my $permission_progress = Term::ProgressBar->new({name => "Importing Permissions", count => $total});
$permission_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my $default_role = exists($config->{'list_role'}) ? $config->{'list_role'} : 'author';
my $rl2_editorID = $rebus2->resultset('Role')->search({name => $default_role}, {rows => 1})->single->get_column('id');

my @rl1_user_org_unit_permissionResults
  = $rebus1->resultset('UserOrgUnitPermission')->search(undef, {order_by => {-asc => [qw/org_unit_id user_id/]}})->all;

for my $rl1_uoup (@rl1_user_org_unit_permissionResults) {

  # Update Progress
  $current_line++;
  $next_update = $permission_progress->update($current_line) if $current_line > $next_update;

  if (exists($unit_links->{$rl1_uoup->org_unit_id}) && exists($user_links->{$rl1_uoup->user_id})) {
    $rebus2->resultset('ListUserRole')->find_or_create(
      {
        list_id        => $unit_links->{$rl1_uoup->org_unit_id},
        user_id        => $user_links->{$rl1_uoup->user_id},
        role_id        => $rl2_editorID,
        inherited_from => $unit_links->{$rl1_uoup->org_unit_id}
      },
      {key => 'primary'}
    );

    my $listResult = $rebus2->resultset('List')->find($unit_links->{$rl1_uoup->org_unit_id});
    for my $descendantResult ($listResult->descendants->all) {
      $descendantResult->find_or_create_related(
        'list_user_roles',
        {
          user_id        => $user_links->{$rl1_uoup->user_id},
          role_id        => $rl2_editorID,
          inherited_from => $unit_links->{$rl1_uoup->org_unit_id}
        }
      );
    }
  }
}

my @rl1_user_list_permissionResults
  = $rebus1->resultset('UserListPermission')->search(undef, {order_by => {-asc => [qw/list_id user_id/]}})->all;

for my $rl1_ulp (@rl1_user_list_permissionResults) {

  # Update Progress
  $current_line++;
  $next_update = $permission_progress->update($current_line) if $current_line > $next_update;

  if (exists($list_links->{$rl1_ulp->list_id}) && exists($user_links->{$rl1_ulp->user_id})) {
    $rebus2->resultset('ListUserRole')->find_or_create(
      {
        list_id        => $list_links->{$rl1_ulp->list_id},
        user_id        => $user_links->{$rl1_ulp->user_id},
        role_id        => $rl2_editorID,
        inherited_from => $list_links->{$rl1_ulp->list_id}
      },
      {key => 'primary'}
    );

    my $listResult = $rebus2->resultset('List')->find($list_links->{$rl1_ulp->list_id});
    for my $descendantResult ($listResult->descendants->all) {
      $descendantResult->find_or_create_related(
        'list_user_roles',
        {
          user_id        => $user_links->{$rl1_ulp->user_id},
          role_id        => $rl2_editorID,
          inherited_from => $list_links->{$rl1_ulp->list_id}
        }
      );
    }

  }
}

say "Permissions loaded...\n";

# OwnersLink
$total = $rebus1->resultset('OwnersLink')->count;
my $owners_progress = Term::ProgressBar->new({name => "Importing Owners", count => $total});
$owners_progress->minor(0);
$next_update  = 0;
$current_line = 0;

my @rl1_owners
  = $rebus1->resultset('OwnersLink')->search(undef, {order_by => {-asc => [qw/list_id owner_id leader_yn/]}})->all;

my $roleResult = $rebus2->resultset('Role')->find({name => 'leader'});
my $leaderID = $roleResult->id;
$roleResult = $rebus2->resultset('Role')->find({name => 'owner'});
my $ownerID = $roleResult->id;

for my $rl1_owner (@rl1_owners) {

  # Update Progress
  $current_line++;
  $next_update = $owners_progress->update($current_line) if $current_line > $next_update;

  if (exists($list_links->{$rl1_owner->list_id}) && exists($user_links->{$rl1_owner->owner_id})) {
    my $roleID = $rl1_owner->leader_yn eq 'y' ? $leaderID : $ownerID;
    $rebus2->resultset('ListUserRole')->find_or_create(
      {
        list_id => $list_links->{$rl1_owner->list_id},
        user_id => $user_links->{$rl1_owner->owner_id},
        role_id => $roleID
      },
      {key => 'primary'}
    );
  }
}

# Routines
sub addMaterial {
  my ($materialRecord, $container_uuid) = @_;
  my $in_stock   = $materialRecord->{in_stock};
  my $metadata   = $materialRecord->{metadata};
  my $owner      = $materialRecord->{owner};
  my $owner_uuid = $materialRecord->{owner_uuid};
  my $eBook      = $materialRecord->{electronic};
  my $web        = $materialRecord->{web_link};
  my $lms        = $materialRecord->{lms_link};
  my $full       = $materialRecord->{fulltext_link};
  my $delayed    = $materialRecord->{delayed_link};

  # If container_uuid, add first and link
  my $containerResult;
  if (defined($container_uuid)) {
    $containerResult
      = $rebus2->resultset('Material')->find({owner => $config->{connector}, owner_uuid => $container_uuid});
    unless (defined($containerResult)) {
      my $metadata = {id => [$container_uuid], type => 'unknown', title => 'Skelital Container Record'};
      $containerResult
        = $rebus2->resultset('Material')
        ->find_or_create(
        {in_stock => 1, metadata => $metadata, owner => $owner, owner_uuid => $owner_uuid, electronic => 0},
        {key      => 'owner'});
    }
  }

  # Local Material
  if ($owner_uuid eq '1-') {
    if ($metadata->{'type'} ne 'note') {
      my $title      = $metadata->{'title'};
      my $type       = $metadata->{'type'};
      my $title_json = {title => $title, type => $type};
      my $json_title = encode_json $title_json;
      my $found = $rebus2->resultset('Material')->search({metadata => {'@>' => $json_title}, electronic => $eBook});
      my ($isbn, $issn);
      if ($found->count == 1) {
        my $new_material = $found->next;
        my $linked
          = $rebus2->resultset('MaterialAnalytic')
          ->find({container_id => $containerResult->id, analytic_id => $new_material->id})
          if (defined($containerResult));
        return $new_material if (!defined($containerResult) || defined($linked));
      }
      elsif ($found->count >= 1) {
        $isbn = $metadata->{ISBN} if exists($metadata->{ISBN});
        if ($isbn) {
          my $isbn_json = {ISBN => $isbn};
          my $json_isbn = encode_json $isbn_json;
          my $found2    = $found->search({metadata => {'@>' => $json_isbn}});
          if ($found2->count == 1) {
            my $new_material = $found2->next;
            my $linked
              = $rebus2->resultset('MaterialAnalytic')
              ->find({container_id => $containerResult->id, analytic_id => $new_material->id})
              if (defined($containerResult));
            return $new_material if (!defined($containerResult) || defined($linked));
          }
        }
        $issn = $metadata->{ISSN} if exists($metadata->{ISSN});
        if ($issn) {
          my $issn_json = {ISSN => $issn};
          my $json_issn = encode_json $issn_json;
          my $found2    = $found->search({metadata => {'@>' => $json_issn}});
          if ($found2->count == 1) {
            my $new_material = $found2->next;
            my $linked
              = $rebus2->resultset('MaterialAnalytic')
              ->find({container_id => $containerResult->id, analytic_id => $new_material->id})
              if (defined($containerResult));
            return $new_material if (!defined($containerResult) || defined($linked));
          }
        }
      }
    }

    # Not Found
    $metadata->{'id'} = [$owner_uuid];
    my $new_material = $rebus2->resultset('Material')->create(
      {
        in_stock      => $in_stock,
        metadata      => $metadata,
        owner         => $owner,
        owner_uuid    => undef,
        electronic    => $eBook,
        web_link      => $web,
        lms_link      => $lms,
        status_link   => undef,
        fulltext_link => $full,
        delayed_link  => $delayed
      }
    );

    my $metadata = $new_material->metadata;
    my $id       = '1-' . $new_material->id;
    $metadata->{'id'} = [$id];
    $new_material->update({metadata => $metadata, owner_uuid => $id});

    # Validate metadata
    my @errors = $validator->validate($metadata);
    if (@errors) {
      use Data::Dumper;
      warn "Errors: " . Dumper(@errors) . "\n";
      exit;
    }

    # Add analytic link
    $rebus2->resultset('MaterialAnalytic')
      ->find_or_create({container_id => $containerResult->id, analytic_id => $new_material->id})
      if (defined($containerResult));

    return $new_material;
  }

  # Remote Material
  $owner_uuid =~ s/\^/,/g;    # Convert `^` to `,` for EDS records
  my $materialResult = $rebus2->resultset('Material')->find({owner => $owner, owner_uuid => $owner_uuid}, {rows => 1});

  if (defined($materialResult)) {
    $metadata->{'id'} = [$owner_uuid];
    $materialResult->update({metadata => $metadata});
    return $materialResult;
  }
  else {
    $metadata->{'id'} = [$owner_uuid];

    # Validate metadata
    my @errors = $validator->validate($metadata);
    if (@errors) {
      use Data::Dumper;
      warn "Errors: " . Dumper(@errors) . "\n";
      exit;
    }

    # Find Manual Materials for Update or Create a new Remote material
    my $title      = $metadata->{'title'};
    my $type       = $metadata->{'type'};
    my $title_json = {title => $title, type => $type};
    my $json_title = encode_json $title_json;
    my $found      = $rebus2->resultset('Material')
      ->search({metadata => {'@>' => $json_title}, electronic => $eBook, owner => $config->{'code'}});
    if ($found->count == 1) {
      my $new_material = $found->next;
      $new_material->update({owner => $owner, owner_uuid => $owner_uuid});
      return $new_material;
    }
    else {
      my $new_material = $rebus2->resultset('Material')->create(
        {
          in_stock      => 1,
          metadata      => $metadata,
          owner         => $owner,
          owner_uuid    => $owner_uuid,
          electronic    => $eBook,
          web_link      => $web,
          lms_link      => $lms,
          status_link   => undef,
          fulltext_link => $full,
          delayed_link  => $delayed
        }
      );

      return $new_material;
    }
  }
}

sub addTag {
  my $text = fix_latin(decode_entities(shift));

  $text = trim($text);

  unless (length $text) {
    return;
  }

  my @tagResults = $rebus2->resultset('Tag')->search({text => $text})->all;

  unless (@tagResults) {
    my $new_tag = $rebus2->resultset('Tag')->create({text => $text});
    return $new_tag;
  }

  return $tagResults[0];
}

sub mapCSL {
  my $materialResult = shift;
  my $csl;

  my $material = {$materialResult->get_columns};
  for my $field (keys %{$material}) {
    $material->{$field} = fix_latin(decode_entities($material->{$field})) if defined($material->{$field});
    delete $material->{$field}
      unless (defined($material->{$field}) && $material->{$field} ne '' && $material->{$field} !~ /^\s*$/);
  }

  # Title
  $csl->{title} = $material->{title} if exists($material->{title});

  # Authors
  $csl->{author} = [];
  push @{$csl->{author}}, {literal => $material->{authors}} if exists($material->{authors});

  # Edition
  $csl->{edition} = $material->{edition} if exists($material->{edition});

  # Volume
  $csl->{volume} = $material->{volume} if exists($material->{volume});

  # Issue
  $csl->{issue} = $material->{issue} if exists($material->{issue});

  # Publisher
  $csl->{publisher} = $material->{publisher} if exists($material->{publisher});

  # Publication Date
  $csl->{issued} = $material->{publication_date} if exists($material->{publication_date});

  # Publication Place
  $csl->{'publisher-place'} = $material->{publication_place} if exists($material->{publication_place});

  # Public Note
  $csl->{'note'} = $material->{note} if exists($material->{note});

  # URL
  $csl->{'URL'} = $material->{url} if exists($material->{url});

  # Per Type Mappings

  # Start Page
  $material->{spage} =~ s/pp\.//g if exists($material->{spage});

  # End Page
  $material->{epage} =~ s/pp\.//g if exists($material->{epage});

  # Types:
  # 1=Book
  if ($materialResult->material_type_id == 1) {

    # Type
    $csl->{'type'} = 'book';

    # Secondary Title
    $csl->{'collection-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Secondary Authors
    $csl->{editor} = [];
    push @{$csl->{editor}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});

    # Start Page -> Number of Pages
    $material->{spage} =~ s/\D+//g if exists($material->{spage});
    $csl->{'number-of-pages'} = $material->{spage} if exists($material->{spage});

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 2=Chapter
  elsif ($materialResult->material_type_id == 2) {

    # Type
    $csl->{'type'} = 'chapter';

    # Secondary Title
    $csl->{'container-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Author
    $csl->{'author'} = [];
    push @{$csl->{author}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});

    # Secondary Author
    $csl->{'container-author'} = [];
    push @{$csl->{'container-author'}}, {literal => $material->{authors}} if exists($material->{authors});

    # Start Page
    $csl->{'page-first'} = $material->{spage} if exists($material->{spage});

    # End Page
    $material->{epage} =~ s/\D+//g if exists($material->{epage});
    delete $material->{epage} if (exists($material->{epage}) && $material->{epage} eq '');
    $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
      if (exists($material->{epage}) && exists($material->{spage}) && looks_like_number($material->{spage}));

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 3=Journal
  elsif ($materialResult->material_type_id == 3) {

    # Type
    $csl->{'type'} = 'journal';

    # Secondary Authors
    push @{$csl->{author}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});

    # ISSN
    $csl->{ISSN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISSN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 4=Article
  elsif ($materialResult->material_type_id == 4) {

    # Type
    $csl->{'type'} = 'article';

    # Authors
    if (exists($material->{secondary_authors})) {
      my @authors = split(/;/, $material->{secondary_authors});
      for my $author (@authors) {
        push @{$csl->{author}}, {literal => $author};
      }
    }

    # Secondary Title
    $csl->{'container-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Start Page
    $csl->{'page-first'} = $material->{spage} if exists($material->{spage});

    # End Page
    $material->{epage} =~ s/\D+//g if exists($material->{epage});
    delete $material->{epage} if (exists($material->{epage}) && $material->{epage} eq '');
    $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
      if (exists($material->{epage}) && exists($material->{spage}) && looks_like_number($material->{spage}));

    # ISSN
    $csl->{ISSN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISSN} = $material->{print_control_no} if exists($material->{print_control_no});

    # Issued
    $csl->{issued} = $material->{year} if exists($material->{year});
  }

  # 5=Scan
  elsif ($materialResult->material_type_id == 5) {

    # Type
    $csl->{'type'} = 'entry';

    # Secondary Title
    $csl->{'container-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Start Page
    $csl->{'page-first'} = $material->{spage} if exists($material->{spage});

    # End Page
    $material->{epage} =~ s/\D+//g if exists($material->{epage});
    delete $material->{epage} if (exists($material->{epage}) && $material->{epage} eq '');
    $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
      if (exists($material->{epage}) && exists($material->{spage}) && looks_like_number($material->{spage}));

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 7=Link
  elsif ($materialResult->material_type_id == 7) {

    # Type
    $csl->{'type'} = 'webpage';

    # Secondary Title
    $csl->{'container-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Secondary Authors
    push @{$csl->{author}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});
  }

  # 9=Other
  elsif ($materialResult->material_type_id == 9) {

    # Type
    $csl->{'type'} = 'entry';

    # Secondary Title
    $csl->{'container-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Start Page
    $csl->{'page-first'} = $material->{spage} if exists($material->{spage});

    # End Page
    $material->{epage} =~ s/\D+//g if exists($material->{epage});
    delete $material->{epage} if (exists($material->{epage}) && $material->{epage} eq '');
    $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
      if (exists($material->{epage}) && exists($material->{spage}) && looks_like_number($material->{spage}));

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 10=eBook
  elsif ($materialResult->material_type_id == 10) {

    # Type
    $csl->{'type'} = 'book';

    # Secondary Title
    $csl->{'collection-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Secondary Authors
    $csl->{editor} = [];
    push @{$csl->{editor}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});

    # Start Page -> Number of Pages
    $material->{spage} =~ s/\D+//g if exists($material->{spage});
    $csl->{'number-of-pages'} = $material->{spage} if exists($material->{spage});

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 11=AV
  elsif ($materialResult->material_type_id == 11) {

    # Type
    $csl->{'type'} = 'broadcast';

    # Secondary Title
    $csl->{'collection-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Secondary Authors
    $csl->{editor} = [];
    push @{$csl->{editor}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});
  }

  # 12=Note
  # 13=Private Note
  # NONE
  else {
    # Type
    $csl->{'type'} = 'book';

    # Secondary Title
    $csl->{'collection-title'} = $material->{secondary_title} if exists($material->{secondary_title});

    # Secondary Authors
    $csl->{editor} = [];
    push @{$csl->{editor}}, {literal => $material->{secondary_authors}} if exists($material->{secondary_authors});

    # Start Page -> Number of Pages
    $material->{spage} =~ s/\D+//g if exists($material->{spage});
    $csl->{'number-of-pages'} = $material->{spage} if exists($material->{spage});

    # ISBN
    $csl->{ISBN} = $material->{elec_control_no}  if exists($material->{elec_control_no});
    $csl->{ISBN} = $material->{print_control_no} if exists($material->{print_control_no});
  }

  # 12=Note and 13=Private Note are handled prior to this

  return $csl;
}

sub arrayCSL {
  my $csl = shift;

  # CSL properties that we need to turn into an array of
  # strings
  my @array_me = ("id", "language", "genre", "ISBN", "ISSN", "medium", "note", "references", "URL");

  # CSL properties that are having their type changed to number
  my @to_number = ("number-of-pages");

  # CSL properties that are having their type changed to string
  my @to_string = ("edition", "issue", "volume");

  # Iterate each property that we need to array-ify
  for my $arr_prop (@array_me) {

    # If it's defined
    if (defined($csl->{$arr_prop})) {

      # If it's not already an array
      if (ref($csl->{$arr_prop}) ne "ARRAY") {

        # Turn it into a string
        $csl->{$arr_prop} = $csl->{$arr_prop} . "";

        # Convert to an arrayref
        $csl->{$arr_prop} = [$csl->{$arr_prop}];
      }
      else {
        # It is an array, ensure it's an array of strings
        for my $arr_ele (@{$csl->{$arr_prop}}) {
          $arr_ele = $arr_ele . "";
        }
      }
    }
  }

  # Iterate each property that we're changing to a number
  for my $num_prop (@to_number) {

    # If it's defined
    if (defined($csl->{$num_prop})) {
      chomp $csl->{$num_prop};

      # If it looks like a number
      if (Scalar::Util::looks_like_number($csl->{$num_prop})) {

        # Force it to a number
        $csl->{$num_prop} = $csl->{$num_prop} + 0;
      }
      else {
        # We can't turn this value into a number, so drop it
        delete $csl->{$num_prop};
      }
    }
  }

  # Iterate each property that we're changing to a string
  for my $str_prop (@to_string) {

    # If it's defined
    if (defined($csl->{$str_prop})) {
      $csl->{$str_prop} = $csl->{$str_prop} . "";
    }
  }

  return $csl;
}

sub cleanCSL {
  my $csl = shift;

  # Dates
  my @dateFields = qw/accessed container event-date issued original-date submitted/;
  my $yyyy       = qr{^(\d{4})$}x;
  my $yyyymm     = qr{^(\d{4})-(\d{2})$}x;
  my $yyyymmdd   = qr{^(\d{4})-(\d{2})-(\d{2})$}x;
  my $isodate    = qr{^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}([+-][0-2]\d:[0-5]\d|Z)$}x;
  my $ddmmyyyy   = qr{^(\d{2})-(\d{2})-(\d{4})$}x;

  # Iterate each property that we need to date-ify
  for my $date_prop (@dateFields) {

    # If it's defined
    if (defined($csl->{$date_prop})) {

      # Strip Whitespace
      $csl->{$date_prop} = trim($csl->{$date_prop});

      # Coerce to ISO
      if ($csl->{$date_prop} =~ /$yyyymmdd/) {
        $csl->{$date_prop} = "$1-$2-$3T00:00:01Z";
      }
      elsif ($csl->{$date_prop} =~ /$ddmmyyyy/x) {
        $csl->{$date_prop} = "$3-$2-$1T00:00:01Z";
      }
      elsif ($csl->{$date_prop} =~ /$yyyymm/) {
        $csl->{$date_prop} = "$1-$2-01T00:00:01Z";
      }
      elsif ($csl->{$date_prop} =~ /$yyyy/) {
        $csl->{$date_prop} = "$1-01-01T00:00:01Z";
      }
      elsif (!($csl->{$date_prop} =~ /$isodate/)) {

        # Remove unrecognised format
        warn "unrecognised date format: $csl->{$date_prop}\n";
        delete $csl->{$date_prop};
      }
    }
  }

  # Language
  my @langFields = qw/language/;
  my $isolang    = qr{^[a-z]{2}-[A-Z]{2}$};

  # Iterate each property we need to language-ify
  for my $lang_prop (@langFields) {

    # If it's defined
    if (defined($csl->{$lang_prop})) {

      # Remove unrecognised format
      for (my $i = $#{$csl->{$lang_prop}}; --$i >= 0;) {
        if (!($csl->{$lang_prop}[$i] =~ /$isolang/)) {

          # Remove unrecognised format
          delete $csl->{$lang_prop}[$i];
        }
      }
    }
  }

  # Strings
  my @strings = (qw/chapter-number citation-number collection-number number-of-volumes page page-first/);

  # Force strings to strings
  for my $key (@strings) {
    if (exists($csl->{$key})) {
      $csl->{$key} = $csl->{$key} . "";
    }
  }

  # Numbers
  my @to_number = ("number-of-pages");

  # Force numbers to numbers
  for my $num_prop (@to_number) {

    # If it's defined
    if (defined($csl->{$num_prop})) {
      chomp $csl->{$num_prop};

      # If it looks like a number
      if (Scalar::Util::looks_like_number($csl->{$num_prop})) {

        # Force it to a number
        $csl->{$num_prop} = $csl->{$num_prop} + 0;
      }
      else {
        # We can't turn this value into a number, so drop it
        delete $csl->{$num_prop};
      }
    }
  }

  # Remove any empty/undefined fields
  for my $key (keys %{$csl}) {
    if (ref $csl->{$key} eq 'ARRAY' && !@{$csl->{$key}} || !defined($csl->{$key})) {
      delete $csl->{$key};
    }
  }

  return $csl;
}

sub trim {
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}
