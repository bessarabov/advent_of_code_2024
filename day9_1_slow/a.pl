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

sub has_gaps {
    my (@memory) = @_;

    my $seen_free = 0;

    my $free_index;

    for (my $i = 0; $i< @memory; $i++) {
        my $el = $memory[$i];
        if ($el eq ' ') {
            $seen_free = 1;
            if (not defined $free_index) {
                $free_index = $i;
            }
        } else {

            return (1, $free_index) if $seen_free;
        }
    }

    return 0;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);
    chomp($content);

    my @memory;

    my @row= split //, $content;

    say 'fill memory';
    my $id = 0;
    for (my $i = 0; $i<@row; $i++) {
        if ($i % 2 == 0) {
            # file
            foreach (1..$row[$i]) {
                push @memory, $id;
            }
            $id++;
        } else {
            #free space;
            foreach (1..$row[$i]) {
                push @memory, ' ';
            }
        }
    }

    say 'memory size: ', scalar @memory;

    say 'move file blocks start';
    my $safe_guars = 0;
    while (1) {
        say 'loop ', $safe_guars if $safe_guars % 1_000 == 0;
        my ($has_gaps, $free_index) = has_gaps(@memory);

        if (!$has_gaps) {
            last;
        }

        my $el = pop @memory;
        if ($el eq ' ') {
            # nothing
        } else {
            $memory[$free_index] = $el;
        }

        $safe_guars++;
        die '!!!' if $safe_guars > 100000;
    }


    say 'checksum start';
    for (my $i = 0; $i<@memory; $i++) {
        $answer += $i * $memory[$i];
    }

    say $answer;
}
main();
__END__
