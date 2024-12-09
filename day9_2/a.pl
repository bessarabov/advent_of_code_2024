#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;

my $FILES = {};

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

sub get_blocks {
    my ($input) = @_;

    my @blocks;

    my $block_id = 0;

    chomp $input;

    my @arr = split //, $input;

    my $file_id = 0;
    for (my $i = 0; $i < @arr; $i++) {
        if ($i % 2 != 0) {
            foreach (1..$arr[$i]) {
                push @blocks, '.';
                $block_id++;
            }
        } else {
            $FILES->{$block_id} = [$file_id, $arr[$i]];
            foreach (1..$arr[$i]) {
                push @blocks, $file_id;
                $block_id++;
            }
            $file_id++;
        }
    }

    return \@blocks;
}

sub get_checksum {
    my ($blocks) = @_;

    my $checksum = 0;
    for (my $i = 0; $i < @{$blocks}; $i++) {
        my $file_id = $blocks->[$i];
        if ($file_id ne '.') {
            $checksum += $i * $file_id;
        }
    }

    return $checksum;
}

sub output_blocks {
    my ($blocks) = @_;

    for (my $i = 0; $i < @{$blocks}; $i++) {
        my $file_id = $blocks->[$i];
        if ($file_id eq '.') {
            print $file_id;
        } else {
            #print 'X';
            print substr($file_id, 0, 1);;
        }
    }

    say '';
}

sub part2 {
    my ($blocks) = @_;

    # hash; key - start index of free block; value - number of consistent free blocks
    my $free_blocks = get_free_blocks($blocks);
    my @free_indexes = sort { $a <=> $b } keys %{$free_blocks};

    # hash; key - start position; value - arrref [$file_id, length]
    # $FILES

    my @file_indexes = sort {$b <=> $a } keys %{$FILES};

    MAIN:
    foreach my $file_index (@file_indexes) {
say $file_index;
        my $file_id = $FILES->{$file_index}->[0];
        my $file_blocks_length = $FILES->{$file_index}->[1];

        TMP:
        foreach my $free_index (@free_indexes) {

            next MAIN if $free_index >= $file_index;

            my $free_blocks_length = $free_blocks->{$free_index};

            if ($free_blocks_length >= $file_blocks_length) {
                put($blocks, $free_index, $file_blocks_length, $file_id);
                put($blocks, $file_index, $file_blocks_length, '.');

                # recalculate
                $free_blocks = get_free_blocks($blocks);
                @free_indexes = sort { $a <=> $b } keys %{$free_blocks};

#output_blocks($blocks);
                last TMP;
            }

        }
    }

#    p $free_blocks;

}

sub put {
    my ($blocks, $index, $length, $what) = @_;

    foreach (0..($length-1)) {
        $blocks->[$_ + $index] = $what;
    }

}

sub get_free_blocks {
    my ($blocks) = @_;

    my %h;
    my $free_start = 0;
    my $free_count = 0;

    for (my $i = 0; $i < @{$blocks}; $i++) {
        if ($blocks->[$i] eq '.') {
            if (!$free_start) {
                $free_start = $i;
            }
            $free_count++;
        } else {
            if ($free_start) {
                $h{$free_start} = $free_count;
                $free_start = 0;
                $free_count = 0;
            }
        }

    }

    return \%h;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my $blocks = get_blocks($content);

    say 'Blocks count: ' . scalar @{$blocks};

    my $free_blocks = 0;
    my $occupied_blocks = 0;

    foreach my $block (@{$blocks}) {
        if ($block eq '.') {
            $free_blocks++;
        } else {
            $occupied_blocks++;
        }
    }

    #output_blocks($blocks);

    part2($blocks);


    say 'Free    : ' . $free_blocks;
    say 'Occupied: ' . $occupied_blocks;

    my $checksum = get_checksum($blocks);

    say 'Checksum: ' . $checksum;

}
main();
__END__
