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

sub gcd {
    my ($a, $b) = @_;
    while ($b != 0) {
        ($a, $b) = ($b, $a % $b);
    }
    return $a;
}

sub lcm {
    my ($a, $b) = @_;
    return abs($a * $b) / gcd($a, $b);
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my $machines;
    my %b;
    foreach my $line (split /\n/, $content) {
        if ($line =~ /^Button (A|B): X\+(\d+), Y\+(\d+)\z/a) {
            $b{$1}->{x} = $2;
            $b{$1}->{y} = $3;
        } elsif ($line =~ /^Prize: X=(\d+), Y=(\d+)\z/a) {
            push @{$machines}, {
#                prize_x => $1,
#                prize_y => $2,
                prize_x => $1 + 10000000000000,
                prize_y => $2 + 10000000000000,
                button_a_x => $b{A}->{x},
                button_a_y => $b{A}->{y},
                button_b_x => $b{B}->{x},
                button_b_y => $b{B}->{y},
            }
        } elsif ($line =~ /^\s*\z/) {
        } else {
            die $line;
        }
    }

    my $i = 0;
    MAIN:
    foreach my $m (@{$machines}) {
        $i++;
        say $i;

        my ($num_a_pushes, $num_b_pushes);

		my $det = $m->{button_a_x} * $m->{button_b_y} - $m->{button_b_x} * $m->{button_a_y};

		if ($det == 0) {
			say 'no solution';
			next MAIN;
		} else {
			my $inv11 = $m->{button_b_y} / $det;
			my $inv12 = -$m->{button_b_x} / $det;
			my $inv21 = -$m->{button_a_y} / $det;
			my $inv22 = $m->{button_a_x} / $det;

			my $ba = $inv11 * $m->{prize_x} + $inv12 * $m->{prize_y};
			my $bb = $inv21 * $m->{prize_x} + $inv22 * $m->{prize_y};

			next MAIN if $ba =~ /\./;
			next MAIN if $bb =~ /\./;

			# it costs 3 tokens to push the A button and 1 token to push the B button.
			$answer += 3 * $ba + $bb;
		}

    }

    say $answer;

}
main();
__END__
