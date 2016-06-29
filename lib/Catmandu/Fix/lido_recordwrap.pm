package Catmandu::Fix::lido_recordwrap;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

# recordID, recordType, recordSource

has record_id => (fix_arg => 1);
has record_id_type => (fix_arg => 1);
has record_type => (fix_arg => 1);
has record_source => (fix_arg => 1);
has lang => (fix_opt => 1, default => sub { 'en' });

sub emit {
	my ($self, $fixer) = @_;
	
	my $required_keys = ['record_id', 'record_type', 'record_source'];
	my $paths = {};
	
	my $new_path = ['administrativeMetadata'];
	#recordWrap
	my $h = $fixer->generate_var();
	
	my $perl = '';
	
	foreach my $required_key (@$required_keys) {
		my $path = $fixer->split_path($self->{$required_key});
		my $key = pop @$path;
		$paths->{$required_key} = {
			'path' => $path,
			'key' => $key,
			'var' => $fixer->generate_var()
		};
		# Register in the fixer code
		$perl .= "my ".$paths->{$required_key}->{'var'}.";";
		# Set the fixer variable to the value of the path
		# this code must be added to the fixer code
		$perl .= walk($fixer, $paths->{$required_key}->{'path'}, $paths->{$required_key}->{'key'}, $paths->{$required_key}->{'var'});
	}
	
	# Path
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $administrative_metadata_root = shift;
			my $administrative_metadata_code = '';
			
			$administrative_metadata_code .= $fixer->emit_create_path(
				$administrative_metadata_root,
				['lang'],
				sub {
					my $lang_pos = shift;
					return "${lang_pos} = '".$self->lang."';";
				}
			);
			
			$administrative_metadata_code .= $fixer->emit_create_path(
				$administrative_metadata_root,
				['recordWrap'],
				sub {
					my $record_root = shift;
					my $record_code = '';
					
					# RecordID
					$record_code .= $fixer->emit_create_path(
						$record_root,
						['recordID', '$append'],
						sub {
							my $record_id_pos = shift;
							return "${record_id_pos} = {"
								."'_' => ".$paths->{'record_id'}->{'var'}.","
								."'type' => '".$self->record_id_type."'"
								."};";
						}
					);
					
					# recordType
					$record_code .= $fixer->emit_create_path(
						$record_root,
						['recordType', 'term', '$append', '_'],
						sub {
							my $record_type_pos = shift;
							return "${record_type_pos} = ".$paths->{'record_type'}->{'var'}.";";
						}
					);
					
					# recordSource
					$record_code .= $fixer->emit_create_path(
						$record_root,
						['recordSource', 'legalBodyName', 'appellationValue', '$append', '_'],
						sub {
							my $record_source_pos = shift;
							return "${record_source_pos} = ".$paths->{'record_source'}->{'var'}.";";
						}
					);
					
					return $record_code;
				}
			);
			
			return $administrative_metadata_code;
		}
	);
	
	return $perl;
}

1;

__END__

=pod

=head1 NAME
Catmandu::Fix::lido_recordwrap - LIDO RecordWrap

=head1 SYNOPSIS
lido_recordwrap(
    recordID,
    recordID_type,
    recordType,
    recordSource,
    lang: en
)