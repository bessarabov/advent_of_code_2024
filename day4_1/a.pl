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

say $content;

    my @field = get_field($content);
#    p \@field;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;


my @arr = @field;

my @rotated;
for my $row (0 .. $#arr) {
    for my $col (0 .. $#{$arr[$row]}) {
        $rotated[$col][$#arr - $row] = $arr[$row][$col];
    }
}

my $new_content = '';
for my $row (@rotated) {
    $new_content .= join('', @$row) . "\n";
}

#say $new_content;




#    foreach my $row (@field) {
#        p $row;
#        foreach my $el (@$row) {
#            say $el;
#        }
#    }


my $a1 = 0;
my $a2 = 0;
my $a3 = 0;
my $a4 = 0;

    foreach my $line (split /\n/, $content) {

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'XMAS') {
				$a1++;
			}
		}

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'SAMX') {
				$a2++;
			}
		}

    }


    foreach my $line (split /\n/, $new_content) {

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'XMAS') {
				$a3++;
			}
		}

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'SAMX') {
				$a4++;
			}
		}
    }


my $a5 = 0;
my $a6 = 0;


my $rows = scalar @field;
my $cols = scalar @{$field[0]};

my @diagonals;

for my $start_col (0 .. $cols - 1) {
    my $x = 0;
    my $y = $start_col;
    my $diag = '';
    while ($x < $rows && $y >= 0) {
        $diag .= $field[$x][$y];
        $x++;
        $y--;
    }
    push @diagonals, $diag;
}

for my $start_row (1 .. $rows - 1) {
    my $x = $start_row;
    my $y = $cols - 1;
    my $diag = '';
    while ($x < $rows && $y >= 0) {
        $diag .= $field[$x][$y];
        $x++;
        $y--;
    }
    push @diagonals, $diag;
}

foreach my $line (@diagonals) {
say $line;

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'XMAS') {
				$a5++;
			}
		}

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'SAMX') {
				$a6++;
			}
		}
}



my $a7 = 0;
my $a8 = 0;

say 'a7 a8';

$rows = scalar @rotated;
$cols = scalar @{$rotated[0]};

@diagonals = ();

for my $start_col (0 .. $cols - 1) {
    my $x = 0;
    my $y = $start_col;
    my $diag = '';
    while ($x < $rows && $y >= 0) {
        $diag .= $field[$x][$y];
        $x++;
        $y--;
    }
    push @diagonals, $diag;
}

for my $start_row (1 .. $rows - 1) {
    my $x = $start_row;
    my $y = $cols - 1;
    my $diag = '';
    while ($x < $rows && $y >= 0) {
        $diag .= $field[$x][$y];
        $x++;
        $y--;
    }
    push @diagonals, $diag;
}



foreach my $line (@diagonals) {
say $line;

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'XMAS') {
				$a7++;
			}
		}

		foreach my $i (0..length($line)) {
			if (substr($line, $i, 4) eq 'SAMX') {
				$a8++;
			}
		}
}

p {
a1 => $a1,
a2 => $a2,
a3 => $a3,
a4 => $a4,
a5 => $a5,
a6 => $a6,
a7 => $a7,
a8 => $a8,
};

    say $a1+$a2+$a3+$a4+$a5+$a6+$a7+$a8;

}
main();
__END__
