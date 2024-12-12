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

sub belongs_to_some_cluster {
    my ($field, $x, $y, $value, $x_y2cluster_id) = @_;

    return 0 if $x == 0 && $y == 0;

    # top
    my $id_from_top = check($field, $x, $y-1, $value, $x_y2cluster_id);
    if ($id_from_top != 0) {
        return $id_from_top;
    }

    # left
    my $id_from_left = check($field, $x-1, $y, $value, $x_y2cluster_id);
    return $id_from_left;
}

sub check {
    my ($field, $x, $y, $expected_value, $x_y2cluster_id) = @_;

    return 0 if $x < 0;
    return 0 if $y < 0;

    return 0 if $x > $MAX_X;
    return 0 if $y > $MAX_Y;

    if ($field->[$y]->[$x] eq $expected_value) {
        if (not exists $x_y2cluster_id->{$x . '_' . $y}) {
            p $x_y2cluster_id;
            warn $x;
            warn $y;
            die;
        }
        return $x_y2cluster_id->{$x . '_' . $y};
    } else {
        return 0;
    }

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
    # key - cluster_id
    # value map { }
    my $h = {};
    my $x_y2cluster_id = {};

    my $cluster_id = 0;


    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $x_y = $x . '_' . $y;
            my $value = $field[$y]->[$x];

            if (my $belongs_id = belongs_to_some_cluster(\@field, $x, $y, $value, $x_y2cluster_id)) {
                $h->{$belongs_id}->{all_fields}->{$x_y} = 1;
                $x_y2cluster_id->{$x_y} = $belongs_id;
            } else {
                $cluster_id++;
                $h->{$cluster_id}->{all_fields}->{$x_y} = 1;
                $h->{$cluster_id}->{value} = $value;
                $x_y2cluster_id->{$x_y} = $cluster_id;
            }
        }
    }

    my %c;
    my @new_field;
    foreach my $cluster_id (keys %{$h}) {
        $c{$cluster_id}++;
        foreach my $x_y (keys %{$h->{$cluster_id}->{all_fields}}) {
            my ($x, $y) = split /_/, $x_y;
            if (defined $new_field[$y]->[$x]) {
                die;
            }
            $new_field[$y]->[$x] = chr(64+ $cluster_id);
        }
    }

    foreach my $row (@new_field) {
        foreach my $char (@{$row}) {
            print $char;
        }
        say '';
    }

#    p $h;
#    p $x_y2cluster_id;

    foreach my $cluster_id (keys %{$h}) {
        $h->{$cluster_id}->{perimeter} = calculate_perimeter($h->{$cluster_id}->{all_fields});
        $h->{$cluster_id}->{area} = scalar keys %{$h->{$cluster_id}->{all_fields}};
    }

    foreach my $cluster_id (keys %{$h}) {
        $answer += $h->{$cluster_id}->{perimeter} * $h->{$cluster_id}->{area};
    }

    say $answer;

}
main();
__END__
