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

sub is_valid {
    my ($n1, $n2, $h) = @_;

    return 0 if exists $h->{$n2}->{$n1};


    return 1;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my %h;
    my @arr;

    foreach my $line (split /\n/, $content) {
        if ($line =~ /(\d+)\|(\d+)/) {
            $h{$1}->{$2}++;

            die if $h{$1}->{$2} != 1;
        }

        if ($line =~ /,/) {
            push @arr, [split /,/, $line];
        }

    }

    my @valid;


    MAIN:
    foreach my $nums (@arr) {
        my $l = scalar @$nums;

        for (my $i = 0; $i < $l-1; $i++) {
            for (my $j = $i+1; $j < $l; $j++) {
                my $n1 = $nums->[$i];
                my $n2 = $nums->[$j];

                if (not is_valid($n1, $n2, \%h)) {
                    next MAIN;
                }

                say $n1, ' ', $n2;
            }
        }

        push @valid, $nums;
    }

    foreach my $nums (@valid) {
        my $l = scalar @$nums;
        my $i = int($l/2);
        $answer += $nums->[$i];
    }

    p \%h;

    say $answer;

}
main();
__END__
