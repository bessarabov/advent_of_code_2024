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

my $MAX_X;
my $MAX_Y;

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

sub nums {
    my ($str) = @_;
    my @nums;

    while ($str =~ /(\-?\d+)/msga) {
        push @nums, $1;
    }

    return @nums;
}

sub output_robots {
    my ($robots) = @_;

    my @field;
    foreach my $r (@{$robots}) {
        $field[$r->{y}]->[$r->{x}]++;
    }

    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $value = $field[$y]->[$x];
            if (not defined $value) {
                print '.';
            } elsif ($value > 9) {
                print '+';
            } else {
                print $value;
            }
        }
        say '';
    }


}

sub get_in_each_quadrant {
    my ($robots) = @_;




    # xx|xx    y == 0
    # xx|xx    y == $y1 == $MAX_Y / 2
    # --+--
    # xx|xx    y == $y2 == $y1 + 2
    # xx|xx    y == $MAX_Y
    #
    # the same for x
    # x == 0
    # x == $x1 = $MAX_X / 2
    # x == $x2 == $x1 + 2
    # x == $MAX_X;

    # 0 1
    # 2 3

    my $tmp_x = ($MAX_X / 2) - 1;
    my $tmp_y = ($MAX_Y / 2) - 1;


    my @q = (
        {
            x1 => 0,
            y1 => 0,
            x2 => $tmp_x,
            y2 => $tmp_y,
        },
        {
            x1 => $tmp_x + 2,
            y1 => 0,
            x2 => $MAX_X,
            y2 => $tmp_y,
        },
        {
            x1 => 0,
            y1 => $tmp_y + 2,
            x2 => $tmp_x,
            y2 => $MAX_Y
        },
        {
            x1 => $tmp_x + 2,
            y1 => $tmp_y + 2,
            x2 => $MAX_X,
            y2 => $MAX_Y
        },
    );

p $q[0];

    my @arr;

    foreach my $q (@q) {
        my $tmp = 0;
        foreach my $r (@{$robots}) {
            if (
($r->{x} >= $q->{x1})
and ($r->{x} <= $q->{x2})
and ($r->{y} >= $q->{y1})
and ($r->{y} <= $q->{y2})
) {
    $tmp++;
}
        }
        push @arr, $tmp;
    }


    return @arr;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    say $content;

    my $robots;

    foreach my $line (split /\n/, $content) {
        my ($x, $y, $vel_x, $vel_y) = nums($line);
        push @{$robots}, {
            x => $x,
            y => $y,
            vel_x => $vel_x,
            vel_y => $vel_y,
        };
    }

    my @field;
    foreach my $r (@{$robots}) {
        $field[$r->{y}]->[$r->{x}]++;
    }

    $MAX_Y = scalar(@field)-1;
    $MAX_X = 0;

    foreach (0..$MAX_Y) {
        if ($field[$_]) {
            $MAX_X = max($MAX_X, scalar(@{$field[$_]})-1);
        }
    }

    # 101 tiles wide and 103 tiles tall
    $MAX_X = 100;
    $MAX_Y = 102;

#    $MAX_X = 10;
#    $MAX_Y = 6;

    say 'Initial:';
    output_robots($robots);
    say '';

    foreach my $i (1..100) {
        foreach my $r (@{$robots}) {
            my $new_x = $r->{x} + $r->{vel_x};
            my $new_y = $r->{y} + $r->{vel_y};

            if ($new_x < 0) {
                $new_x = $MAX_X + $new_x + 1;
            }

            if ($new_y < 0) {
                $new_y = $MAX_Y + $new_y + 1;
            }

            if ($new_x > $MAX_X) {
                $new_x = $new_x - $MAX_X - 1;
            }

            if ($new_y > $MAX_Y) {
                $new_y = $new_y - $MAX_Y - 1;
            }

            $r->{x} = $new_x;
            $r->{y} = $new_y;
        }

#        say "after $i sec:";
#        output_robots($robots);
#        say '';
    }

    output_robots($robots);

    my @arr = get_in_each_quadrant($robots);

    p \@arr;

    say $arr[0] * $arr[1] * $arr[2] * $arr[3];

    say $answer;

}
main();
__END__
