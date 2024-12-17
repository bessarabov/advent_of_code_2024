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

#sub dec2base8 {
#    my ($num) = @_;
#    return sprintf("%o", $num);
#}
#
#sub base8toDec {
#    my ($octal) = @_;
#    return oct($octal);
#}

sub run_op {
    my ($op, $value, $r) = @_;

#p 'run_op';
#p {
#op => $op,
#value => $value,
#r => $r,
#};

# Combo operands 0 through 3 represent literal values 0 through 3.
# Combo operand 4 represents the value of register A.
# Combo operand 5 represents the value of register B.
# Combo operand 6 represents the value of register C.
# Combo operand 7 is reserved and will not appear in valid programs.

    my $combo = $value;

    if ($value == 4) {
        $combo = $r->{A};
    } elsif ($value == 5) {
        $combo = $r->{B};
    } elsif ($value == 6) {
        $combo = $r->{C};
    }

    if ($op == 0) {
# The adv instruction (opcode 0) performs division. The numerator is the value in
# the A register. The denominator is found by raising 2 to the power of the
# instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an
# operand of 5 would divide A by 2^B.) The result of the division operation is
# truncated to an integer and then written to the A register.
        my $numerator = $r->{A};
        my $denominator = 2 ** $combo;
		my $result = int($numerator / $denominator);
		$r->{A} = $result;
    } elsif ($op == 1) {
# The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the
# instruction's literal operand, then stores the result in register B.
		my $result = $r->{B} ^ $value;
		$r->{B} = $result;
    } elsif ($op == 2) {
#The bst instruction (opcode 2) calculates the value of its combo operand
#modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to
#the B register.
		my $result = $combo % 8;
		$r->{B} = $result;

    } elsif ($op == 3) {
#The jnz instruction (opcode 3) does nothing if the A register is 0. However,
#if the A register is not zero, it jumps by setting the instruction pointer to
#the value of its literal operand; if this instruction jumps, the instruction
#pointer is not increased by 2 after this instruction.
		return if $r->{A} == 0;
		return { p => $value };
    } elsif ($op == 4) {
#The bxc instruction (opcode 4) calculates the bitwise XOR of register B and
#register C, then stores the result in register B. (For legacy reasons, this
#instruction reads an operand but ignores it.)
		my $result = $r->{B} ^ $r->{C};
		$r->{B} = $result;
    } elsif ($op == 5) {
#The out instruction (opcode 5) calculates the value of its combo operand
#modulo 8, then outputs that value. (If a program outputs multiple values, they
#are separated by commas.)
		my $result = $combo % 8;
		return { o => $result };
    } elsif ($op == 6) {
#The bdv instruction (opcode 6) works exactly like the adv instruction except
#that the result is stored in the B register. (The numerator is still read from
#the A register.)
        my $numerator = $r->{A};
        my $denominator = 2 ** $combo;
		my $result = int($numerator / $denominator);
		$r->{B} = $result;
    } elsif ($op == 7) {
#The cdv instruction (opcode 7) works exactly like the adv instruction except
#that the result is stored in the C register. (The numerator is still read from
#the A register.)
        my $numerator = $r->{A};
        my $denominator = 2 ** $combo;
		my $result = int($numerator / $denominator);
		$r->{C} = $result;
    } else {
        die $op;
    }

	return {};
}

sub base8toDec {
    my ($octal_str) = @_;
    my $decimal = 0;
    my @digits = split(//, $octal_str);
    foreach my $digit (@digits) {
        die "Invalid octal digit: $digit\n" if $digit !~ /^[0-7]$/;
        $decimal = $decimal * 8 + $digit;
    }
    return $decimal;
}

sub get_answer {
    my ($content, $A) = @_;

#        say $A;
        my $prog_str;
        my $r = {}; # registers
        my $p = 0; # pointer
        my $prog = []; # array with arrays [opcode, operand]

        foreach my $line (split /\n/, $content) {
            if ($line =~ /Register (.): (\d+)\z/) {
                $r->{$1} = $2;
            }

            if ($line =~ /Program: (.*)/) {
                $prog_str = $1;
                my @arr = split /,/, $1;

                while (@arr) {
                    my $op = shift @arr;
                    my $value = shift @arr;

                    push @{$prog}, [$op, $value];
                }
            }
        }

        if ($A) {
            $r->{A} = $A;
        }

    #    p {
    #        r => $r,
    #        p => $p,
    #        prog => $prog,
    #    };

        my @arr;

        my $safe_guard = 0;
        while (1) {
            $safe_guard++;
            die if $safe_guard > 1000;

            my $op = $prog->[$p]->[0];
            my $value = $prog->[$p]->[1];
            my $return = run_op($op, $value, $r);

            if ($return && exists $return->{o}) {
                push @arr, $return->{o};
            }

            if ($return && exists $return->{p}) {
                $p = $return->{p};
            } else {
                $p = $p+1;
            }

    #		say $p;
    #		say scalar(@{$prog});
            last if $p > (scalar(@{$prog}) - 1);
        }

    #	say 'registres:';
    #	p $r;
    #
    #	say 'answer:';
    #	p \@arr;
        my $new_string = join ',', @arr;

    return $new_string;
}

sub binary_search {

    my $answer = '';

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my $prog_str;
    foreach my $line (split /\n/, $content) {
        if ($line =~ /Program: (.*)/) {
            $prog_str = $1;
        };
    }

    my $expected_length = length($prog_str);

    my $p1 =    10_000_000_000_000;
    my $p2 = 1_000_000_000_000_000;

    my $step = 0;

    while($p1 <= $p2) {
        $step++;
        p $step;
        my $middle = int(($p1 + $p2) / 2);

        my $new_string = get_answer($content, $middle);
        my $new_string_length = length($new_string);

        if ($new_string_length == $expected_length) {
            say 'FOUND ANSWER:';
            p $middle;
            die;
        } else {

            if ($new_string_length > $expected_length) {
                $p2 = $middle - 1;
            }

            if ($new_string_length < $expected_length) {
                $p1 = $middle + 1;
            }
        }
    }

}

sub main {

    my $answer = '';

    my $file_name = $ARGV[0];
    my $content = read_file($file_name);

    my $prog_str;
    foreach my $line (split /\n/, $content) {
        if ($line =~ /Program: (.*)/) {
            $prog_str = $1;
        };
    }

    my $min = 35_184_372_088_832;
    my $max = 281_474_976_710_655;

    my $A = $min;
    my $prev_length;

    my $step = 0;
    while(1) {
        $step++;

        my $new_string = get_answer($content, $A);


        my $num1 = $new_string;
        $num1 =~ s/,//g;
		$num1 =~ s/^0+//;

		my $num2 = join '', reverse split //, $num1;
		$num2 =~ s/^0+//;

if ($new_string =~ /0,3,5,5,3,0\z/) {
        say "$new_string <- got from A: $A Step: $step";
}
#        say "$prog_str <- expected";
#        say '';


#        if ($prog_str eq $new_string) {
#            say 'FOUND ANSWER:';
#            p $A;
#            die;
#        }

        $A += int(($max-$min) / 1_000_000);

        die if $A > $max;
    }

}
main();
#binary_search();
__END__
