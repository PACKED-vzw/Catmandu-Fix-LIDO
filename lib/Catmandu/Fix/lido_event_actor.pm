package Catmandu::Fix::lido_event_actor;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk mk_append mk_wrap);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        ['eventActor'],
        sub {
            my $actor_root = shift;
            my $actor_code = '';

            # displayActorInRole
            $actor_code .= mk_append($fixer, $actor_root, ['displayActorInRole']);
            # actorInRole
            $actor_code .= $fixer->emit_create_path(
                $actor_root,
                ['actorInRole', '$append'],
                sub {
                    my $r_root = shift;
                    my $r_code = '';

                    # actor
                    $r_code .= $fixer->emit_create_path(
                        $r_root,
                        ['actor'],
                        sub {
                            my $air_root = shift;
                            my $air_code = '';
                            # actorID
                            $air_code .= mk_append($fixer, $air_root, ['actorID']);
                            # nameActorSet
                            $air_code .= mk_append($fixer, $air_root, ['nameActorSet']);
                            # nationalityActor
                            $air_code .= mk_append($fixer, $air_root, ['nationalityActor']);
                            # vitalDatesActor
                            #$air_code .= mk_append($fixer, $air_root, ['vitalDatesActor']);
                            $air_code .= $fixer->emit_create_path(
                                $air_root,
                                ['vitalDatesActor'],
                                sub {
                                    my $vda_root = shift;
                                    my $vda_code = '';
                                    $vda_code .= mk_append($fixer, $vda_root, ['earliestDate']);
                                    $vda_code .= mk_append($fixer, $vda_root, ['latestDate']);
                                    return $vda_code;
                                }
                            );
                            # genderActor
                            $air_code .= mk_append($fixer, $air_root, ['genderActor']);

                            return $air_code;
                        }
                    );
                    # roleActor
                    $r_code .= mk_append($fixer, $r_root, ['roleActor']);
                    # attributionQualifierActor
                    $r_code .= mk_append($fixer, $r_root, ['attributionQualifierActor']);
                    # extentActor
                    $r_code .= mk_append($fixer, $r_root, ['extentActor']);

                    return $r_code;
                }
            );
            
            return $actor_code;
        }
    );


    return $perl;
}

1;