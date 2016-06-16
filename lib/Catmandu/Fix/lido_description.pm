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
	
	my $new_path = ['descriptiveMetadata'];
	
	my $h = $fixer->generate_var();
	my $perl = '';
	
	$perl .= "my ${h};";
	
	$perl .= walk($fixer, $description_path, $description_key, $h);
	
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
					return "${lang_pos} = '".$self->lang."';"
				}
			);
			$descriptive_metadata_code .= $fixer->emit_create_path(
				$descriptive_metadata_root,
				['objectIdentificationWrap', 'objectDescriptionWrap', 'objectDescriptionSet', 'descriptiveNoteValue', '$append'],
				sub {
					my $description_note_pos = shift;
					return "${description_note_pos} = {"
						."'_' => ${h},"
						."'lang' => '".$self->lang."'"
						."}";
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
Catmandu::Fix::description - LIDO descriptive note

=head1 SYNOPSIS
lido_description(description, lang: en)
