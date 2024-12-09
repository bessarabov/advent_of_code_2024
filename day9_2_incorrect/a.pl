#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;

my $MIN_FREE_START = 0;


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

sub get_from_memory {
    my ($mem, $start, $end) = @_;

    my $str = '';

    foreach my $el ($start..$end) {
        $str .= $mem->[$el];
    }

    return $str;
}

sub output_memory {
    my ($mem) = @_;

    my $str = get_from_memory($mem, 0, scalar(@{$mem}) - 1);

    $str =~ s/ /./g;
    say $str;
}

sub get_first_free {
    my ($memory) = @_;

    my @memory = @{$memory};

    my $p_free_start;
    my $p_free_end;

    EEE1:
    for (my $i = $MIN_FREE_START; $i<@memory; $i++) {
        if ($memory[$i] eq ' ') {
            $MIN_FREE_START = $i;
            if (not defined $p_free_start) {
                $p_free_start = $i;

                for (my $j = $i; $i<(@memory - 1); $j++) {
                    if ($memory[$j+1] ne ' ') {
                        $p_free_end = $j;
                        last EEE1;
                    }
                }
            }
        }
    }

    return ($p_free_start, $p_free_end);
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

    output_memory(\@memory);

    say 'move file blocks start';


    my $p_free_start; # including the start
    my $p_free_end; # including the end, $p_free_end + 1 is the first element that is not free

    ($p_free_start, $p_free_end) = get_first_free(\@memory);

    my $p_file_start; # including the start
    my $p_file_end; # including the end, $p_free_end + 1 is the first element that is not free

    FFF1:
    for (my $i = @memory - 1; $i>=0; $i--) {
        if ($memory[$i] ne ' ') {
            $p_file_end = $i;

            for (my $j = $i; $j>=1; $j--) {
                if ($memory[$j-1] ne $memory[$i]) {
                    $p_file_start = $j;
                    last FFF1;
                }
            }
        }
    }
    my $has_file_to_move = 1;

    my $safe_guars = 0;

#say join '', @memory;


my $prev_memory = '';
my $seen_same_memory = 0;

my %moved;

    MAIN:
    while (1) {
        if ($safe_guars % 1_000 == 0) {
            say 'loop ', $safe_guars;
            say scalar keys %moved;

        }
#my $tmp_memory = get_memory_as_string(\@memory);
#
##        say $tmp_memory;
#if ($prev_memory eq $tmp_memory) {
#    $seen_same_memory++;
#} else {
#    $seen_same_memory = 0;
#}
#$prev_memory = $tmp_memory;
#
#if ($seen_same_memory > 1000) {
#    say 'seen too many times';
#    last MAIN;
#};
#

        my $free_length = $p_free_end - $p_free_start + 1;
        my $file_length = $p_file_end - $p_file_start + 1;
#say sprintf 'free: %s .. %s length: %s "%s"', $p_free_start, $p_free_end, $free_length,
#get_from_memory(\@memory, $p_free_start, $p_free_end);
#say sprintf 'file: %s .. %s length: %s "%s"', $p_file_start, $p_file_end, $file_length,
#get_from_memory(\@memory, $p_file_start, $p_file_end);

my $current_file = get_from_memory(\@memory, $p_file_start, $p_file_end);

#p \%moved;

last MAIN if $moved{$current_file};

die if $free_length < 1;
#die if $file_length < 1;
last MAIN if $file_length < 1;

        if ($has_file_to_move) {
            if (
                ($free_length >= $file_length)
                and ($p_free_start < $p_file_start)
                )
            {
                #say 'has_file_to_move & has space';

                my $file = get_from_memory(\@memory, $p_file_start, $p_file_end);
                #say "moving $file";
                $moved{$file} = 1;

                for (my $i = 0; $i < $file_length; $i++) {
                    $memory[$p_free_start + $i] = $memory[$p_file_start+$i];
                    $memory[$p_file_start + $i] = ' ';
                }

                if ($p_free_start + $file_length <= $p_free_end) {
                    $p_free_start += $file_length;
                }


                $has_file_to_move = 0;

                ($p_free_start, $p_free_end) = get_first_free(\@memory);

            } else {
                #say 'has_file_to_move & NOT has space';
                # free space is not enough to put the full file

                my $new_p_free_start;
                my $new_p_free_end;

                EEE2:
                for (my $i = $p_free_end+1; $i<@memory; $i++) {
                    if ($memory[$i] eq ' ') {
                        if (not defined $new_p_free_start) {
                            $new_p_free_start = $i;

                            for (my $j = $i; $i<(@memory - 1); $j++) {
                                if (not defined $memory[$j+1]) {
                                    #say 'need to select new file';

                                    ($p_free_start, $p_free_end) = get_first_free(\@memory);

                                    FFF3:
                                    for (my $i = $p_file_start-1; $i>=0; $i--) {
                                        if ($memory[$i] ne ' ') {
                                            $p_file_end = $i;

                                            for (my $j = $i; $j>=1; $j--) {
                                                if ($memory[$j-1] ne $memory[$i]) {
                                                    $p_file_start = $j;
                                                    last FFF3;
                                                }
                                            }
                                        }
                                    }
                                    $has_file_to_move = 1;

                                    next MAIN
                                }
                                if ($memory[$j+1] ne ' ') {
                                    $new_p_free_end = $j;
                                    last EEE2;
                                }
                            }
                        }
                    }
                }

                $p_free_start = $new_p_free_start;
                $p_free_end = $new_p_free_end;
            }
        } else {
            #say 'NOT has_file_to_move';
            # file is moved, need to find new file;
            FFF2:
            for (my $i = $p_file_start-1; $i>=0; $i--) {
                if ($memory[$i] ne ' ') {
                    $p_file_end = $i;

                    for (my $j = $i; $j>=1; $j--) {
                        if ($memory[$j-1] ne $memory[$i]) {
                            $p_file_start = $j;
                            last FFF2;
                        }
                    }
                }
            }
            $has_file_to_move = 1;
        }

        $safe_guars++;
        #die '!!!' if $safe_guars > 200_000;
        die '!!!' if $safe_guars > 5_000_000;
    }

    output_memory(\@memory);

    say 'checksum start';
    for (my $i = 0; $i<@memory; $i++) {
        if ($memory[$i] ne ' ') {
            $answer += $i * $memory[$i];
        }
    }

    say $answer;
}
main();
__END__
