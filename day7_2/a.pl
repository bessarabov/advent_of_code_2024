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

sub get_in_ternary {
    my ($num) = @_;

    return 0 if $num == 0;

    my $ternary = "";
    while ($num > 0) {
        $ternary = ($num % 3) . $ternary;
        $num= int($num / 3);
    }

    return $ternary;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

foreach my $line (split /\n/, $content) {

    my $has_valid_answer = 0;

say 'line: ' . $line;
    my ($num, $other) = $line =~ /^(\d+): (.+)\z/;
    my @other = split /\s+/, $other;

    my $l = scalar(@other) - 1;

    MAIN:
    foreach my $bin (0..(3**$l-1)) {
#say $bin;
        my $operators = reverse get_in_ternary($bin);
#say "\tvariant " . $operators;
        my @ops = split //, $operators;

        my @tmp1 = @other;

        my $result = shift @tmp1;

        for (my $ii = 1; $ii < (scalar @other); $ii++) {
            my $o = shift @ops;
            $o = 0 if not defined $o;
            if ($o eq '0') {
                $result *= $other[$ii];
            } elsif ($o eq '1') {
                $result += $other[$ii];
            } elsif ($o eq '2') {
                $result .= $other[$ii];
            }
        }

        if ($num == $result) {
            say "\t\t!!!! " . $num;
            $has_valid_answer = 1;
            last MAIN;
        }

    }


    if ($has_valid_answer) {
        $answer += $num;
    }
}


    say $answer;

}
main();
__END__
