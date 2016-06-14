package Catmandu::Fix::lido_repository;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

# TODO: add support for xml:lang

with 'Catmandu::Fix::Base';

has name => ( fix_arg => 1 );
has workid => ( fix_arg => 1 );

sub emit {
	my ($self, $fixer) = @_;
	my $name_path = $fixer->split_path($self->name);
	my $name_key = pop @$name_path;
	my $workid_path = $fixer->split_path($self->workid);
	my $workid_key = pop @$workid_path;
	
	my $new_path = ['lido', 'descriptiveMetadata', 'objectIdentificationWrap', 'repositoryWrap', '$append'];
	
	my $perl = '';
	my $h = $fixer->generate_var();
	$perl .= "my ${h} = {};";
	
	# repositoryName from name
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$name_path,
		sub {
			my $name_var = shift;
			$fixer->emit_get_key(
				$name_var,
				$name_key,
				sub {
					my $name_val = shift;
					#legalBodyName.appellationValue
					"${h}->{'repositoryName'} = {"
						."'legalBodyName' => {"
							."'appellationValue' => ${name_val}"
							."}"
						."};";
				}
			);
		}
	);
	
	# workID from workid
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$workid_path,
		sub {
			my $workid_var = shift;
			$fixer->emit_get_key(
				$workid_var,
				$workid_key,
				sub {
					my $workid_val = shift;
					"${h}->{'workID'} = ${workid_val};";
				}
			);
		}
	);
	
	# Append the repositorySet ($append)
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			$fixer->emit_create_path(
				$path_var,
				['repositorySet'],
				sub {
					my $path_var = shift;
					"${path_var} = ${h};";
				}
			);
		}
	);
	$perl;
}

1;
