#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use feature 'say';
use utf8;
use open qw(:std :utf8);

use Moment;
use Test::More;
use Data::Dumper;

my $MAX_X;
my $MAX_Y;

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
        my @new_elements;
        foreach my $el (@elements) {
            if ($el eq '#') {
                push @new_elements, '#';
                push @new_elements, '#';
            } elsif ($el eq 'O') {
                push @new_elements, '[';
                push @new_elements, ']';
            } elsif ($el eq '.') {
                push @new_elements, '.';
                push @new_elements, '.';
            } elsif ($el eq '@') {
                push @new_elements, '@';
                push @new_elements, '.';
            } else {
                die $el;
            }
        }

        push @field, \@new_elements;
    }

    return @field;
}

sub tmp_get_field {
    my ($content) = @_;

    my @field;

    foreach my $row (split /\n/, $content) {
        my @elements = split //, $row;
        push @field, \@elements;
    }

    return @field;
}

sub output_field {
    my ($f, $cur_x, $cur_y) = @_;

    $cur_x //= -1;
    $cur_y //= -1;

    my @field = @{$f};

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            if ($x == $cur_x && $y == $cur_y) {
                print('@');
            } else {
                my $value = $field[$y]->[$x];
                print($value);
            }
        }
        say '';
    }

}

sub min {
    my ($one, $two) = @_;

    return $one < $two ? $one : $two;
}

sub max {
    my ($one, $two) = @_;

    return $one > $two ? $one : $two;
}

sub calculate_gps {
    my (@field) = @_;

    my @arr;
    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (1..($max_y-1)) {
        foreach my $x (1..($max_x-1)) {
            my $value = $field[$y]->[$x];
            if ($value eq '[') {
#                p $x;
#                p $y;
                push @arr, $y * 100 + $x;
            }

        }
    }

    return @arr;
}

sub get_new_row {
    my ($cur_row, $s, $cur_x) = @_;

#p $cur_row;
#p $s;
#p $cur_x;
#
    my $moved = 0;

    if ($s eq '>' || $s eq 'v') {
        die if $cur_row->[$cur_x+1] ne 'O';

        # need to find first empty
        my $first_empty_x;
        TMP:
        foreach my $x (($cur_x+2)..(scalar(@{$cur_row})-1)) {
            if ($cur_row->[$x] eq '#') {
                last TMP
            }

            if ($cur_row->[$x] eq '.') {
                $first_empty_x = $x;
                last TMP
            }
        }
        if (defined $first_empty_x) {
            # need to move everything to the right
            # to do it i'm just moving one element to the right
            $cur_row->[$first_empty_x] = 'O';
            $cur_row->[$cur_x+1] = '.';
            $moved = 1;
        } else {
            # nothing to do, as there are no free spaces
        }
    } elsif ($s eq '<' || $s eq '^') {
        die if $cur_row->[$cur_x-1] ne 'O';

        # need to find first empty
        my $first_empty_x;
        TMP:
        for (my $x=$cur_x-2; $x>=0; $x--) {
            if ($cur_row->[$x] eq '#') {
                last TMP
            }
            if ($cur_row->[$x] eq '.') {
                $first_empty_x = $x;
                last TMP
            }
        }

        if (defined $first_empty_x) {
            # need to move everything to the right
            # to do it i'm just moving one element to the right
            $cur_row->[$first_empty_x] = 'O';
            $cur_row->[$cur_x-1] = '.';
            $moved = 1;
        } else {
            # nothing to do, as there are no free spaces
        }
    } else {
        die
    }

    return ($cur_row, $moved);
}

sub show_chars_count {
    my ($field) = @_;

    my @field = @{$field};

    my %chars;
    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            $chars{$value}++;
        }
    }

    p \%chars;
}

