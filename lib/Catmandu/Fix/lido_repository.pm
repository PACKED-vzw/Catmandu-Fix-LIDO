package Catmandu::Fix::lido_repository;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk path_and_key);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

# TODO: add support for xml:lang

with 'Catmandu::Fix::Base';

has name   => ( fix_arg => 1 );
has workid => ( fix_arg => 1 );
has lang   => ( fix_opt => 1, default => sub { 'en' } );

sub emit {
	my ( $self, $fixer ) = @_;
	my ( $name_path, $name_key ) = path_and_key( $fixer, $self->name );
	my $workid_path = $fixer->split_path( $self->workid );
	my $workid_key  = pop @$workid_path;

	my $new_path = ['descriptiveMetadata'];

	#		'objectIdentificationWrap', 'repositoryWrap'
	#	];

	my $perl           = '';
	my $h              = $fixer->generate_var();
	my $repositoryName = $fixer->generate_var();
	my $workID         = $fixer->generate_var();
	$perl .= "my ${h} = {};" . "my ${repositoryName};" . "my ${workID};";

	# repositoryName from name
	$perl .= walk( $fixer, $name_path, $name_key, $repositoryName );

	# workID from workid
	$perl .= walk( $fixer, $workid_path, $workid_key, $workID );

	# Append the repositorySet ($append)
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $descriptive_metadata_root = shift;
			my $descriptive_metadata_code = '';
			$descriptive_metadata_code .= $fixer->emit_create_path(
				$descriptive_metadata_root,
				['lang'],
				sub {
					my $lang_pos = shift;
					return "${lang_pos} = '" . $self->lang . "';";
				}
			);
			$descriptive_metadata_code .= $fixer->emit_create_path(
				$descriptive_metadata_root,
				[ 'objectIdentificationWrap', 'repositoryWrap' ],
				sub {
					my $path_var = shift;
					$fixer->emit_create_path(
						$path_var,
						['repositorySet'],
						sub {
							my $repository_root = shift;
							my $repository_code = '';
							$repository_code .= $fixer->emit_create_path(
								$repository_root,
								[
									'repositoryName',   'legalBodyName',
									'appellationValue', '$append',
									'_'
								],
								sub {
									my $repository_name_pos = shift;
									return "${repository_name_pos} = ${repositoryName};";
								}
							);
							$repository_code .= $fixer->emit_create_path(
								$repository_root,
								[ 'workID', '$append', '_' ],
								sub {
									my $workid_pos = shift;
									return "${workid_pos} = ${workID};";
								}
							);
							return $repository_code;
						}
					);
				}
			);
			return $descriptive_metadata_code;
		}
	);
	$perl;
}

1;

__END__

=pod

=head1 NAME
Catmandu::Fix::lido_repository - LIDO Repository

=head1 SYNOPSIS
lido_repository(legalBodyName, workID, lang: en)
