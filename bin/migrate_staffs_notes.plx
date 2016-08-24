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
use List::Util qw/any/;
use Scalar::Util 'looks_like_number';

use HTML::Entities qw/decode_entities/;
use Term::ProgressBar 2.00;

use Mojo::JSON qw(decode_json encode_json);

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

# Begin Migration
say "Beggining migration...";

# Sequence, Material, MaterialType, MaterialRating, MaterialLabel, Tag, TagLink, MetadataSource
my $total = $rebus1->resultset('Sequence')->count;
my $material_progress =
  Term::ProgressBar->new( { name => "Importing Materials", count => $total } );
$material_progress->minor(0);
my $next_update  = 0;
my $current_line = 0;

my @rl1_sequenceResults = $rebus1->resultset('Sequence')
  ->search( undef, { order_by => { -asc => [qw/list_id rank/] } } )->all;

for my $rl1_sequence (@rl1_sequenceResults) {

    # Update Progress
    $current_line++;
    $next_update = $material_progress->update($current_line)
      if $current_line > $next_update;

    # Get material
    my $rl1_material = $rebus1->resultset('Material')
      ->find( { material_id => $rl1_sequence->material_id } );

    if ( defined($rl1_material) ) {

        # Handle Note/Private Note
        if ( $rl1_material->material_type_id == 12 ) {
            next;
        }
        elsif ( $rl1_material->material_type_id == 13 ) {
            next;
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
            my ( $owner, $owner_uuid );
            if ( $csl->{type} eq 'article' || $csl->{type} eq 'chapter' ) {
                next;
            }
            elsif (defined( $rl1_material->print_sysno )
                && $rl1_material->print_sysno ne ''
                && !( $rl1_material->print_sysno =~ /^\s*$/ ) )
            {
                $owner      = $config->{'connector'};
                $owner_uuid = $rl1_material->print_sysno;
            }
            elsif (defined( $rl1_material->elec_sysno )
                && $rl1_material->elec_sysno ne ''
                && !( $rl1_material->elec_sysno =~ /^\s*$/ ) )
            {
                $owner      = $config->{'connector'};
                $owner_uuid = $rl1_material->elec_sysno;
            }
            else {
                next;
            }

            my $eBook =
              ( $rl1_material->material_type_id == 10 )
              ? Mojo::JSON->true
              : Mojo::JSON->false;

            # Add material
            my $rl2_material =
              addMaterial( $rl1_material->in_stock_yn eq 'y' ? 1 : 0,
                $csl, $owner, $owner_uuid, $eBook );

            # Get list note
            my $rl1_note = $rl1_material->note;
            next if !defined($rl1_note);

            # Add List Local note
            my $rl2_sequence = $rebus2->resultset('ListMaterial')->find(
                {
                    list_id     => $rl1_sequence->list_id,
                    material_id => $rl2_material->id
                },
                { key => 'primary' }
            );

            $rl2_sequence->update(
                { note => $rl2_sequence->note . " " . $rl1_note } )
              if ( defined($rl2_sequence) && defined($rl1_note) );
        }
    }
}

