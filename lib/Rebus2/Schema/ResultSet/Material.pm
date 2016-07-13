package Rebus2::Schema::ResultSet::Material;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw( Helper::ResultSet::CorrelateRelationship ));

=head3 with_selected

Description: Custom correlation filter to add selected field for frbr_equivalents when passed a list_id

Requires: list_id

=cut

#sub with_selected {
#  my ($self, $list_id) = @_;
#
#  return $self->search(
#    undef,
#    {
#      '+columns' =>
#        {selected => $self->correlate('frbr_list_materials')->search({list_id => $list_id})->count_rs->as_query}
#    }
#  );
#}

sub with_selected {
  my ($self, $list_id) = @_;

  return $self->search(
    undef,
    {
      '+columns' =>
        {selected => {exists => $self->correlate('frbr_list_materials')->search({list_id => $list_id})->as_query}}
    }
  );
}

1;
