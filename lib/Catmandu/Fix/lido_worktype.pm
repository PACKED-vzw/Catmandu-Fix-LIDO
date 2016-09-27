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
has source => (fix_opt => 1, default => sub { 'AAT' } );
has pref => (fix_opt => 1, default => sub { 'preferred' });

sub emit {
	my ($self, $fixer) = @_;
	
	my $worktype_path = $fixer->split_path($self->worktype);
	my $worktype_key = pop @$worktype_path;
	
	my $new_path = ['descriptiveMetadata'];
	
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
				[ 'objectClassificationWrap', 'objectWorkTypeWrap', 'objectWorkType', '$append' ],
				sub {
					my $worktype_root = shift;
					my $code = '';
					$code .= $fixer->emit_create_path(
						$worktype_root,
						['term', '$append'],
						sub {
							my $worktype_pos = shift;
							return "${worktype_pos} = {"
								."'_' => ${workType},"
								."'lang' => '".$self->lang."',"
								."'pref' => '".$self->pref."'"
								."};";
						}
					);
					if ($self->conceptid) {
						$code .= $fixer->emit_create_path(
							$worktype_root,
							['conceptID', '$append'],
							sub {
								my $concept_id_pos = shift;
								return "${concept_id_pos} = {"
								."'_' => ${conceptID},"
								."'pref' => '".$self->pref."',"
								."'source' => '".$self->source."'"
								."};";
							}
					);
					}
					return $code;
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

Catmandu::Fix::lido_worktype - Create a Lido objectWorkType

=head1 SYNOPSIS

lido_worktype(workType, conceptid: conceptID, lang: en, pref: preferred, source: AAT)