# Routines
sub addMaterial {
    my ( $in_stock, $metadata, $owner, $owner_uuid, $eBook ) = @_;

    # Local Material
    if ( $owner_uuid eq '1-' ) {
        my $title      = $metadata->{'title'};
        my $type       = $metadata->{'type'};
        my $title_json = { title => $title, type => $type };
        my $json_title = encode_json $title_json;
        my $found      = $rebus2->resultset('Material')
          ->search( { metadata => { '@>' => $json_title } } );
        my ( $isbn, $issn );
        if ( $found->count == 1 ) {
            my $new_material = $found->next;
            return $new_material;
        }
        elsif ( $found->count >= 1 ) {
            $isbn = $metadata->{ISBN} if exists( $metadata->{ISBN} );
            if ($isbn) {
                my $isbn_json = { ISBN => $isbn };
                my $json_isbn = encode_json $isbn_json;
                my $found2 =
                  $found->search( { metadata => { '@>' => $json_isbn } } );
                if ( $found2->count == 1 ) {
                    my $new_material = $found2->next;
                    return $new_material;
                }
            }
            $issn = $metadata->{ISSN} if exists( $metadata->{ISSN} );
            if ($issn) {
                my $issn_json = { ISSN => $issn };
                my $json_issn = encode_json $issn_json;
                my $found2 =
                  $found->search( { metadata => { '@>' => $json_issn } } );
                if ( $found2->count == 1 ) {
                    my $new_material = $found2->next;
                    return $new_material;
                }
            }
        }

        # Not Found
        $metadata->{'id'} = [$owner_uuid];
        my $new_material = $rebus2->resultset('Material')->create(
            {
                in_stock   => $in_stock,
                metadata   => $metadata,
                owner      => $owner,
                owner_uuid => undef,
                electronic => $eBook
            }
        );

        my $metadata = $new_material->metadata;
        my $id       = '1-' . $new_material->id;
        $metadata->{'id'} = [$id];
        $new_material->update( { metadata => $metadata, owner_uuid => $id } );

        return $new_material;
    }

    # Remote Material
    $owner_uuid =~ s/\^/,/g;
    my $materialResult = $rebus2->resultset('Material')
      ->find( { owner => $owner, owner_uuid => $owner_uuid }, { rows => 1 } );

    if ( defined($materialResult) ) {
        return $materialResult;
    }
    else {
        $metadata->{'id'} = [$owner_uuid];

        my $new_material = $rebus2->resultset('Material')->create(
            {
                in_stock   => Mojo::JSON->true,
                metadata   => $metadata,
                owner      => $owner,
                owner_uuid => $owner_uuid,
                electronic => $eBook
            }
        );

        return $new_material;
    }
}

