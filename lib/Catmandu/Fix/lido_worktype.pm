package Catmandu::Fix::lido_worktype;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/


with 'Catmandu::Fix::Base';


has worktype => (fix_arg => 1);
has conceptid => (fix_opt => 1);
has lang => (fix_opt => 1, default => sub { 'en' } );

sub emit {
	my ($self, $fixer) = @_;
	
	my $worktype_path = $fixer->split_path($self->worktype);
	my $worktype_key = pop @$worktype_path;
	
	my $new_path = ['lido', 'descriptiveMetadata', 'objectClassificationWrap', 'objectWorkTypeWrap', '$append', 'objectWorkType'];
	
	my $h = $fixer->generate_var();
	my $workType = $fixer->generate_var();
	my $conceptID = $fixer->generate_var();
	
	my $perl = '';
	
	$perl .= "my ${h} = {};"
	."my (${workType}, ${conceptID});";
	
	$perl .= walk($fixer, $worktype_path, $worktype_key, $workType);
	
	if ($self->conceptid) {
		my $conceptid_path = $fixer->split_path($self->conceptid);
		my $conceptid_key = pop @$conceptid_path;
		$perl .= walk($fixer, $conceptid_path, $conceptid_key, $conceptID);
	}
	
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			my $code = '';
			$code .= "${h}->{'term'} = ${workType};";
			if ($self->conceptid) {
				$code .= "${h}->{'conceptID'} = ${conceptID};";
			}
			$code .= "${path_var} = ${h};";
			$code;
		}
	);
	
	$perl;
	
}

1;