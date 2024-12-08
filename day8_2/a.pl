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

sub get_hash_with_uniq_elements_count {
    my (@field) = @_;

    my %h;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            $h{$field[$y]->[$x]}++;
        }
    }

    return \%h;
}

sub min {
    my ($one, $two) = @_;

    return $one < $two ? $one : $two;
}

sub max {
    my ($one, $two) = @_;

    return $one > $two ? $one : $two;
}

sub say_field {
    my (@field) = @_;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            print $field[$y]->[$x];
        }
        say '';
    }
}

sub put_anti_pair {
    my ($pair, $anti) = @_;

    my $max_x = scalar(@{$anti->[0]})-1;
    my $max_y = scalar(@{$anti})-1;

	my $p1 = $pair->[0];
	my $p2 = $pair->[1];

    my $x_diff = $p1->[0] - $p2->[0];
    my $y_diff = $p1->[1] - $p2->[1];

	put_anti($p1->[0], $p1->[1], $anti);
	put_anti($p2->[0], $p2->[1], $anti);

    # anti 1

	my $a1_x = $p1->[0]+$x_diff;
	my $a1_y = $p1->[1]+$y_diff;
	put_anti($a1_x, $a1_y, $anti);

	while(1) {
		$a1_x += $x_diff;
		$a1_y += $y_diff;

		put_anti($a1_x, $a1_y, $anti);

        last if $a1_x < 0;
        last if $a1_y < 0;

        last if $a1_x > $max_x;
        last if $a1_y > $max_y;
	}

    # anti 2

	my $a2_x = $p2->[0]-$x_diff;
	my $a2_y = $p2->[1]-$y_diff;
	put_anti($a2_x, $a2_y, $anti);

	while(1) {
		$a2_x -= $x_diff;
		$a2_y -= $y_diff;

		put_anti($a2_x, $a2_y, $anti);

        last if $a2_x < 0;
        last if $a2_y < 0;

        last if $a2_x > $max_x;
        last if $a2_y > $max_y;
	}

}

sub put_anti {
    my ($x, $y, $anti, $char) = @_;

    my $max_x = scalar(@{$anti->[0]})-1;
    my $max_y = scalar(@{$anti})-1;

	if
	( ($x >= 0 && $x <= $max_x)
	and ($y >= 0 && $y <= $max_y) ) {
		$anti->[$y]->[$x] = $char // '#';
	}

}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);
#    p \@field;

    my %positions;

    my @anti;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            $anti[$y]->[$x] = '.';

            if ($field[$y]->[$x] ne '.') {
                push @{$positions{$field[$y]->[$x]}}, [$x, $y];
            }

#            print $field[$y]->[$x];
#            print " ";
        }
#        say '';
    }

    foreach my $antena (sort keys %positions) {
        my @pairs;

        my @arr = @{$positions{$antena}};

        for (my $i = 0; $i < @arr; $i++) {
            for (my $j = $i + 1; $j < @arr; $j++) {
                push @pairs, [$arr[$i], $arr[$j]];
            }
        }

        foreach my $pair (@pairs) {
            put_anti_pair($pair, \@anti);
        }
    }


    say_field(@field);

	say '';

    say_field(@anti);

    my $h = get_hash_with_uniq_elements_count(@anti);
    p $h;


    say $answer;

}
main();
__END__
