package Catmandu::Fix::lido_event;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk path_and_key);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/


with 'Catmandu::Fix::Base';

has type => (fix_arg => 1);
has id => (fix_opt => 1);
has name => (fix_opt => 1);
has actor_name => (fix_opt => 1);
has actor_role => (fix_opt => 1);
has actor_id => (fix_opt => 1);
has date_display => (fix_opt => 1);
has date_iso => (fix_opt => 1);

sub emit {
	my ($self, $fixer) = @_;
	
	my $optional_as_path = [qw(id name actor_name actor_id date_display)];
	my $optional_as_string = [qw(actor_role date_iso)];
	
	my $new_path = [qw(lido descriptiveMetadata eventWrap $append eventSet)];
	
	my $h = $fixer->generate_var();
	
	my $perl = '';
	$perl .= "my ${h} = {};";
	
	my $optional_generated = {};
	my $optional_path = {};
	my $optional_key = {};
	
	foreach my $var (@$optional_as_path) {
		if ($self->{$var}) {
			print $var;
			($optional_path->{$var}, $optional_key->{$var}) = path_and_key($fixer, $self->{$var});
			$optional_generated->{$var} = $fixer->generate_var();
			my $fix_var = $optional_generated->{$var};
			$perl .= "my ${fix_var};";
			$perl .= walk($fixer, $optional_path->{$var}, $optional_key->{$var}, $optional_generated->{$var});
		}
	}
	
	$perl .= $fixer->emit_create_path(
		$fixer->var,
		$new_path,
		sub {
			my $path_var = shift;
			my $p_code = '';
			$p_code .= $fixer->emit_create_path(
				$path_var,
				['event'],
				sub {
					my $event_var = shift;
					my $code = '';
					my $val;
					$code .= "${h} = {";
					#[qw(id name actor_name actor_role actor_id date_display date_iso)]
					if ($self->id) {
						$val = $optional_generated->{'id'};
						$code .= "'eventID' => ${val},";
					}
					if ($self->name) {
						$val = $optional_generated->{'name'};
						$code .= "'eventName' => {".
						"'appellationValue' => ${val}"
						."};";
					}
					# This comes last, so we can add the ',' to every item in the above list
					# type is mandatory
					$val = $self->type;
					$code .= "'eventType' => {"
						."'term' => '${val}'"
						."}";
					$code .= "};";
					$code .= "${event_var} = ${h};";
					# Creating paths must come last, as otherwise it will output
					# the code in the middle of a hash ($h). This will fail.
					
                                        # eventDate.displayDate
                                        # eventDate.date.earliestDate|.latestDate
                                        if ($self->date_display || $self->date_iso) {
                                            my $date_path = [qw(eventDate)];
                                            $code .= $fixer->emit_create_path(
                                                $path_var,
                                                $date_path,
                                                sub {
                                                    my $date_var = shift;
                                                    my $date_code = '';
                                                    if ($self->date_display) {
                                                        $date_code .= $fixer->emit_create_path(
                                                            $date_var,
                                                            [qw(displayDate)],
                                                            sub {
                                                                my $display_date_var = shift;
                                                                $val = $optional_generated->{'date_display'};
                                                                "${display_date_var} = ${val};";
                                                            }
                                                        );
                                                    }
                                                    if ($self->date_iso) {
                                                        $date_code .= $fixer->emit_create_path(
                                                            $date_var,
                                                            [qw(date)],
                                                            sub {
                                                                my $date_iso_var = shift;
                                                                $val = $self->date_iso;
                                                                "${date_iso_var} = {"
                                                                ."'earliestDate' => '${val}',"
                                                                ."'latestDate' => '${val}'"
                                                                ."};";
                                                            }
                                                        );
                                                    }
                                                    $date_code;
                                                }
                                            );
                                        }

					# TODO: fix problem when $append does not work between event and eventActor
					if ($self->actor_name) {
						my $actor_path = [qw(event eventActor actorInRole)];
						$val = $optional_generated->{'actor_name'};
						$code .= $fixer->emit_create_path(
							$path_var,
							$actor_path,
							sub {
								my $actor_var = shift;
								my $actor_code = '';
								$actor_code .= $fixer->emit_create_path(
									$actor_var,
									[qw(actor nameActorSet appellationValue)],
									sub {
										my $name_actor_var = shift;
										"${name_actor_var} = ${val};";
									}
								);
								if ($self->actor_role) {
									$actor_code .= $fixer->emit_create_path(
										$actor_var,
										[qw(roleActor term)],
										sub {
											my $role_actor_var = shift;
											my $val = $self->actor_role;
											"${role_actor_var} = '$val';";
										}
									);
								}
                                                                if ($self->actor_id) {
                                                                    my $val = $optional_generated->{'actor_id'};
                                                                    $actor_code .= $fixer->emit_create_path(
                                                                        $actor_var,
                                                                        [qw(actor actorID)],
                                                                        sub {
                                                                            my $actor_id_var = shift;
                                                                            "${actor_id_var} = ${val};";
                                                                        }
                                                                    );
                                                                }
								$actor_code;
							}
						);
					}
					$code;
				}
			);
			$p_code;
		}
	);
	
	$perl;
	
}

1;
