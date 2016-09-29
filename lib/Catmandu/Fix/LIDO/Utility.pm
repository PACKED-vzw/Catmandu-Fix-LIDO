package Catmandu::Fix::LIDO::Utility;

use strict;

use 5.18.0;

use Data::Util qw(is_array_ref is_hash_ref is_string is_number);
use Data::Dumper qw(Dumper);

use Exporter qw(import);

our @EXPORT_OK = qw(walk declare_source deep_hash deep_hash_basic);

sub deep_hash {
	my ( $hash, $path ) = @_;
	my $local_root = $hash;
	my $previous_root;
	my $pos = 0;
	foreach my $component (@$path) {
		print ("$component: ");

		# Two cases; either $local_root is a hashref or it is an arrayref
		print ("root: ".ref($local_root)."\n");
#		print ("comp: ".ref($local_root->{$component})."\n");
		if (is_modifier($component)) {
			$local_root = modifier_action($local_root, $component);
		} else {
			if (is_hash_ref($local_root)) {
				# Default case
				if (exists ($local_root->{$component})) {
					# This key exists, so get on with our lives
					# But if the next key exists and is not a hashref, create it as array
					if (!is_hash_ref($local_root->{$component}) && !is_array_ref($local_root->{$component})) {
						$local_root->{$component} = [$local_root->{$component}];
					} else {
						if (next_is_modifier($path, $pos)) {
							$local_root->{$component} = [$local_root->{$component}];
						}
					}
					$local_root = $local_root->{$component};
				} else {
					# Create it
					# If the next key is a modifier, create an array instead of a hash
					if (next_is_modifier($path, $pos)) {
						$local_root->{$component} = [];
					} else {
						$local_root->{$component} = {};
					}
					$local_root = $local_root->{$component};
				}
			} elsif (is_array_ref($local_root)) {
				# Array
				push @$local_root, {
					$component => {}
				};
				$local_root = $local_root->[-1]->{$component};
			} else {
				# Complicated stuff
				print($local_root);
			}
		}
		$pos++;
	}
}

##
# Check to see if the next item in $path is a modifier
sub next_is_modifier {
	my ($path, $pos) = @_;
	if (defined($path->[$pos + 1])) {
		my $next = $path->[$pos + 1];
		return is_modifier($next);
	}
	return 0;
}

sub is_modifier {
	my ($component) = @_;
	if ($component eq '$append' || $component eq '$prepend' || $component eq '$start' || $component eq '$end' || $component eq '*' || is_number($component)) {
		return 1;
	}
}

sub modifier_action {
	my ($root, $modifier) = @_;
	if ($modifier eq '$append') {
		push @$root, {};
		return $root->[-1];
	} elsif ($modifier eq '$prepend') {
		unshift @$root, {};
		return $root->[0];
	} elsif ($modifier eq '$start') {
		return $root->[0];
	} elsif ($modifier eq '$end') {
		return $root->[-1];
	} elsif ($modifier eq '*') {

	} elsif (is_number($modifier)) {
		if (defined($root->[$modifier])) {
			return $root->[$modifier];
		} else {
			# error
		}
	}
}


sub path_component_basic {
	my ($root, $component) = @_;
	if (is_hash_ref($root)) {
		if (!exists($root->{$component})) {
			$root->{$component} = {};
			$root = $root->{$component};
		} else {
			if (!is_hash_ref($root->{$component})) {
				if (!is_array_ref($root->{$component})) {
					$root->{$component} = [$root->{$component}];
				}
				unshift @{$root->{$component}}, {};
				$root = $root->{$component}->[0];
			} else {
				$root = $root->{$component};
			}
		}
	} elsif (is_array_ref($root)) {
		$root = $root->[0];
	}
	return $root;
}

sub deep_hash_basic {
	my ($existing_hash, $path) = @_;
	my $current_root = $existing_hash;
	while (my $component = shift @$path) {
		if (!exists($current_root->{$component})) {
			$current_root->{$component} = {};
			$current_root = $current_root->{$component};
		} else {
			if(!is_hash_ref($current_root->{$component})) {
				if (!is_array_ref($current_root->{$component})) {
					$current_root->{$component} = [$current_root->{$component}];
				}
				unshift @{$current_root->{$component}}, {};
				$current_root = $current_root->{$component}->[0];
			} else {
				$current_root = $current_root->{$component};
			}
		}
		
	}
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
	my ( $fixer, $path, $key, $h ) = @_;
	
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