sub move {
    my ($field, $cur_x, $cur_y, $s) = @_;

    my $there_was_move = 0;

    # find the nearest box that we are trying to move with our step
    my $box_x;
    my $box_y;

    if ($s eq '<') { $box_x = $cur_x - 2; $box_y = $cur_y; }
    elsif ($s eq '>') { $box_x = $cur_x + 1; $box_y = $cur_y; }
    elsif ($s eq '^') {
        $box_x = $cur_x; $box_y = $cur_y - 1;
        my $value = $field->[$box_y]->[$box_x];
        if ($value eq ']') {
            $box_x--;
        }
    }
    elsif ($s eq 'v') {
        $box_x = $cur_x; $box_y = $cur_y + 1;
        my $value = $field->[$box_y]->[$box_x];
        if ($value eq ']') {
            $box_x--;
        }
    }
    else { die }
    if ($field->[$box_y]->[$box_x] ne '[') {
        die;
    }

    # calculate all boxes positions
    my %all_boxes;

    foreach my $y (0..$MAX_Y) {
        foreach my $x (0..$MAX_X) {
            my $value = $field->[$y]->[$x];
            if ($value eq '[') {
                $all_boxes{$x . '_' . $y} = {};
            }
        }
    }

    # for each box find all the neareast boxes that will be moved if that box is moved
    foreach my $box_id (keys %all_boxes) {
        my ($this_box_x, $this_box_y) = split /_/, $box_id;

        # <
        if (exists $all_boxes{ ($this_box_x - 2) . '_' . $this_box_y}) {
            $all_boxes{$box_id}->{'<'}->{($this_box_x - 2) . '_' . $this_box_y} = 1;
        }

        # >
        if (exists $all_boxes{ ($this_box_x + 2) . '_' . $this_box_y}) {
            $all_boxes{$box_id}->{'>'}->{($this_box_x + 2) . '_' . $this_box_y} = 1;
        }

        # ^
        if (exists $all_boxes{ $this_box_x . '_' . ($this_box_y-1) }) {
            $all_boxes{$box_id}->{'^'}->{ $this_box_x . '_' . ($this_box_y-1) } = 1;
        }
        if (exists $all_boxes{ ($this_box_x - 1) . '_' . ($this_box_y-1) }) {
            $all_boxes{$box_id}->{'^'}->{ ($this_box_x - 1) . '_' . ($this_box_y-1) } = 1;
        }
        if (exists $all_boxes{ ($this_box_x + 1) . '_' . ($this_box_y-1) }) {
            $all_boxes{$box_id}->{'^'}->{ ($this_box_x + 1) . '_' . ($this_box_y-1) } = 1;
        }

        # v
        if (exists $all_boxes{ $this_box_x . '_' . ($this_box_y+1) }) {
            $all_boxes{$box_id}->{'v'}->{ $this_box_x . '_' . ($this_box_y+1) } = 1;
        }
        if (exists $all_boxes{ ($this_box_x - 1) . '_' . ($this_box_y+1) }) {
            $all_boxes{$box_id}->{'v'}->{ ($this_box_x - 1) . '_' . ($this_box_y+1) } = 1;
        }
        if (exists $all_boxes{ ($this_box_x + 1) . '_' . ($this_box_y+1) }) {
            $all_boxes{$box_id}->{'v'}->{ ($this_box_x + 1) . '_' . ($this_box_y+1) } = 1;
        }
    }

#    p \%all_boxes;

    # find out all the boxes that are needed to be moved
    my %all_boxes_to_move;

    $all_boxes_to_move{$box_x . '_' . $box_y} = 1;

    TMP:
    while (1) {
        my $boxes_added = 0;
        foreach my $box_id (keys %all_boxes_to_move) {
            my @other_boxes = keys %{$all_boxes{$box_id}->{$s}};
            foreach my $tmp_box_id (@other_boxes) {
                if (not exists $all_boxes_to_move{$tmp_box_id}) {
                    $all_boxes_to_move{$tmp_box_id} = 1;
                    $boxes_added++;
                }
            }
        }

        last TMP if $boxes_added == 0;
    }

#    p \%all_boxes_to_move;

    # check if all the boxes can be moved TODO
    my $can_move_all_boxes = 0;

    foreach my $box_id (sort keys %all_boxes_to_move) {
        my ($this_box_x, $this_box_y) = split /_/, $box_id;

        if ($s eq '<') { return 0 if $field->[$this_box_y]->[$this_box_x-1] eq '#' }
        elsif ($s eq '>') { return 0 if $field->[$this_box_y]->[$this_box_x+2] eq '#' }
        elsif ($s eq '^') {
            return 0 if $field->[$this_box_y-1]->[$this_box_x] eq '#';
            return 0 if $field->[$this_box_y-1]->[$this_box_x+1] eq '#';
        }
        elsif ($s eq 'v') {
            return 0 if $field->[$this_box_y+1]->[$this_box_x] eq '#';
            return 0 if $field->[$this_box_y+1]->[$this_box_x+1] eq '#';
        }
        else { die }
    }

    # if we are still here this means that we can move all the boxes
    # at first mark all the places of boxes as free
    foreach my $box_id (sort keys %all_boxes_to_move) {
        my ($this_box_x, $this_box_y) = split /_/, $box_id;
        $field->[$this_box_y]->[$this_box_x] = '.';
        $field->[$this_box_y]->[$this_box_x+1] = '.';
    }

    # next - put all the boxes to the new positions
    foreach my $box_id (sort keys %all_boxes_to_move) {
        my ($this_box_x, $this_box_y) = split /_/, $box_id;

        if ($s eq '<') {
            $field->[$this_box_y]->[$this_box_x-1] = '[';
            $field->[$this_box_y]->[$this_box_x] = ']';
        } elsif ($s eq '>') {
            $field->[$this_box_y]->[$this_box_x+2] = ']';
            $field->[$this_box_y]->[$this_box_x+1] = '[';
        } elsif ($s eq '^') {
            $field->[$this_box_y-1]->[$this_box_x] = '[';
            $field->[$this_box_y-1]->[$this_box_x+1] = ']';
        } elsif ($s eq 'v') {
            $field->[$this_box_y+1]->[$this_box_x] = '[';
            $field->[$this_box_y+1]->[$this_box_x+1] = ']';
        }
        else { die }

    }


    return 1; # notify that there was move
}

