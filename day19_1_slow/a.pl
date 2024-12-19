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

sub is_possible {
    my ($patterns, $towel) = @_;

    my $arr = get_possible_splits($patterns, $towel);

    return 0 if @{$arr} == 0;

    my @rest;
    foreach my $el (@{$arr}) {
        if ($el->{rest} eq '') {
            return 1;
        } else {
            push @rest, $el->{rest};
        }
    }

    my $count = 0;
    while (@rest) {
        $count ++;
        my $towel = pop @rest;

        my $arr = get_possible_splits($patterns, $towel);

        foreach my $el (@{$arr}) {
            if ($el->{rest} eq '') {
#                say $count;
                return 1;
            } else {
                push @rest, $el->{rest};
            }
        }
    }

    return 0;
}

sub get_possible_splits {
    my ($patterns, $towel) = @_;

    my @res;
    foreach my $p (@{$patterns}) {
        if (substr($towel, 0, length($p)) eq $p) {
            my $rest = substr($towel, length($p));
            push @res, {
                pattern => $p,
                rest => $rest,
            }
        }
    }

    return \@res;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my ($tmp_patterns, $tmp_towels) = split /\n\n/, $content;

    my @patterns = sort {length($a) <=> length($b) || $a cmp $b } split /,\s*/, $tmp_patterns;

p \@patterns;

    my $n = 0;
    foreach my $towel (split /\n/, $tmp_towels) {
        $n++;
        my $bool = is_possible(\@patterns, $towel);
        say "$n $towel $bool";
        if ($bool) {
            $answer++;
        }
    }

    say $answer;
}
main();
__END__
