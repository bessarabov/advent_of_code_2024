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
        my @elements = split //, $row;
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

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);
#    p \@field;

    $MAX_X = scalar(@{$field[0]})-1;
    $MAX_Y = scalar(@field)-1;

    my $start_x;
    my $start_y;

    my $end_x;
    my $end_y;

    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $value = $field[$y]->[$x];
            if ($value eq 'S') {
                $start_x = $x;
                $start_y = $y;
            }
            if ($value eq 'E') {
                $end_x = $x;
                $end_y = $y;
            }
        }
    }

    $field[$start_y]->[$start_x] = '.';
    $field[$end_y]->[$end_x] = '.';

#    p {
#        start_x => $start_x,
#        start_y=> $start_y,
#    };
#
#    p {
#        end_x => $end_x,
#        end_y=> $end_y,
#    };

    my $cur_x = $start_x;
    my $cur_y = $start_y;
    my $dir = 'E';

    my $numbers;
    $numbers->{$start_x . '_' . $start_y}->{E} = 0;
    $numbers->{$start_x . '_' . $start_y}->{N} = 1000;
    $numbers->{$start_x . '_' . $start_y}->{W} = 2000;
    $numbers->{$start_x . '_' . $start_y}->{S} = 3000;

# N
#W E
# S

p $numbers;

    my $safe_guard = 0;
    while(1) {
        $safe_guard++;

        my $did_some_work = 0;

        foreach my $p (sort keys %{$numbers}) {
            my ($x, $y) = split /_/, $p;
            #  N
            # W E
            #  S

            # N
            if ($field[$y-1]->[$x] eq '.') {
                my $new_position = $x . '_' . ($y-1);
                if (not exists $numbers->{ $new_position }) {
                    $numbers->{ $new_position }->{N} = $numbers->{ $p }->{N}+1;
                    $numbers->{ $new_position }->{W} = $numbers->{ $p }->{N}+1 + 1000;
                    $numbers->{ $new_position }->{S} = $numbers->{ $p }->{N}+1 + 2000;
                    $numbers->{ $new_position }->{E} = $numbers->{ $p }->{N}+1 + 3000;
                    $did_some_work++;
                }
            }

            # W
            if ($field[$y]->[$x-1] eq '.') {
                my $new_position = ($x - 1) . '_' . $y;
                if (not exists $numbers->{ $new_position }) {
                    $numbers->{ $new_position }->{W} = $numbers->{ $p }->{W}+1;
                    $numbers->{ $new_position }->{S} = $numbers->{ $p }->{W}+1 + 1000;
                    $numbers->{ $new_position }->{E} = $numbers->{ $p }->{W}+1 + 2000;
                    $numbers->{ $new_position }->{N} = $numbers->{ $p }->{W}+1 + 3000;
                    $did_some_work++;
                }
            }

            # S
            if ($field[$y+1]->[$x] eq '.') {
                my $new_position = ($x) . '_' . ($y+1);
                if (not exists $numbers->{ $new_position }) {
                    $numbers->{ $new_position }->{S} = $numbers->{ $p }->{S}+1;
                    $numbers->{ $new_position }->{E} = $numbers->{ $p }->{S}+1 + 1000;
                    $numbers->{ $new_position }->{N} = $numbers->{ $p }->{S}+1 + 2000;
                    $numbers->{ $new_position }->{W} = $numbers->{ $p }->{S}+1 + 3000;
                    $did_some_work++;
                }
            }

            # E
            if ($field[$y]->[$x+1] eq '.') {
                my $new_position = ($x+1) . '_' . ($y);
                if (not exists $numbers->{ $new_position }) {
                    $numbers->{ $new_position }->{E} = $numbers->{ $p }->{E}+1;
                    $numbers->{ $new_position }->{N} = $numbers->{ $p }->{E}+1 + 1000;
                    $numbers->{ $new_position }->{W} = $numbers->{ $p }->{E}+1 + 2000;
                    $numbers->{ $new_position }->{S} = $numbers->{ $p }->{E}+1 + 3000;
                    $did_some_work++;
                }
            }

#p $numbers;
#            die;
        }

        last if not $did_some_work;
        die if $safe_guard > 1000;
    }

    my $end_position_numbers = $numbers->{$end_x . '_' . $end_y};

    say min(
        $end_position_numbers->{N},
        $end_position_numbers->{W},
        $end_position_numbers->{S},
        $end_position_numbers->{E},
    );


}
main();
__END__
