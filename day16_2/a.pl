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

sub output_field {
    my ($f) = @_;

    my @field = @{$f};

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            if ($value eq '#') {
                print '█';
            } else {
                print($value);
            }
        }
        say '';
    }

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

    output_field(\@field);
    say '';

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

# N
#W E
# S

#p $numbers;

    # [x, y]
    my @moves = (
        [0, -1], # N
        [-1, 0], # W
        [0, 1], # S
        [1, 0], # E
    );

    # Remove all dead ends
    my $safe_guard = 0;

    L1:
    while(1) {
        $safe_guard++;
        die if $safe_guard > 1000;

        my $did_some_work = 0;

        foreach my $y (0..$MAX_Y) {

            TMP1:
            foreach my $x (0..$MAX_X) {
                next TMP1 if $x == $start_x && $y == $start_y;
                next TMP1 if $x == $end_x && $y == $end_y;
                my $value = $field[$y]->[$x];

                if ($value eq '.') {
                    my %h;
                    foreach my $m (@moves) {
                        my $value2 = $field[$y+$m->[1]]->[$x+$m->[0]];
                        $h{$value2}++;
                    }
                    if (($h{'#'} // 0) == 3) {
                        $field[$y]->[$x] = '#';
                        $did_some_work = 1;
                    }
                }

            }
        }

        last L1 if not $did_some_work;
    }

    # here we have maze without dead ends
    # we have start poistion
    # we have end position
    # crossroad are ponts that have move that 2 roads
    #
    # i'm curious what number of diffrent types of crossroad we have
    my %diffrent_crossroad;
    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $value = $field[$y]->[$x];

            if ($value eq '.') {
                my $count = 0;
                foreach my $m (@moves) {
                    my $value2 = $field[$y+$m->[1]]->[$x+$m->[0]];
                    if ($value2 eq '.') {
                        $count++;
                    }
                }
                $diffrent_crossroad{$count}++;
            }
        }
    }

    output_field(\@field);

    p \%diffrent_crossroad;

}
main();
__END__
