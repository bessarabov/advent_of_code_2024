use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;
use List::Util qw(min);

my $MAX_X;
my $MAX_Y;

$Data::Dumper::Sortkeys = 1;

sub p {
    say Dumper $_[0];
}

sub read_file {
    my ($file_name) = @_;
    open(my $fh, '<', $file_name) or die "Could not open file '$file_name' $!";
    my $content = do { local $/; <$fh> };
    close($fh);
    return $content;
}

sub get_field {
    my ($content) = @_;
    my @field;
    foreach my $row (split /\n/, $content) {
        my @elements = split //, $row;
        push @field, \@elements;
    }
    return @field;
}

sub output_field {
    my ($f) = @_;
    my @field = @{$f};
    foreach my $row (@field) {
        foreach my $value (@$row) {
            print $value eq '#' ? '█' : $value;
        }
        say '';
    }
}

sub heuristic {
    my ($x1, $y1, $x2, $y2) = @_;
    return abs($x1 - $x2) + abs($y1 - $y2);
}

sub a_star {
    my ($field, $start_x, $start_y, $end_x, $end_y) = @_;

    # Directions: [dx, dy, direction_index]
    my @directions = (
        [0, -1, 'N'],  # North
        [1,  0, 'E'],  # East
        [0,  1, 'S'],  # South
        [-1, 0, 'W']   # West
    );

    my %visited;
    my @queue = ([0, $start_x, $start_y, 1, heuristic($start_x, $start_y, $end_x, $end_y)]); # [cost, x, y, dir, priority]

    while (@queue) {
        @queue = sort { $a->[4] <=> $b->[4] } @queue; # Sort by priority (cost + heuristic)
        my ($cost, $x, $y, $dir, $priority) = @{shift @queue};

        # If we've reached the end
        return $cost if $x == $end_x && $y == $end_y;

        # Mark the state as visited
        $visited{"$x,$y,$dir"} = 1;

        # Move forward
        my $dx = $directions[$dir][0];
        my $dy = $directions[$dir][1];
        my $nx = $x + $dx;
        my $ny = $y + $dy;

        if ($nx >= 0 && $ny >= 0 && $nx <= $MAX_X && $ny <= $MAX_Y && !$visited{"$nx,$ny,$dir"} && $field->[$ny]->[$nx] ne '#') {
            push @queue, [$cost + 1, $nx, $ny, $dir, $cost + 1 + heuristic($nx, $ny, $end_x, $end_y)];
        }

        # Rotate clockwise and counterclockwise
        foreach my $rotation ([-1, -1], [1, 1]) {
            my $new_dir = ($dir + $rotation->[0]) % 4;
            $new_dir += 4 if $new_dir < 0; # Handle negative modulo
            unless ($visited{"$x,$y,$new_dir"}) {
                push @queue, [$cost + 1000, $x, $y, $new_dir, $cost + 1000 + heuristic($x, $y, $end_x, $end_y)];
            }
        }
    }

    return -1; # If no path is found
}

sub main {
    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);

    $MAX_X = scalar(@{$field[0]}) - 1;
    $MAX_Y = scalar(@field) - 1;

    my ($start_x, $start_y, $end_x, $end_y);
    foreach my $y (0 .. $MAX_Y) {
        foreach my $x (0 .. $MAX_X) {
            my $value = $field[$y]->[$x];
            if ($value eq 'S') {
                ($start_x, $start_y) = ($x, $y);
            }
            if ($value eq 'E') {
                ($end_x, $end_y) = ($x, $y);
            }
        }
    }

    $field[$start_y]->[$start_x] = '.';
    $field[$end_y]->[$end_x] = '.';

    output_field(\@field);

    my $result = a_star(\@field, $start_x, $start_y, $end_x, $end_y);

    if ($result >= 0) {
        say "Minimum cost to traverse the maze: $result";
    } else {
        say "No path found.";
    }
}

main();
__END__

