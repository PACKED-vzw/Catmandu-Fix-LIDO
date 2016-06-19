package Catmandu::Fix::LIDO::Utility;

use strict;

use Exporter qw(import);

our @EXPORT_OK = qw(walk);


##
# Walk through a path ($path) until at
# $key. Set $h = $val.
# $h must be declared before calling walk()
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