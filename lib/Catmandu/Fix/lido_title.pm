package Catmandu::Fix::lido_title;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

# TODO: add support for xml:lang

with 'Catmandu::Fix::Base';

has value  => ( fix_arg => 1 );
has source => ( fix_arg => 1 );
has lang => ( fix_opt => 1, default => sub { 'en' } );
has pref => (fix_opt => 1, default => sub { 'preferred' });


sub emit {
	my ( $self, $fixer ) = @_;
	my $value_path  = $fixer->split_path( $self->value );
	my $value_key = pop @$value_path;
	my $source_path = $fixer->split_path( $self->source );
	my $source_key = pop @$source_path;
	my $new_path    = [
		'descriptiveMetadata'
	];
	my $perl = '';
	# $h = the variable that holds the titleSet (it is a hash)
	# titleSet.appellationValue & titleSet.sourceAppellation
	my $h = $fixer->generate_var();
	my $appellationValue = $fixer->generate_var();
	my $sourceAppellation = $fixer->generate_var();
	# They must be declared in $perl beforehand. The value
	# of $appellationValue is something like $__1 etc.
	$perl .= "my ${h} = {};"
	."my ${appellationValue};"
	."my ${sourceAppellation};";
	
	# appellationValue from value
	$perl .= walk($fixer, $value_path, $value_key, $appellationValue);
	
	# sourceAppellation from source
	$perl .= walk($fixer, $source_path, $source_key, $sourceAppellation);
	
	# Add the new path (LIDO) to the document.
	# The titleSet is appended ($append) to new_path
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
				[ 'objectIdentificationWrap', 'titleWrap' ],
				sub {
					my $path_var = shift;
					$fixer->emit_create_path(
						$path_var,
						['titleSet'],
						sub {
							my $title_root = shift;
							my $title_code = '';
							$title_code .= $fixer->emit_create_path(
								$title_root,
								['appellationValue', '$append'],
								sub {
									my $appellation_value_pos = shift;
									return "${appellation_value_pos} = {"
										."'_' => ${appellationValue},"
										."'lang' => '".$self->lang."',"
										."'pref' => '".$self->pref."'"
										."};";
								}
							);
							$title_code .= $fixer->emit_create_path(
								$title_root,
								['sourceAppellation', '$append', '_'],
								sub {
									my $source_appellation_pos = shift;
									return "${source_appellation_pos} = ${sourceAppellation};";
								}
							);
							return $title_code;
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

Catmandu::Fix::lido_title - Create a Lido titleSet

=head1 SYNOPSIS

lido_title(appellationValue, sourceAppellation, lang: en)