sub mapCSL {
    my $materialResult = shift;
    my $csl;

    my $material = { $materialResult->get_columns };
    for my $field ( keys %{$material} ) {
        delete $material->{$field}
          unless ( defined( $material->{$field} )
            && $material->{$field} ne ''
            && $material->{$field} !~ /^\s*$/ );
    }

    # Title
    $csl->{title} = $material->{title} if exists( $material->{title} );

    # Authors
    $csl->{author} = [];
    push @{ $csl->{author} }, { literal => $material->{authors} }
      if exists( $material->{authors} );

    # Edition
    $csl->{edition} = $material->{edition} if exists( $material->{edition} );

    # Volume
    $csl->{volume} = $material->{volume} if exists( $material->{volume} );

    # Issue
    $csl->{issue} = $material->{issue} if exists( $material->{issue} );

    # Publisher
    $csl->{publisher} = $material->{publisher}
      if exists( $material->{publisher} );

    # Publication Date
    $csl->{issued} = $material->{publication_date}
      if exists( $material->{publication_date} );

    # Publication Place
    $csl->{'publisher-place'} = $material->{publication_place}
      if exists( $material->{publication_place} );

    # Public Note
    $csl->{'note'} = $material->{note} if exists( $material->{note} );

    # URL
    $csl->{'URL'} = $material->{url} if exists( $material->{url} );

    # Per Type Mappings

    # Start Page
    $material->{spage} =~ s/pp\.//g if exists( $material->{spage} );

    # End Page
    $material->{epage} =~ s/pp\.//g if exists( $material->{epage} );

    # Types:
    # 1=Book
    if ( $materialResult->material_type_id == 1 ) {

        # Type
        $csl->{'type'} = 'book';

        # Secondary Title
        $csl->{'collection-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Secondary Authors
        $csl->{editor} = [];
        push @{ $csl->{editor} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );

        # Start Page -> Number of Pages
        $material->{spage} =~ s/\D+//g if exists( $material->{spage} );
        $csl->{'number-of-pages'} = $material->{spage}
          if exists( $material->{spage} );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 2=Chapter
    elsif ( $materialResult->material_type_id == 2 ) {

        # Type
        $csl->{'type'} = 'chapter';

        # Secondary Title
        $csl->{'container-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Start Page
        $csl->{'page-first'} = $material->{spage}
          if exists( $material->{spage} );

        # End Page
        $material->{epage} =~ s/\D+//g if exists( $material->{epage} );
        delete $material->{epage}
          if ( exists( $material->{epage} ) && $material->{epage} eq '' );
        $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
          if ( exists( $material->{epage} )
            && exists( $material->{spage} )
            && looks_like_number( $material->{spage} ) );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 3=Journal
    elsif ( $materialResult->material_type_id == 3 ) {

        # Type
        $csl->{'type'} = 'journal';

        # Secondary Authors
        push @{ $csl->{author} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );

        # ISSN
        $csl->{ISSN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISSN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 4=Article
    elsif ( $materialResult->material_type_id == 4 ) {

        # Type
        $csl->{'type'} = 'article';

        # Secondary Title
        $csl->{'container-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Start Page
        $csl->{'page-first'} = $material->{spage}
          if exists( $material->{spage} );

        # End Page
        $material->{epage} =~ s/\D+//g if exists( $material->{epage} );
        delete $material->{epage}
          if ( exists( $material->{epage} ) && $material->{epage} eq '' );
        $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
          if ( exists( $material->{epage} )
            && exists( $material->{spage} )
            && looks_like_number( $material->{spage} ) );

        # ISSN
        $csl->{ISSN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISSN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 5=Scan
    elsif ( $materialResult->material_type_id == 5 ) {

        # Type
        $csl->{'type'} = 'entry';

        # Secondary Title
        $csl->{'container-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Start Page
        $csl->{'page-first'} = $material->{spage}
          if exists( $material->{spage} );

        # End Page
        $material->{epage} =~ s/\D+//g if exists( $material->{epage} );
        delete $material->{epage}
          if ( exists( $material->{epage} ) && $material->{epage} eq '' );
        $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
          if ( exists( $material->{epage} )
            && exists( $material->{spage} )
            && looks_like_number( $material->{spage} ) );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 7=Link
    elsif ( $materialResult->material_type_id == 7 ) {

        # Type
        $csl->{'type'} = 'webpage';

        # Secondary Title
        $csl->{'container-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Secondary Authors
        push @{ $csl->{author} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );
    }

    # 9=Other
    elsif ( $materialResult->material_type_id == 9 ) {

        # Type
        $csl->{'type'} = 'entry';

        # Secondary Title
        $csl->{'container-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Start Page
        $csl->{'page-first'} = $material->{spage}
          if exists( $material->{spage} );

        # End Page
        $material->{epage} =~ s/\D+//g if exists( $material->{epage} );
        delete $material->{epage}
          if ( exists( $material->{epage} ) && $material->{epage} eq '' );
        $csl->{'number-of-pages'} = $material->{epage} - $material->{spage}
          if ( exists( $material->{epage} )
            && exists( $material->{spage} )
            && looks_like_number( $material->{spage} ) );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 10=eBook
    elsif ( $materialResult->material_type_id == 10 ) {

        # Type
        $csl->{'type'} = 'book';

        # Secondary Title
        $csl->{'collection-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Secondary Authors
        $csl->{editor} = [];
        push @{ $csl->{editor} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );

        # Start Page -> Number of Pages
        $material->{spage} =~ s/\D+//g if exists( $material->{spage} );
        $csl->{'number-of-pages'} = $material->{spage}
          if exists( $material->{spage} );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 11=AV
    elsif ( $materialResult->material_type_id == 11 ) {

        # Type
        $csl->{'type'} = 'broadcast';

        # Secondary Title
        $csl->{'collection-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Secondary Authors
        $csl->{editor} = [];
        push @{ $csl->{editor} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );
    }

    # 12=Note
    # 13=Private Note
    # NONE
    else {
        # Type
        $csl->{'type'} = 'book';

        # Secondary Title
        $csl->{'collection-title'} = $material->{secondary_title}
          if exists( $material->{secondary_title} );

        # Secondary Authors
        $csl->{editor} = [];
        push @{ $csl->{editor} }, { literal => $material->{secondary_authors} }
          if exists( $material->{secondary_authors} );

        # Start Page -> Number of Pages
        $material->{spage} =~ s/\D+//g if exists( $material->{spage} );
        $csl->{'number-of-pages'} = $material->{spage}
          if exists( $material->{spage} );

        # ISBN
        $csl->{ISBN} = $material->{elec_control_no}
          if exists( $material->{elec_control_no} );
        $csl->{ISBN} = $material->{print_control_no}
          if exists( $material->{print_control_no} );
    }

    # 12=Note and 13=Private Note are handled prior to this

    return $csl;
}

sub arrayCSL {
    my $csl = shift;

    # CSL properties that we need to turn into an array of
    # strings
    my @array_me = (
        "id",   "language",   "genre", "ISBN", "ISSN", "medium",
        "note", "references", "URL"
    );

    # CSL properties that are having their type changed to number
    my @to_number = ("number-of-pages");

    # CSL properties that are having their type changed to string
    my @to_string = ( "edition", "issue", "volume" );

    # Iterate each property that we need to array-ify
    for my $arr_prop (@array_me) {

        # If it's defined
        if ( defined( $csl->{$arr_prop} ) ) {

            # If it's not already an array
            if ( ref( $csl->{$arr_prop} ) ne "ARRAY" ) {

                # Turn it into a string
                $csl->{$arr_prop} = $csl->{$arr_prop} . "";

                # Convert to an arrayref
                $csl->{$arr_prop} = [ $csl->{$arr_prop} ];
            }
            else {
                # It is an array, ensure it's an array of strings
                for my $arr_ele ( @{ $csl->{$arr_prop} } ) {
                    $arr_ele = $arr_ele . "";
                }
            }
        }
    }

    # Iterate each property that we're changing to a number
    for my $num_prop (@to_number) {

        # If it's defined
        if ( defined( $csl->{$num_prop} ) ) {
            chomp $csl->{$num_prop};

            # If it looks like a number
            if ( Scalar::Util::looks_like_number( $csl->{$num_prop} ) ) {

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
        if ( defined( $csl->{$str_prop} ) ) {
            $csl->{$str_prop} = $csl->{$str_prop} . "";
        }
    }

    return $csl;
}

sub cleanCSL {
    my $csl = shift;

    # Dates
    my @dateFields =
      qw/accessed container event-date issued original-date submitted/;
    my $yyyy     = qr{^(\\d{4})$};
    my $yyyymm   = qr{^(\\d{4})-(\\d{2})$};
    my $yyyymmdd = qr{^(\\d{4})-(\\d{2})-(\\d{2})$};
    my $isodate  = qr{^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$};

    # Iterate each property that we need to date-ify
    for my $date_prop (@dateFields) {

        # If it's defined
        if ( defined( $csl->{$date_prop} ) ) {

            # Coerce to ISO
            if ( $csl->{$date_prop} =~ /$yyyymmdd/ ) {
                $csl->{$date_prop} = "$1-$2-$3T00:00:01Z";
            }
            elsif ( $csl->{$date_prop} =~ /$yyyymm/ ) {
                $csl->{$date_prop} = "$1-$2-01T00:00:01Z";
            }
            elsif ( $csl->{$date_prop} =~ /$yyyy/ ) {
                $csl->{$date_prop} = "$1-01-01T00:00:01Z";
            }
            elsif ( !( $csl->{$date_prop} =~ /$isodate/ ) ) {

                # Remove unrecognised format
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
        if ( defined( $csl->{$lang_prop} ) ) {

            # Remove unrecognised format
            for ( my $i = $#{ $csl->{$lang_prop} } ; --$i >= 0 ; ) {
                if ( !( $csl->{$lang_prop}[$i] =~ /$isolang/ ) ) {

                    # Remove unrecognised format
                    delete $csl->{$lang_prop}[$i];
                }
            }
        }
    }

    # Strings
    my @strings = (
        qw/chapter-number citation-number collection-number number-of-volumes page page-first/
    );

    # Force strings to strings
    for my $key (@strings) {
        if ( exists( $csl->{$key} ) ) {
            $csl->{$key} = $csl->{$key} . "";
        }
    }

    # Numbers
    my @to_number = ("number-of-pages");

    # Force numbers to numbers
    for my $num_prop (@to_number) {

        # If it's defined
        if ( defined( $csl->{$num_prop} ) ) {
            chomp $csl->{$num_prop};

            # If it looks like a number
            if ( Scalar::Util::looks_like_number( $csl->{$num_prop} ) ) {

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
    for my $key ( keys %{$csl} ) {
        if ( ref $csl->{$key} eq 'ARRAY' && !@{ $csl->{$key} }
            || !defined( $csl->{$key} ) )
        {
            delete $csl->{$key};
        }
    }

    return $csl;
}
