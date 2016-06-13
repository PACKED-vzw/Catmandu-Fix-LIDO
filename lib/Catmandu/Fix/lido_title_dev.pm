package Catmandu::Fix::lido_title_dev;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Digest::MD5;

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

has value  => ( fix_arg => 1 );
has source => ( fix_arg => 1 );


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
	my $h = $fixer->generate_var();
	$perl .= "my ${h} = {};";
	
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
