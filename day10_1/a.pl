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

sub has_path {
    my ($field, $start, $end) = @_;

    return 0 if abs($start->[0] - $end->[0]) > 10;
    return 0 if abs($start->[1] - $end->[1]) > 10;

    my $has_path = do_r($field, $start->[0], $start->[1], 1, $end->[0], $end->[1]);

    return $has_path;
}

# return @arr with [$x, $y] of all points connected to specified point that has expected number
sub get_points {
    my ($f, $cur_x, $cur_y, $expected) = @_;

    my @field = @{$f};

    my @points;

    if ($cur_y > 0) {
        my $u = $field[$cur_y-1]->[$cur_x];
        if ($u =~ /\d/ && $u == $expected) {
            push @points, [$cur_x, $cur_y-1];
        }
    }

    if ($cur_y < $MAX_Y) {
        my $d = $field[$cur_y+1]->[$cur_x];
        if ($d =~ /\d/ && $d == $expected) {
            push @points, [$cur_x, $cur_y+1];
        }
    }

    if ($cur_x > 0) {
        my $l = $field[$cur_y]->[$cur_x-1];

        if ($l =~ /\d/ && $l == $expected) {
            push @points, [$cur_x-1, $cur_y];
        }
    }

    if ($cur_x < $MAX_X) {
        my $r = $field[$cur_y]->[$cur_x+1];

        if ($r =~ /\d/ && $r == $expected) {
            push @points, [$cur_x+1, $cur_y];
        }
    }

    return @points;
}

#
sub do_r {
    my ($f, $x, $y, $expected_number, $expected_x, $expected_y) = @_;

    #say "do_r $x $y $expected_number ";

    my @field = @{$f};

    my @points = get_points($f, $x, $y, $expected_number);

    return 0 if @points == 0;

    if ($expected_number == 9) {
        my $found = 0;
        TMP:
        foreach my $p (@points) {
            if ($p->[0] == $expected_x && $p->[1] == $expected_y) {
                $found = 1;
                last TMP;
            }
        }

        return $found;
    }

    my $has = 0;
    my $i = 0;
    TMP:
    foreach my $p (@points) {
        #say "Working with point $i total points " .  scalar @points;
        $i++;
        my $result = do_r($f, $p->[0], $p->[1], $expected_number+1, $expected_x, $expected_y);
        if ($result) {
            $has = 1;
            last TMP;
        }
    }

    return $has;
}

sub output_field {
    my ($f) = @_;

    my @field = @{$f};

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            print($value);
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

    # arrayref; each element is [$x, $y] of point with zero
    my $zeroes;

    # arrayref; each element is [$x, $y] of point with nine
    my $nines;

    $MAX_X = scalar(@{$field[0]})-1;
    $MAX_Y = scalar(@field)-1;

    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $value = $field[$y]->[$x];
            if ($value =~ /\d/ && $value == 0) {
                push @{$zeroes}, [$x, $y];
            }

            if ($value =~ /\d/ && $value == 9) {
                push @{$nines}, [$x, $y];
            }
        }
    }


    output_field(\@field);

    say 'Zeroes count: ' . scalar @{$zeroes};
    say 'Nines count: ' . scalar @{$nines};

    my $i = 1;
    foreach my $z (@{$zeroes}) {
#        say "Trailhead $i [$z->[0], $z->[1]]";
        my $score = 0;

        foreach my $n (@{$nines}) {
#            say "   End [$n->[0], $n->[1]]";
            if (has_path(\@field, $z, $n)) {
#                say '   has path';
                $score++;
            } else {
#                say '   has NO path';
            }
        }

        say "Trailhead $i [$z->[0], $z->[1]] score: " . $score;
        say '';
        $i++;
        $answer += $score;
    }

#    output_field(\@field);

    say $answer;

}
main();
__END__
