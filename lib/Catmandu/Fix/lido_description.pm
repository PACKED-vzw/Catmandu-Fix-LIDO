package Catmandu::Fix::lido_description;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/


with 'Catmandu::Fix::Base';

has description => (fix_arg => 1);
has lang => (fix_opt => 1, default => sub { 'en' });

sub emit {
	my ($self, $fixer) = @_;
	
	my $description_path = $fixer->split_path($self->description);
	my $description_key = pop @$description_path;
	
	my $new_path = ['descriptiveMetadata', 'objectIdentificationWrap', 'objectDescriptionWrap',
	'objectDescriptionSet', 'descriptiveNoteValue', '$append'];
	
	my $h = $fixer->generate_var();
	my $perl = '';
	
	$perl .= "my ${h};";
	
	$perl .= walk($fixer, $description_path, $description_key, $h);
	
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			if ($self->lang) {
				return "${path_var} = {"
					."'_' => ${h},"
					."'lang' => '".$self->lang."'"
					."}";
			} else {
				return "${path_var} = {"
					."'_' => ${h}"
					."}";
			}
		}
	);
	
	$perl;
	
}

1;