sub check_field_for_validity {
    my ($f) = @_;
    my @field = @{$f};

    foreach my $y (0..$MAX_Y) {
        my @row_elements;
        foreach my $x (0..$MAX_X) {
            push @row_elements, $field[$y]->[$x];
        }
        my $str = join '', @row_elements;
        die if $str =~ /\.\]/;
        die if $str =~ /\[\./;
        die if $str =~ /\[\[/;
        die if $str =~ /\]\]/;
    }
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my ($map, $steps) = split /\n\n/, $content;

    my @field = get_field($map);

    $steps =~ s/\n//g;
    my @steps = split //, $steps;

    my $cur_x;
    my $cur_y;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;

    $MAX_X = $max_x;
    $MAX_Y = $max_y;

    foreach my $y (0..$max_y) {
        foreach my $x (0..$max_x) {
            my $value = $field[$y]->[$x];
            if ($value eq '@') {
                $cur_x = $x;
                $cur_y = $y;
                $field[$y]->[$x] = '.';
            }
        }
    }

    my %moves = (
        '^' => { y => -1, x => 0 },
        'v' => { y => 1, x => 0 },
        '>' => { y => 0, x => 1 },
        '<' => { y => 0, x => -1 },
    );

    say 'Initial state:';
    output_field(\@field, $cur_x, $cur_y);
    say '';

    my $i = 0;
    foreach my $s (@steps) {
        $i++;
        say "## Step $i $s";
        say "Move $s:";

        my $new_x = $cur_x + $moves{$s}->{x};
        my $new_y = $cur_y + $moves{$s}->{y};

        if ($field[$new_y]->[$new_x] eq '.') {
            $cur_x = $new_x;
            $cur_y = $new_y;
        } elsif ($field[$new_y]->[$new_x] eq '#') {
            # do nothing
        } else {
            if (move(\@field, $cur_x, $cur_y, $s)) {
                $cur_x += $moves{$s}->{x};
                $cur_y += $moves{$s}->{y};
            }
        }

#        output_field(\@field, $cur_x, $cur_y);
#        say '';

        check_field_for_validity(\@field);

#        die if $i > 10
   }

    say 'After all moves:';
    output_field(\@field);
    say '';

    my @gps = calculate_gps(@field);
    $answer += $_ foreach @gps;

    say $answer;

}
main();
__END__
