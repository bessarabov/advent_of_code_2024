use strict;
use warnings;
use Data::Dumper;

# Step 1: Create a graph from the maze
sub create_graph {
    my ($maze) = @_;
    my $rows = scalar @$maze;
    my $cols = scalar @{$maze->[0]};
    my %graph;

    for my $x (0 .. $rows - 1) {
        for my $y (0 .. $cols - 1) {
            my $node_key = "${x}_${y}";
            my %neighbors;

            for my $dir ([-1, 0], [1, 0], [0, -1], [0, 1]) { # Up, Down, Left, Right
                my ($nx, $ny) = ($x + $dir->[0], $y + $dir->[1]);
                if ($nx >= 0 && $nx < $rows && $ny >= 0 && $ny < $cols) {
                    my $neighbor_key = "${nx}_${ny}";
                    $neighbors{$neighbor_key} = $maze->[$nx][$ny];
                }
            }
            $graph{$node_key} = \%neighbors;
        }
    }
    return \%graph;
}

# Step 2: Find the minimum cost path using Dijkstra's algorithm
sub find_min_cost {
    my ($graph, $maze, $start, $goal) = @_;
    my $rows = scalar @$maze;
    my $cols = scalar @{$maze->[0]};

    # Convert start and goal to node keys
    my $start_key = join('_', @$start);
    my $goal_key = join('_', @$goal);

    # Distance hash initialized to infinity
    my %dist = map { $_ => "inf" } keys %$graph;
    $dist{$start_key} = $maze->[$start->[0]][$start->[1]];

    # Priority queue
    my @pq = ([$dist{$start_key}, $start_key]); # (cost, node_key)

    while (@pq) {
        # Find and remove the element with the smallest cost
        @pq = sort { $a->[0] <=> $b->[0] } @pq;
        my ($current_cost, $current_key) = @{shift @pq};

        # If we reach the goal, return the cost
        return $current_cost if $current_key eq $goal_key;

        # Process neighbors
        for my $neighbor_key (keys %{$graph->{$current_key}}) {
            my $new_cost = $current_cost + $graph->{$current_key}{$neighbor_key};
            if ($new_cost < $dist{$neighbor_key}) {
                $dist{$neighbor_key} = $new_cost;
                push @pq, [$new_cost, $neighbor_key];
            }
        }
    }

    return -1; # If goal is not reachable
}

# Example usage
my @maze = (
    [1, 3, 1],
    [1, 5, 1],
    [4, 2, 1],
);
my $start = [0, 0];  # Starting point (row 0, column 0)
my $goal = [2, 2];   # Goal point (row 2, column 2)

# Create the graph
my $graph = create_graph(\@maze);
print "Graph representation:\n";
print Dumper($graph);

# Find the minimum cost path
my $min_cost = find_min_cost($graph, \@maze, $start, $goal);
print "Minimum cost path: $min_cost\n";

