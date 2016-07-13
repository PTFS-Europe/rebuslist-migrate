use utf8;

package Rebus2::Schema::ResultSet::Report;

=head1 NAME

Rebus2::Schema::ResultSet::Report

=cut

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(Helper::ResultSet::CorrelateRelationship));

=head1 CORRELATE RELATIONS

=head2 with_last_run

Type: special case of 'runs'

Related object: L<Rebus2::Schema::Result::ReportRun>

=cut

# FIXME: Clever `hack` added to allow 'order_by => last_run_completed' that will be incorporated better upstream in the helper one day
sub with_last_run {
  my $self = shift;

  $self->search(
    undef,
    {
      '+columns' => {
        last_run_id => $self->correlate('runs')->search(undef, {rows => 1, order_by => {-desc => [qw/completed/]}})
          ->get_column('id')->as_query,
        last_run_completed => do {
          my $x = $self->correlate('runs')->search(undef, {rows => 1, order_by => {-desc => [qw/completed/]}})
            ->get_column('completed')->as_query;
          @{${$x}}[0] .= " AS last_run_completed";
          $x;
        },
      }
    }
  );
}

1;
