package Catmandu::Fix::lido_event;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

has type         => ( fix_arg => 1 );
has lang         => ( fix_opt => 1, default => sub { 'en' } );
has id           => ( fix_opt => 1 );
has name         => ( fix_opt => 1 );
has actor_name   => ( fix_opt => 1 );
has actor_role   => ( fix_opt => 1 );
has actor_id     => ( fix_opt => 1 );
has date_display => ( fix_opt => 1 );
has date_iso     => ( fix_opt => 1 );

# This builds the structure LIDO::XML needs to convert it to valid XML

sub emit {
	my ( $self, $fixer ) = @_;

	my $optional_as_path   = [qw(id name actor_name actor_id date_display)];
	my $optional_as_string = [qw(actor_role date_iso)];

	my $new_path = ['event'];

	#[qw(descriptiveMetadata eventWrap eventSet $append event)];

	my $h = $fixer->generate_var();

	my $optional_paths = {};

	my $perl = '';
	$perl .= "my ${h} = {};";

	foreach my $optional_key (@$optional_as_path) {
		if ( $self->{$optional_key} ) {
			my $path = $fixer->split_path( $self->{$optional_key} );
			my $key  = pop @$path;
			$optional_paths->{$optional_key} = {
				'path' => $path,
				'key'  => $key,
				'var'  => $fixer->generate_var()
			};

			# Register in the fixer code
			$perl .= "my " . $optional_paths->{$optional_key}->{'var'} . ";";

			# Set the fixer variable to the value of the path
			# this code must be added to the fixer code
			$perl .= walk(
				$fixer,
				$optional_paths->{$optional_key}->{'path'},
				$optional_paths->{$optional_key}->{'key'},
				$optional_paths->{$optional_key}->{'var'}
			);
		}
	}

	# Path
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $event_root = shift;
			my $event_code = '';

			# Actor
			if ( $self->actor_name || $self->actor_id ) {
				$event_code .= $fixer->emit_create_path(
					$event_root,

# The problem is that now we have used $append, all children of 'event' ($event_root) must be array elements.
# We can't have a hash now
# Check what happens when we convert to XML
					[ 'eventActor', '$append', 'actorInRole' ],
					sub {
						my $actor_root = shift;
						my $actor_code = '';
						if ( $self->actor_name ) {
							$actor_code .= $fixer->emit_create_path(
								$actor_root,
								[
									'actor',            'nameActorSet',
									'appellationValue', '$append',
									'_'
								],
								sub {
									my $actor_name_pos = shift;
									return
									    "${actor_name_pos} = "
									  . $optional_paths->{'actor_name'}->{'var'}
									  . ";";
								}
							);
						}
						if ( $self->actor_id ) {
							$actor_code .= $fixer->emit_create_path(
								$actor_root,
								[ 'actor', 'actorID', '$append', '_' ],
								sub {
									my $actor_id_pos = shift;
									return
									    "${actor_id_pos} = "
									  . $optional_paths->{'actor_id'}->{'var'}
									  . ";";
								}
							);
						}
						if ( $self->actor_role ) {
							$actor_code .= $fixer->emit_create_path(
								$actor_root,
								[ 'roleActor', 'term', '$append', '_' ],
								sub {
									my $actor_role_pos = shift;
									return
									  "${actor_role_pos} = '"
									  . $self->actor_role . "';";
								}
							);
						}
						return $actor_code;
					}
				);
			}

			# Date
			if ( $self->date_display || $self->date_iso ) {
				$event_code .= $fixer->emit_create_path(
					$event_root,
					['eventDate'],
					sub {
						my $date_root = shift;
						my $date_code = '';
						if ( $self->date_display ) {
							$date_code .= $fixer->emit_create_path(
								$date_root,
								[ 'displayDate', '$append', '_' ],
								sub {
									my $display_date_pos = shift;
									return "${display_date_pos} = "
									  . $optional_paths->{'date_display'}
									  ->{'var'} . ";";
								}
							);
						}
						if ( $self->date_iso ) {
							$date_code .= $fixer->emit_create_path(
								$date_root,
								['date'],
								sub {
									my $iso_date_pos = shift;
									return
									    "${iso_date_pos} = {"
									  . "'earliestDate' => {'_' => '"
									  . $self->date_iso . "'},"
									  . "'latestDate' => {'_' => '"
									  . $self->date_iso . "'}" . "};";
								}
							);
						}
						return $date_code;
					}
				);
			}
			# ID
			if ( $self->id ) {
				$event_code .= $fixer->emit_create_path(
					$event_root,
					[ 'eventID', '$append', '_' ],
					sub {
						my $event_id_pos = shift;
						return
						  "${event_id_pos} = "
						  . $optional_paths->{'id'}->{'var'} . ";";
					}
				);
			}

			# Name
			if ( $self->name ) {
				$event_code .= $fixer->emit_create_path(
					$event_root,
					[ 'eventName', 'appellationValue', '$append', '_' ],
					sub {
						my $event_name_pos = shift;
						return
						  "${event_name_pos} = "
						  . $optional_paths->{'name'}->{'var'} . ";";
					}
				);
			}

			#Type
			$event_code .= $fixer->emit_create_path(
				$event_root,
				[ 'eventType', 'term', '$append', '_' ],
				sub {
					my $event_type_pos = shift;
					return "${event_type_pos} = '" . $self->type . "';";
				}
			);

			return $event_code;
		}
	);

	return $perl;
}

1;

__END__

=pod

=head1 NAME
Catmandu::Fix::lido_event - LIDO Events

=head1 SYNOPSIS
do lido_event_bind()
	lido_event(
	    type,
	    lang: en,
	    id: eventID,
	    name: eventName,
	    actor_name: nameActorSet.appellationValue,
	    actor_role: roleActor.term,
	    actor_id: actorID,
	    date_display: displayDate,
	    date_iso: date.earliestDate
	)
end

=head1 Description
Creates a (minimal) LIDO event in the 'event' path. To get the event in the correct path, you have to use lido_event_bind().

