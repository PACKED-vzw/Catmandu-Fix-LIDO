package Catmandu::Fix::lido_title;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO_Utility qw(walk);

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
			my $path_var = shift;
			$fixer->emit_create_path(
				$path_var,
				['titleSet'],
				sub {
					my $path_var = shift;
					"${h} = {"
						."'appellationValue' => ${appellationValue},"
						."'sourceAppellation' => ${sourceAppellation}"
						."};"
					."${path_var} = ${h};";
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
