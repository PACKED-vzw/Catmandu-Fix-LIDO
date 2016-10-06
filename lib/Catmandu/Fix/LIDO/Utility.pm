package Catmandu::Fix::LIDO::Utility;

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(walk declare_source);


sub mk_append {
	my ($fixer, $root, $path) = @_;
	my $perl = '';
	push @$path, '$append';
	$perl .= $fixer->emit_create_path(
		$root,
		$path,
		sub {
			my $local_root = shift;
			return "${local_root} = {};";
		}
	);
	return $perl;
}

##
# Make a generic wrap. A wrap is non-repeatable and thus is always a hash.
# You can add extra fields to this hash using do with(path); add_field(); end
sub mk_wrap {
    my ($fixer, $root, $path) = @_;
    my $perl = '';
    $perl .= $fixer->emit_create_path(
        $root,
        $path,
        sub {
            my $local_root = shift;
            return "${local_root} = {};";
        }
    );
    return $perl;
}

##
# For a source $var, that is a path parameter to a fix,
# use walk() to get the value and return the generated
# $perl code.
sub declare_source {
	my ( $fixer, $var, $declared_var ) = @_;

	my $perl = '';

	my $var_path = $fixer->split_path ( $var );
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