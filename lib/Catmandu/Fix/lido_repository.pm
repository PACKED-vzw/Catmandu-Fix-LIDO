package Catmandu::Fix::lido_repository;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO_Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

# TODO: add support for xml:lang

with 'Catmandu::Fix::Base';

has name   => ( fix_arg => 1 );
has workid => ( fix_arg => 1 );

sub emit {
	my ( $self, $fixer ) = @_;
	my $name_path   = $fixer->split_path( $self->name );
	my $name_key    = pop @$name_path;
	my $workid_path = $fixer->split_path( $self->workid );
	my $workid_key  = pop @$workid_path;

	my $new_path = [
		'lido',                     'descriptiveMetadata',
		'objectIdentificationWrap', 'repositoryWrap',
		'$append'
	];

	my $perl           = '';
	my $h              = $fixer->generate_var();
	my $repositoryName = $fixer->generate_var();
	my $workID         = $fixer->generate_var();
	$perl .= "my ${h} = {};"
	."my ${repositoryName};"
	."my ${workID};";

	# repositoryName from name
	$perl .= walk( $fixer, $name_path, $name_key, $repositoryName );

	# workID from workid
	$perl .= walk( $fixer, $workid_path, $workid_key, $workID );

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
					"${h}->{'repositoryName'} = {"
					  . "'legalBodyName' => {"
					  	. "'appellationValue' => ${repositoryName}" 
					  	. "}" 
					  . "};"
					  . "${h}->{'workID'} = ${workID};"
					  . "${path_var} = ${h};";
				}
			);
		}
	);
	$perl;
}

1;
