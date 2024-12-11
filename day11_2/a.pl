#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep
                    clock_gettime clock_getres clock_nanosleep clock
                    stat lstat utime);

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

sub sum {
    my $s = 0;
    $s += $_ foreach @_;
    return $s;
}

sub seconds2text {
    my ($full_seconds) = @_;

    my $text;

    my $left_seconds = $full_seconds;

    my $days = int($left_seconds / (24*60*60));
    $left_seconds = $left_seconds - $days*(24*60*60);

    my $hours = int($left_seconds / (60*60));
    $left_seconds = $left_seconds - $hours*(60*60);

    my $minutes = int($left_seconds / (60));
    $left_seconds = $left_seconds - $minutes*(60);

    my $need;

    if ($days) {
        $text .= sprintf "%sd",
            $days,
            ;
        $need = 1;
    }

    if ($need || $hours) {
        $text .= sprintf "%02dh",
            $hours,
            ;
        $need = 1;
    }

    if ($need || $minutes) {
        $text .= sprintf "%02dm",
            $minutes,
            ;
    }

    $text .= sprintf "%02ds",
            $left_seconds,
            ;

    $text =~ s/^0//;

    return $text;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    chomp $content;

    my %h = map { $_ => 1 } split / /, $content;
    my @stones = split / /, $content;

    say join ' ', @stones;
    say '';

    foreach my $i (1..75) {

        say '## ' . $i;
#        my $t0 = [gettimeofday];


#        my @new_stones;
#        foreach my $s (@stones) {
#            if ($s == 0) {
#                push @new_stones, 1
#            } elsif (length($s) % 2 == 0) {
#                my $l = length($s) / 2;
#                push @new_stones, int(substr($s, 0, $l));
#                push @new_stones, int(substr($s, $l));
#            } else {
#                push @new_stones, $s*2024;
#            }
#        }
#        @stones = @new_stones;

        my %inc;
        my %dec;

        foreach my $s (keys %h) {
            if ($s == 0) {
                $dec{0} += ($h{$s} // 1) * 1;
                $inc{1} += ($h{$s} // 1) * 1;
            } elsif (length($s) % 2 == 0) {
                $dec{$s} += ($h{$s} // 1) * 1;

                my $l = length($s) / 2;

                $inc{int(substr($s, 0, $l))} += ($h{$s} // 1) * 1;
                $inc{int(substr($s, $l))} += ($h{$s} // 1) * 1;
            } else {
                $dec{$s} += ($h{$s} // 1) * 1;
                $inc{$s*2024} += ($h{$s} // 1) * 1;
            }
        }

        foreach my $s (keys %inc) {
            $h{$s} += $inc{$s}
        }

        foreach my $s (keys %dec) {
            $h{$s} -= $dec{$s};

            die if $h{$s} < 0;
        }

#        p {
#            inc => \%inc,
#            dec => \%dec,
#            result => \%h,
#        };

        say "after $i blinks stones count: " . sum values %h;
#        say 'Real stones count: ' . scalar @stones;
#        say 'Real stones: ' . join ' ', @stones;
#        say '';

    }

    my $full_count = 0;

    foreach my $s (keys %h) {
        $full_count += $h{$s};
    }

    say '';
    say $full_count;

}
main();
__END__
