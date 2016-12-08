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
    $self->__inherit_column_parent($parent)
      ; # FIXME: It may be better to insist on an ancestors method instead of the parent method.

    # flatten array of columns to make inheritable
    my @columns = map { (ref) ? @$_ : $_ } $columns;

    my @inherited_columns;
    for my $column (@columns) {
        if ( $self->has_column("inherited_$column") ) {
            $self->column_info($column)->{_inherit_info} = 2;
        }
        else {
            $self->column_info($column)->{_inherit_info} = 1;
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

    if ( $self->result_source->column_info($col)->{_inherit_info} == 2 ) {
        return $self->get_column("inherited_$col");
    }
    elsif ( exists $self->{_inherited_column}{$col} ) {
        return $self->{_inherited_column}{$col};
    }
    else {

        # ORIGINAL METHOD - Recursively looks up parent result
        #my $parent = $self->__inherit_column_parent;
        #my $value = $self->get_column($col);
        #
        #my $current = $self;
        #while (!$value) {
        #  $current = $current->$parent;
        #  if ($current) {
        #    $value = $current->get_column($col);
        #  }
        #  else {
        #    last;
        #  }
        #}

        # NEW METHOD - Grabs all ancestors in one go
        #my $value = $self->get_column($col);
        #unless (defined($value)) {
        #  my @ancestors = $self->ancestors->all;
        #  for my $ancestor (@ancestors) {
        #    $value = $ancestor->get_column($col);
        #    if (defined($value)) {
        #      last;
        #    }
        #  }
        #}

        # NEW CACHED METHOD
        $self->_populate_inherited_columns;

        return $self->{_inherited_column}{$col};
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
    }
    else {
        $values = { $self->get_columns };
    }

    my $missing;
    foreach my $key ( keys %{$values} ) {
        if ( exists $self->result_source->column_info($key)->{_inherit_info}
            && $self->result_source->column_info($key)->{_inherit_info} == 2 )
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

    my @ancestors = $self->ancestors->all;
    for my $ancestor (@ancestors) {
        foreach my $index ( keys %{$missing} ) {
            my $value;
            if ( $attr->{'inflate'}
                && exists $self->result_source->column_info($index)
                ->{_inflate_info} )
            {
                $value = $ancestor->get_inflated_column($index);
            }
            else {
                $value = $ancestor->get_column($index);
            }

            if ( defined($value) ) {
                $values->{$index} = $value;
                delete $missing->{$index};
            }
        }
    }

    return %{$values};
}

# FIXME: As above, this currently returns all columns, not a limited set as may have been requetsed in the original resultSet->search.
# FIXME: There is no column caching here.
sub get_inflated_inherited_columns {
    my ($self) = @_;
    return $self->get_inherited_columns( { inflate => 1 } );
}

sub _populate_inherited_columns {
    my ($self) = @_;

    my @columns = $self->result_source->columns;

    my $missing;
    foreach my $column (@columns) {
        next
          unless
          exists $self->result_source->column_info($column)->{_inherit_info};
        next
          if $self->result_source->column_info($column)->{_inherit_info} == 2;
        $missing->{$column} = 1;
    }

    my @ancestors = $self->ancestors->all;
    unshift @ancestors, ($self);
    for my $ancestor (@ancestors) {
        foreach my $column ( keys %{$missing} ) {
            my $value = $ancestor->get_column($column);

            if ( defined($value) ) {
                $self->{_inherited_column}{$column} = $value;
                delete $missing->{$column};
            }
        }

        last unless ( keys %{$missing} );
    }

    for my $column ( keys %{$missing} ) {
        $self->{_inherited_column}{$column} = undef;
    }

    return;
}

1;
