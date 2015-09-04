package DBIx::Class::Tree::Inheritance;
use strict;
use warnings;

use base 'DBIx::Class::Row';
use namespace::clean;

__PACKAGE__->mk_classdata( __inherit_column_parent => "" );

# specify columns to allow inheritance
sub inheritable_columns {
    my ( $self, $parent, $columns ) = @_;

    #
    $self->__inherit_column_parent($parent);

    # flatten array of columns to make inheritable
    my @columns = map { (ref) ? @$_ : $_ } $columns;

    my @inherited_columns;
    for my $column (@columns) {
        if ( $self->has_column("inherited_$column") ) {
            $self->column_info($column)->{_inherit_info} = '2';
        } else {
            $self->column_info($column)->{_inherit_info} = '1';
            push @inherited_columns, "inherited_" . $column;
        }
    }

    # make accessors
    $self->mk_group_accessors( inherited_column => @inherited_columns );

    return 1;
}

# should return the first populated column value walking backwards up the tree.
sub get_inherited_column {
    my ( $self, $col ) = @_;

    $col =~ s/inherited_//g;

    $self->throw_exception("$col is not an inheritable column")
      unless exists $self->result_source->column_info($col)->{_inherit_info};

    if ( $self->result_source->column_info($col)->{_inherit_info} == '2' ) {
        return $self->get_column("inherited_$col");
    }
    else {

        my $parent = $self->__inherit_column_parent;

        my $value = $self->get_column($col);

        my $current = $self;
        while ( !$value ) {
            $current = $current->$parent;
            $value   = $current->get_column($col);
        }

        return $value;
    }
}

sub set_inherited_column {
    die "NO";
}

# FIXME: This currently does not limit on the columns requested.. it instead always returns all columns
# FIXME: There is no column caching here.
sub get_inherited_columns {
    my ( $self, $attr ) = @_;

    my $values;
    if ( $attr->{'inflate'} ) {
        $values = { $self->get_inflated_columns };
    } else {
        $values = { $self->get_columns };
    }

    my $missing;
    foreach my $key ( keys %{$values} ) {
        if ( exists $self->result_source->column_info($key)->{_inherit_info}
            && $self->result_source->column_info($key)->{_inherit_info} == '2' )
        {
            $values->{"$key"} = $values->{"inherited_$key"};
            delete $values->{"inherited_$key"};
        }
        next if defined( $values->{$key} );
        next
          unless
            exists $self->result_source->column_info($key)->{_inherit_info};

        $missing->{$key} = 1;
    }

    my $parent  = $self->__inherit_column_parent;
    my $current = $self;
    my $run     = 0;
    while ( keys %{$missing} ) {
        $run++;
        $current = $current->$parent;
        if ( defined($current) ) {
            foreach my $index ( keys %{$missing} ) {
                my $value;
                if ( $attr->{'inflate'} && exists $self->result_source->column_info($index)->{_inflate_info} ) {
                    $value = $current->get_inflated_column($index);
                } else {
                    $value = $current->get_column($index);
                }
                if ( defined($value) ) {
                    $values->{$index} = $value;
                    delete $missing->{$index};
                }
            }
        }
        else {
            last;
        }
    }

    return %{$values};
}

# FIXME: As above, this currently returns all columns, not a limited set as may have been requetsed in the original resultSet->search.
# FIXME: There is no column caching here.
sub get_inflated_inherited_columns {
    my ($self) = @_;


#    my $loaded_colinfo = $self->result_source->columns_info;
#    $self->has_column_loaded($_)
#      or delete $loaded_colinfo->{$_}
#      for keys %$loaded_colinfo;
#
#    my %cols_to_return = ( %{ $self->{_column_data} }, %$loaded_colinfo );
#
#    map {
#        $_ => (
#            (
#                !exists $loaded_colinfo->{$_}
#                  or ( exists $loaded_colinfo->{$_}{accessor}
#                    and !defined $loaded_colinfo->{$_}{accessor} )
#            ) ? $self->get_inherited_column($_)
#            : $self ->${
#                \(
#                    defined $loaded_colinfo->{$_}{accessor}
#                    ? $loaded_colinfo->{$_}{accessor}
#                   : $_
#                 )
#              }
#          )
#   } keys %cols_to_return;

    return $self->get_inherited_columns( { inflate => 1 } );
}

1;
