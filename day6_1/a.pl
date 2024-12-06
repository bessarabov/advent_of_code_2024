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

sub say_field {
    my (@field) = @_;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            print $field[$y]->[$x];
        }
        say '';
    }
}

sub count {
    my (@field) = @_;

    my $answer = 0;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            if ($field[$y]->[$x] eq 'X') {
                $answer++;
            }
        }
    }

    return $answer;
}

sub main {


    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);

#    p \@field;
#
    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

my $cur_x = 0;
my $cur_y = 0;

my $dir = 'U';

my %next_dir = (
U => 'R',
D => 'L',
L => 'U',
R => 'D',
);

    TMP:
    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            if ($field[$y]->[$x] eq '^') {
                $cur_x = $x;
                $cur_y = $y;
                $field[$y]->[$x] = 'X';
last TMP;
            }
        }
    }


    my $safe_guard = 0;

    MAIN:
    while (1) {
#        say_field(@field);
#        say $dir, ' ', $cur_x, ' ', $cur_y;
#        say '';

        if ($dir eq 'U') {
            if ($cur_y == 0) {
                last;
            }

            if ($field[$cur_y-1]->[$cur_x] eq '#') {
                $dir = $next_dir{$dir};
            } else {
                $cur_y--;
                $field[$cur_y]->[$cur_x] = 'X';
            }
        }
        if ($dir eq 'D') {
            if ($cur_y == $max_y) {
                last;
            }

            if ($field[$cur_y+1]->[$cur_x] eq '#') {
                $dir = $next_dir{$dir};
            } else {
                $cur_y++;
                $field[$cur_y]->[$cur_x] = 'X';
            }
        }

        if ($dir eq 'L') {

            if ($cur_x == 0) {
                last;
            }

            if ($field[$cur_y]->[$cur_x-1] eq '#') {
                $dir = $next_dir{$dir};
            } else {
                $cur_x--;
                $field[$cur_y]->[$cur_x] = 'X';
            }
        }

        if ($dir eq 'R') {

            if ($cur_x == $max_x) {
                last;
            }

            if ($field[$cur_y]->[$cur_x+1] eq '#') {
                $dir = $next_dir{$dir};
            } else {
                $cur_x++;
                $field[$cur_y]->[$cur_x] = 'X';
            }
        }

        $safe_guard++;
        #last if $safe_guard > 100;
    }


say_field(@field);
say $safe_guard;

    my $answer = count(@field);


    say $answer;

}
main();
__END__
