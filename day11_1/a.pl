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

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    chomp $content;

    my @stones = split / /, $content;


    foreach my $i (1..25) {
#        say join ' ', @stones;
        my @new_stones;
        foreach my $s (@stones) {
            if ($s == 0) {
                push @new_stones, 1
            } elsif (length($s) % 2 == 0) {
                my $l = length($s) / 2;
                push @new_stones, int(substr($s, 0, $l));
                push @new_stones, int(substr($s, $l));
            } else {
                push @new_stones, $s*2024;
            }
        }
        @stones = @new_stones;
    }

    say scalar @stones;

}
main();
__END__
