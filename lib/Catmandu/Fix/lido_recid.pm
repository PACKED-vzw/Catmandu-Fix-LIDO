package Catmandu::Fix::lido_recid;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/


with 'Catmandu::Fix::Base';

has recid => ( fix_arg => 1 );

sub emit {
	my ($self, $fixer) = @_;
	my $recid_path = $fixer->split_path($self->recid);
	my $recid_key = pop @$recid_path;
	
	my $new_path = ['lido', 'lidoRecID'];
	
	my $h = $fixer->generate_var();
	my $perl = '';
	$perl .= "my ${h};";
	
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$recid_path,
		sub {
			my $recid_var = shift;
			$fixer->emit_get_key (
				$recid_var,
				$recid_key,
				sub {
					my $recid_val = shift;
					"${h} = ${recid_val};";
				}
			);
		}
	);
	
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			"${path_var} = ${h};";
		}
	);
	
	$perl;
}

1;
