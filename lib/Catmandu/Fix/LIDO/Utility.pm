package Catmandu::Fix::LIDO::Utility;

use strict;

use Data::Dumper qw(Dumper);

use Exporter qw(import);
use String::Util qw(trim);

our @EXPORT_OK = qw(walk declare_source split_path);

##
# $fixer->split_path with local fixes
# Loosely adapted from the example in the C Programming Language
sub split_path {
    my ($path) = @_;
    
    my @splitted_path;
    my @component;

    my @chars = split(//, trim($path));

    foreach my $char (@chars) {
        if ($char eq '.' || $char eq '/') {
            my $previous = pop(@component);

            # If $previous equals \, do not split on $char and append
            # $char to @component. It is a part of the path key, not the path.
            # $previous is thrown away if it is \, as it is nowhere in the
            # original path.
            if (defined($previous)) {
                if ($previous eq '\\') {
                    push(@component, $char);
                } else {
                    # Perform the split action
                    push(@component, $previous);
                    push(@splitted_path, join('', @component));
                    # Empty @component
                    @component = ();
                }
            }
        } else {
            # It is not a split char, so add to @component
            push(@component, $char);
        }
    }

    # Add the last @component (between the last ./ and the end of the string)
    if (scalar @component != 0) {
        push(@splitted_path, join('', @component));
    }

return \@splitted_path;
}


##
# For a source $var, that is a path parameter to a fix,
# use walk() to get the value and return the generated
# $perl code.
# @param $fixer
# @param $var
# @param $declared_var
# @return $fixer emit code
sub declare_source {
	my ( $fixer, $var, $declared_var ) = @_;

	my $perl = '';

	my $var_path = split_path ( $var );
	my $var_key = pop @$var_path;
	$perl .= walk($fixer, $var_path, $var_key, $declared_var);
	return $perl;
}

##
# Walk through a path ($path) until at
# $key. Set $h = $val in the fixer code.
# $h must be declared before calling walk()
# This has the effect of assigning $val (the value of the leaf
# node you're walking to) to $h, so you can use $h in your fix.
# @param $fixer
# @param $path
# @param $key
# @param $h
# @return $fixer emit code
sub walk {
	my ($fixer, $path, $key, $h) = @_;

	my $perl = '';
	
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$path,
		sub {
			my $var = shift;
			$fixer->emit_get_key(
				$var,
				$key,
				sub {
					my $val = shift;
					"${h} = ${val};";
				}
			);
		}
	);
	
	return $perl;
}

1;