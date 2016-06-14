package Catmandu::Fix::lido_title;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

# TODO: add support for xml:lang

with 'Catmandu::Fix::Base';

has value  => ( fix_arg => 1 );
has source => ( fix_arg => 1 );
has lang => ( fix_opt => 1, default => sub { 'en' } );


sub emit {
	my ( $self, $fixer ) = @_;
	my $value_path  = $fixer->split_path( $self->value );
	my $value_key = pop @$value_path;
	my $source_path = $fixer->split_path( $self->source );
	my $source_key = pop @$source_path;
	my $new_path    = [
		'lido',                     'descriptiveMetadata',
		'objectIdentificationWrap', 'titleWrap',
		'$append'
	];
	my $perl = '';
	# $h = the variable that holds the titleSet (it is a hash)
	# titleSet.appellationValue & titleSet.sourceAppellation
	my $h = $fixer->generate_var();
	$perl .= "my ${h} = {};";
	
	# appellationValue from value
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$value_path,
		sub {
			my $value_var = shift;
			$fixer->emit_get_key(
				$value_var,
				$value_key,
				sub {
					my $value_val = shift;
					"${h}->{'appellationValue'} = ${value_val};";
				}
			);
		}
	);
	
	# sourceAppellation from source
	$perl .= $fixer->emit_walk_path(
		$fixer->var,
		$source_path,
		sub {
			my $source_var = shift;
			$fixer->emit_get_key(
				$source_var,
				$source_key,
				sub {
					my $source_val = shift;
					"${h}->{'sourceAppellation'} = ${source_val};";
				}
			);
		}
	);
	
	# Add the new path (LIDO) to the document.
	# The titleSet is appended ($append) to new_path
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			$fixer->emit_create_path(
				$path_var,
				['titleSet'],
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

__END__

=pod

=head1 NAME

Catmandu::Fix::lido_title - Create a Lido titleSet

=head1 SYNOPSIS

Create a Lido titleSet consisting of a appellationValue and a sourceAppellation from
two items in the current document.

	# Fix
	lido_title(appellationValue, sourceAppellation)
