#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;

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

sub output_field {
    my ($f, $cur_x, $cur_y) = @_;

    $cur_x //= -1;
    $cur_y //= -1;

    my @field = @{$f};

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            if ($x == $cur_x && $y == $cur_y) {
                print('@');
            } else {
                my $value = $field[$y]->[$x];
                print($value);
            }
        }
        say '';
    }

}

sub min {
    my ($one, $two) = @_;

    return $one < $two ? $one : $two;
}

sub max {
    my ($one, $two) = @_;

    return $one > $two ? $one : $two;
}

sub calculate_gps {
    my (@field) = @_;

    my @arr;
    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (1..($max_y-1)) {
        foreach my $x (1..($max_x-1)) {
            my $value = $field[$y]->[$x];
            if ($value eq 'O') {
#                p $x;
#                p $y;
                push @arr, $y * 100 + $x;
            }

        }
    }

    return @arr;
}

sub get_new_row {
    my ($cur_row, $s, $cur_x) = @_;

#p $cur_row;
#p $s;
#p $cur_x;
#
    my $moved = 0;

    if ($s eq '>' || $s eq 'v') {
        die if $cur_row->[$cur_x+1] ne 'O';

        # need to find first empty
        my $first_empty_x;
        TMP:
        foreach my $x (($cur_x+2)..(scalar(@{$cur_row})-1)) {
            if ($cur_row->[$x] eq '#') {
                last TMP
            }

            if ($cur_row->[$x] eq '.') {
                $first_empty_x = $x;
                last TMP
            }
        }
        if (defined $first_empty_x) {
            # need to move everything to the right
            # to do it i'm just moving one element to the right
            $cur_row->[$first_empty_x] = 'O';
            $cur_row->[$cur_x+1] = '.';
            $moved = 1;
        } else {
            # nothing to do, as there are no free spaces
        }
    } elsif ($s eq '<' || $s eq '^') {
        die if $cur_row->[$cur_x-1] ne 'O';

        # need to find first empty
        my $first_empty_x;
        TMP:
        for (my $x=$cur_x-2; $x>=0; $x--) {
            if ($cur_row->[$x] eq '#') {
                last TMP
            }
            if ($cur_row->[$x] eq '.') {
                $first_empty_x = $x;
                last TMP
            }
        }

        if (defined $first_empty_x) {
            # need to move everything to the right
            # to do it i'm just moving one element to the right
            $cur_row->[$first_empty_x] = 'O';
            $cur_row->[$cur_x-1] = '.';
            $moved = 1;
        } else {
            # nothing to do, as there are no free spaces
        }
    } else {
        die
    }

    return ($cur_row, $moved);
}

sub show_chars_count {
    my ($field) = @_;

    my @field = @{$field};

    my %chars;
    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            $chars{$value}++;
        }
    }

    p \%chars;
}



sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my ($map, $steps) = split /\n\n/, $content;

    my @field = get_field($map);

    $steps =~ s/\n//g;
    my @steps = split //, $steps;

    my $cur_x;
    my $cur_y;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            if ($value eq '@') {
                $cur_x = $x;
                $cur_y = $y;
                $field[$y]->[$x] = '.';
            }
        }
    }

#    p {
#        cur_x => $cur_x,
#        cur_y => $cur_y,
#    };

    my %moves = (
        '^' => { y => -1, x => 0 },
        'v' => { y => 1, x => 0 },
        '>' => { y => 0, x => 1 },
        '<' => { y => 0, x => -1 },
    );

    say 'Initial state:';
    output_field(\@field, $cur_x, $cur_y);
    say '';

    show_chars_count(\@field);

    my $i = 0;
    foreach my $s (@steps) {
        $i++;
#        say "## Step $i $s";
#        say "Move $s:";

        my $new_x = $cur_x + $moves{$s}->{x};
        my $new_y = $cur_y + $moves{$s}->{y};

        if ($field[$new_y]->[$new_x] eq '.') {
            $cur_x = $new_x;
            $cur_y = $new_y;
        } elsif ($field[$new_y]->[$new_x] eq '#') {
            # do nothing
        } else {
            if ($s eq '<' || $s eq '>') {
                my ($new_row, $moved) = get_new_row($field[$new_y], $s, $cur_x);
                $field[$new_y] = $new_row;
                if ($moved) {
                    $cur_x += $moves{$s}->{x};
                }
            } elsif ($s eq 'v' || $s eq '^') {
                my @col;
                foreach my $i (0..$max_y) {
                    push @col, $field[$i]->[$new_x];
                }
                my ($new_col, $moved) = get_new_row(\@col, $s, $cur_y);

                foreach (my $i=0; $i<@{$new_col}; $i++) {
                    $field[$i]->[$new_x] = $new_col->[$i];
                }

                if ($moved) {
                    $cur_y += $moves{$s}->{y};
                }
            } else {
                die;
            }
        }

#        output_field(\@field, $cur_x, $cur_y);
#        say '';

#        die if $i > 10
    }




    say 'After all moves:';
    output_field(\@field);
    say '';

    show_chars_count(\@field);

    my @gps = calculate_gps(@field);

    $answer += $_ foreach @gps;

#    my @field = get_field($content);
#    p \@field;
#
#    my $max_x = scalar(@{$field[0]})-1;
#    my $max_y = scalar(@field)-1;
#
#    foreach my $y (0..$max_y) {
#        foreach my $x (0..$max_x) {
#            print $field[$y]->[$x];
#            print " ";
#        }
#        say '';
#    }

    say $answer;

}
main();
__END__
