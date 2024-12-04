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

sub get_XMAS_count {
    my ($str) = @_;

    my $count = 0;

    foreach my $i (0..length($str)) {
        if (substr($str, $i, 4) eq 'XMAS') {
            $count++;
        }
    }

    return $count;
}

sub get_SAMX_count {
    my ($str) = @_;

    my $count = 0;

    foreach my $i (0..length($str)) {
        if (substr($str, $i, 4) eq 'SAMX') {
            $count++;
        }
    }

    return $count;
}

sub get_rotated {
    my ($input) = @_;

	my @rows = split /\n/, $input;

	my $rows_count = scalar @rows;
	my $cols_count = length $rows[0];

	my @rotated;

	for my $col (0 .. $cols_count - 1) {
		my $rotated_row = '';
		for my $row (reverse @rows) {
			$rotated_row .= substr($row, $col, 1);
		}
		push @rotated, $rotated_row;
	}

	my $output = join "\n", @rotated;

	return $output;
}

sub get_diagonal_lines {
    my @matrix = split /\n/, shift;
    my %diagonals;

    # Traverse each cell and group them by diagonal index
    for my $row (0 .. $#matrix) {
        for my $col (0 .. length($matrix[$row]) - 1) {
            my $char = substr($matrix[$row], $col, 1);
            push @{$diagonals{$col - $row}}, $char;
        }
    }

    # Collect diagonals from top-right to bottom-left
    my @result;
    foreach my $key (sort { $a <=> $b } keys %diagonals) {
        push @result, join('', @{$diagonals{$key}});
    }

    return @result;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);
say $content;

my $a1 = 0;
my $a2 = 0;
foreach my $line (split /\n/, $content) {
    $a1 += get_XMAS_count($line);
    $a2 += get_SAMX_count($line);
}

my $a3 = 0;
my $a4 = 0;

my $rotated = get_rotated($content);
say $rotated;
foreach my $line (split /\n/, $rotated) {
    $a3 += get_XMAS_count($line);
    $a4 += get_SAMX_count($line);
}

my $a5 = 0;
my $a6 = 0;
say '-'x78;
foreach my $line (get_diagonal_lines($content)) {
say $line;
    $a5 += get_XMAS_count($line);
    $a6 += get_SAMX_count($line);
}
say '-'x78;

my $a7 = 0;
my $a8 = 0;
say '-'x78;
foreach my $line (get_diagonal_lines($rotated)) {
say $line;
    $a7 += get_XMAS_count($line);
    $a8 += get_SAMX_count($line);
}
say '-'x78;



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


say '';
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
