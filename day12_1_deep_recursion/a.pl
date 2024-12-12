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

my $MAX_X;
my $MAX_Y;

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

sub get_area {
    my ($field, $needed_value, $x, $y, $parsed_fields, $all_fields) = @_;

    my $area = 0;

    return 0 if $x < 0;
    return 0 if $y < 0;

    return 0 if $x > $MAX_X;
    return 0 if $y > $MAX_Y;

    return 0 if $parsed_fields->{$x . '_' . $y};

    my $cur_value = $field->[$y]->[$x];

    if ($cur_value eq $needed_value) {
        $all_fields->{$x . '_' . $y}++;

        my $area = 1;

        $parsed_fields->{$x . '_' . $y}++;

        my ($u_a, $u_p) = (0,0);
        if (! $parsed_fields->{$x . '_' . ($y-1)}) {
            $u_a = get_area($field, $needed_value, $x, $y-1, $parsed_fields, $all_fields);
        }

        my ($r_a, $r_p) = (0,0);
        if (! $parsed_fields->{($x+1) . '_' . $y}) {
            $r_a = get_area($field, $needed_value, $x+1, $y, $parsed_fields, $all_fields);
        }

        my ($d_a, $d_p)= (0,0);
        if (! $parsed_fields->{$x . '_' . ($y+1)}) {
            $d_a = get_area($field, $needed_value, $x, $y+1, $parsed_fields, $all_fields);
        }

        my ($l_a, $l_p) = (0,0);
        if (! $parsed_fields->{($x-1) . '_' . $y}) {
            $l_a = get_area($field, $needed_value, $x-1, $y, $parsed_fields, $all_fields);
        }

        $area += $u_a + $d_a + $r_a + $l_a;

        return $area;
    } else {
        return 0;
    };
}

sub calculate_perimeter {
    my ($all) = @_;

p $all;

    my @keys = keys %{$all};

    return 4 if @keys == 1;

    my $p = 0;

    foreach my $x_y (@keys) {
        my ($x, $y) = split /_/, $x_y;

        # u
        if (!exists $all->{ $x . '_' . ($y-1) }) {
            $p++;
        }

        # r
        if (!exists $all->{ ($x+1) . '_' . $y }) {
            $p++;
        }

        # d
        if (!exists $all->{ $x . '_' . ($y+1) }) {
            $p++;
        }

        # l
        if (!exists $all->{ ($x-1) . '_' . $y }) {
            $p++;
        }

    }

    return $p;
}


sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

say $content;

    my @field = get_field($content);
#    p \@field;

    $MAX_X = scalar(@{$field[0]})-1;
    $MAX_Y = scalar(@field)-1;

    # hash
    # key x_y (some of x_y of area)
    # value map { area perimeter }
    my $h = {};

    # hash
    # key x_y  or the field that is already parsed
    my $parsed_fields = {};

    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
#            say "$x $y";

            my $x_y = $x . '_' . $y;
            next if $parsed_fields->{$x_y};

            my $value = $field[$y]->[$x];
            my $all_fields = {};

            my $area = get_area(
                \@field,
                $value,
                $x,
                $y,
                $parsed_fields,
                $all_fields,
            );

            $h->{$x . '_' . $y} = {
                area => $area,
                all_fields => $all_fields,
            };

            die if $parsed_fields->{$x_y} != 1;
        }
    }

    foreach my $x_y (keys %{$h}) {
        $h->{$x_y}->{perimeter} = calculate_perimeter($h->{$x_y}->{all_fields});
    }

#    p $parsed_fields;
#    p $h;

    foreach my $x_y (keys %{$h}) {
        $answer += $h->{$x_y}->{perimeter} * $h->{$x_y}->{area};
    }

    say $answer;

}
main();
__END__
