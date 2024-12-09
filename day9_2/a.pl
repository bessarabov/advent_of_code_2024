#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);

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

sub get_memory_from_input {
    my ($content) = @_;

    chomp $content;

    my @mem;

    my @arr = split //, $content;
    my $id = 0;

    for (my $i = 0; $i < @arr; $i++) {
        my $char = $arr[$i];
        if ($i % 2 == 1) {
            foreach (1..$char) {
                push @mem, '',
            }
        } else {
            foreach (1..$char) {
                push @mem, $id,
            }
            $id++;
        }
    }

    return \@mem;
}

sub output_memory {
    my ($mem) = @_;

    foreach my $el (@{$mem}) {
        if ($el eq '') {
            print '.'
        } else {
            print $el;
        }
    }

    say '';
}

sub get_checksum {
    my ($mem) = @_;

    my $checksum = 0;
    for (my $i = 0; $i < @{$mem}; $i++) {
        my $value = $mem->[$i];

        if ($value ne '') {
            $checksum += $i * $value;
        }
    }

    return $checksum;
}

sub part1 {
    my ($mem) = @_;

    # hash; key - index of free block start; value - length of free block
    my $free_spaces = get_free_spaces($mem);

    my $last_number_index = scalar @$mem - 1;
    my $first_free_index = get_first_free_index($free_spaces);

    MAIN:
    while ($first_free_index < $last_number_index) {
        #output_memory($mem);
        my $value;

        TMP:
        while (1) {
            $value = pop @{$mem};
            $last_number_index--;
            if ($value ne '') {
                last TMP;
            }
        }

        $mem->[$first_free_index] = $value;
        $free_spaces->{$first_free_index}--;
        if ($free_spaces->{$first_free_index} == 0) {
            delete $free_spaces->{$first_free_index};
        } else {
            $free_spaces->{$first_free_index+1} = delete $free_spaces->{$first_free_index};
        }

        $first_free_index = get_first_free_index($free_spaces);
    }

}

sub get_free_spaces {
    my ($mem) = @_;

    my %h;
    my $free_start = 0;
    my $free_count = 0;

    for (my $i = 0; $i < @{$mem}; $i++) {
        if ($mem->[$i] eq '') {
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

sub get_first_free_index {
    my ($free_spaces) = @_;

    my @arr = keys %{$free_spaces};

    my $min = $arr[0];

    foreach my $el (@arr) {
        if ($el < $min) {
            $min = $el;
        }
    }

    die if $min == -1;

    return $min;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    say 'Generating memory from input - start';
    my $t0 = [gettimeofday];
    my $mem = get_memory_from_input($content);
    my $elapsed = tv_interval ( $t0, [gettimeofday]);
    say sprintf 'Generating memory from input - end - %s seconds', $elapsed;
    say '';

    say 'Memory length: ' . scalar @{$mem};
    say '';

    say 'Main logic - start';
    $t0 = [gettimeofday];
    part1($mem);
    $elapsed = tv_interval ( $t0, [gettimeofday]);
    say sprintf 'Main logic - end - %s seconds', $elapsed;
    say '';


    say 'Calculate checksum - start';
    $t0 = [gettimeofday];
    my $checksum = get_checksum($mem);
    $elapsed = tv_interval ( $t0, [gettimeofday]);
    say sprintf 'Calculate checksum - end - %s seconds', $elapsed;
    say '';

    #output_memory($mem);

    say $checksum;

}
main();
__END__
