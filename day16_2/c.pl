#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min);

# Read input file
my $file = shift @ARGV or die "Usage: perl a.pl input\n";
open my $fh, '<', $file or die "Cannot open input file: $!\n";
my @maze = <$fh>;
chomp @maze;
close $fh;

# Parse the maze to find start and end points
my ($start_x, $start_y, $end_x, $end_y);
my @directions = ([0, 1], [1, 0], [0, -1], [-1, 0]); # East, South, West, North
for my $y (0..$#maze) {
    for my $x (0..length($maze[$y]) - 1) {
        my $tile = substr($maze[$y], $x, 1);
        if ($tile eq 'S') {
            ($start_x, $start_y) = ($x, $y);
        } elsif ($tile eq 'E') {
            ($end_x, $end_y) = ($x, $y);
        }
    }
}

# Breadth-first search to find all best paths
my %visited;
my @queue = ([$start_x, $start_y, 0, 0, []]); # x, y, score, direction, path
my $min_score = undef;
my @best_paths;

while (@queue) {
    my ($x, $y, $score, $dir, $path) = @{shift @queue};
    next if $visited{"$x,$y,$dir"}++;

    # Update path
    push @$path, [$x, $y];

    # Check if we reached the end
    if ($x == $end_x && $y == $end_y) {
        if (!defined $min_score || $score < $min_score) {
            $min_score = $score;
            @best_paths = ($path);
        } elsif ($score == $min_score) {
            push @best_paths, $path;
        }
        next;
    }

    # Explore neighbors
    for my $i (0..$#directions) {
        my ($dx, $dy) = @{$directions[$i]};
        my $nx = $x + $dx;
        my $ny = $y + $dy;
        my $rotation_cost = ($i == $dir) ? 0 : 1000;
        my $new_score = $score + 1 + $rotation_cost;
        if ($maze[$ny] && substr($maze[$ny], $nx, 1) ne '#') {
            push @queue, [$nx, $ny, $new_score, $i, [@$path]];
        }
    }
}

# Mark tiles that are part of any best path
my %best_tiles;
for my $path (@best_paths) {
    for my $tile (@$path) {
        $best_tiles{"$tile->[0],$tile->[1]"} = 1;
    }
}

# Count and mark tiles that are part of any best path
my $count = 0;
for my $y (0..$#maze) {
    for my $x (0..length($maze[$y]) - 1) {
        if ($best_tiles{"$x,$y"}) {
            substr($maze[$y], $x, 1, 'O');
            $count++;
        }
    }
}

# Print the updated maze and result
print join("\n", @maze), "\n";
print "Number of tiles part of at least one best path: $count\n";

