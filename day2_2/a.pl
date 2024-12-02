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

sub is_safe {
    my (@row) = @_;

    my %h = (
        inc => 0,
        dec => 0,
    );

    my $prev;
    foreach my $el (@row) {
        if ($prev) {
            return 0 if $el == $prev;

            if ($el > $prev) {
    $h{inc} = 1;
            }

            if ($el < $prev) {
    $h{dec} = 1;
            }

            my $diff = abs($prev-$el);
            return 0 if $diff > 3;

        }

        $prev = $el;
        #p $el;
    }

    say '';

    return 0 if $h{inc} && $h{dec};

    return 1;
}

sub is_safe2 {
    my (@row) = @_;

    foreach my $i (0..scalar(@row)-1) {
        my @new;
        p $i;

        for (my $n=0; $n<@row; $n++) {
            if ($n != $i) {
                push @new, $row[$n];
            }
        }
            return 1 if is_safe(@new);
    }

    return 0;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);
    p \@field;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        if (is_safe2(@{$field[$y]})) {
            say 'safe';
            $answer++;
        } else {
            say 'not safe';
        }
    }

    say $answer;

}
main();
__END__
