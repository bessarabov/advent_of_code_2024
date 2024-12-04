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

sub has {
    my ($square) = @_;

    my @arr = get_field($square);

#say $square;

my $d1 = $arr[0]->[0] . $arr[1]->[1] . $arr[2]->[2];
my $d2 = $arr[2]->[0] . $arr[1]->[1] . $arr[0]->[2];

    if (
        ( ($d1 eq 'MAS') or ($d1 eq 'SAM') )
        and ( ($d2 eq 'MAS') or ($d2 eq 'SAM') )
    ) {
        return 1;
    }

#say $d1;
#say $d2;
#die;

    return 0;
}

sub main {

    my $answer = 0;

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my @field = get_field($content);
#    p \@field;

    my $max_x = scalar(@{$field[0]})-1;
    my $max_y = scalar(@field)-1;


    foreach my $y (0..($max_y-2)) {
        foreach my $x (0..($max_x-2)) {
#say "x: $x y: $y";

#say ':';
my $square=
$field[$y]->[$x] . $field[$y]->[$x+1] . $field[$y]->[$x+2] . "\n"
. $field[$y+1]->[$x] . $field[$y+1]->[$x+1] . $field[$y+1]->[$x+2] . "\n"
. $field[$y+2]->[$x] . $field[$y+2]->[$x+1] . $field[$y+2]->[$x+2] . "\n"
;

        if (has($square)) {
            $answer++;
        }


#            print $field[$y]->[$x];
#            print " ";
        }
    }

    say '';
    say '-'x78;
    say $answer;

}
main();
__END__
