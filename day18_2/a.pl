#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;

my $MAX_X;
my $MAX_Y;

$Data::Dumper::Sortkeys = 1;

sub p {
    say Dumper $_[0];
}

sub read_file {
    my ($file_name) = @_;

    my $content = '';

    open(my $fh, '<', $file_name) or die "Could not open file '$file_name' $!";

    while (my $line = <$fh>) {
        $content .= $line;
    }

    close($fh);

    return $content;
}

=head2 get_field

$field[0] - first row
$field[0]->[2] - 3rd element if 1st row

$field[$y]->[$x]

(x,y)

:

    0,0     1,0     2,0     # $field[0]
    0,1     1,1     2,1     # $field[1]

:

    my @field = get_field($content);

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            print $field[$y]->[$x];
            print " ";
        }
        say '';
    }

=cut

sub get_field {
    my ($content) = @_;

    my @field;

    foreach my $row (split /\n/, $content) {
        my @elements = split /\s+/, $row;
        push @field, \@elements;
    }

    return @field;
}

sub min {
    my ($one, $two) = @_;

    return $one < $two ? $one : $two;
}

sub max {
    my ($one, $two) = @_;

    return $one > $two ? $one : $two;
}

sub neighbors {
    my ($x, $y) = @_;
    return (
        [$x - 1, $y], # Left
        [$x + 1, $y], # Right
        [$x, $y - 1], # Up
        [$x, $y + 1], # Down
    );
}

sub is_within_bounds {
    my ($x, $y, $max_x, $max_y) = @_;
    return $x >= 0 && $x <= $max_x && $y >= 0 && $y <= $max_y;
}

sub dijkstra {
    my ($field, $start, $end) = @_;

    my %distances;
    my %visited;
    my @queue = ($start); # Priority queue (FIFO list for simplicity)

    $distances{"$start->[0],$start->[1]"} = 0;

    while (@queue) {
        # Get the node with the smallest distance
        my ($x, $y) = @{shift @queue};
        next if $visited{"$x,$y"}++;

        # Check if we reached the destination
        if ($x == $end->[0] && $y == $end->[1]) {
            return $distances{"$x,$y"};
        }

        foreach my $neighbor (neighbors($x, $y)) {
            my ($nx, $ny) = @$neighbor;
            next if !is_within_bounds($nx, $ny, $MAX_X, $MAX_Y) || $field->[$ny]->[$nx] eq '#';

            my $new_dist = $distances{"$x,$y"} + 1;
            if (!exists $distances{"$nx,$ny"} || $new_dist < $distances{"$nx,$ny"}) {
                $distances{"$nx,$ny"} = $new_dist;
                push @queue, [$nx, $ny];
            }
        }
    }

    return -1; # Return -1 if no path is found
}

sub main {

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my $j = 1024;
    my $prev_line;;
    my $last_line;

    MAIN:
    while (1) {
        say $j;
        my @field;

        $MAX_X = 70;
        $MAX_Y = 70;

        foreach my $y (0..$MAX_Y) {
            foreach my $x (0..$MAX_X) {
                $field[$y]->[$x] = '.';
            }
        }

        my $i = 0;
        foreach my $line (split /\n/, $content) {
            $last_line = $line;
            $i++;
            last if $i > $j;
            my ($x, $y) = split /,/, $line;

            $field[$y]->[$x] = '#';
        }

#        foreach my $y (0..$MAX_Y) {
#            foreach my $x (0..$MAX_X) {
#               print $field[$y]->[$x];
#            }
#            say '';
#        }

        my $start = [0, 0];
        my $end = [$MAX_X, $MAX_Y];

        my $answer = dijkstra(\@field, $start, $end);
        if ($answer == -1) {
            say $j;
            say $prev_line;
            last MAIN;
        }
        $j++;
        $prev_line = $last_line;
    }

}
main();
__END__
