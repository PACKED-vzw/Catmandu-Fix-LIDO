package Catmandu::Fix::lido_event_set;

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
        ['eventSet'],
        sub {
            my $set_root = shift;
            my $set_code = '';
            #displayEvent
            $set_code .= mk_append($fixer, $set_root, ['displayEvent']);
            #event
            $set_code .= $fixer->emit_create_path(
                $set_root,
                ['event'],
                sub {
                    my $event_root = shift;
                    my $event_code = '';
                    # eventID
                    $event_code .= mk_append($fixer, $event_root, ['eventID']);
                    # eventType
                    $event_code .= mk_wrap($fixer, $event_root, ['eventType']);
                    # roleInEvent
                    $event_code .= mk_append($fixer, $event_root, ['roleInEvent']);
                    # eventName
                    $event_code .= mk_append($fixer, $event_root, ['eventName']);
                    # eventActor
                    $event_code .= mk_append($fixer, $event_root, ['eventActor']);
                    # culture
                    $event_code .= mk_append($fixer, $event_root, ['culture']);
                    # eventDate
                    $event_code .= mk_wrap($fixer, $event_root, ['eventDate']);
                    # periodName
                    $event_code .= mk_append($fixer, $event_root, ['periodName']);
                    # eventPlace
                    $event_code .= mk_append($fixer, $event_root, ['eventPlace']);
                    # eventMethod
                    $event_code .= mk_append($fixer, $event_root, ['eventMethod']);
                    # eventMaterialsTech
                    $event_code .= mk_append($fixer, $event_root, ['eventMaterialsTech']);
                    # thingPresent
                    $event_code .= mk_append($fixer, $event_root, ['thingPresent']);
                    # relatedEventSet
                    $event_code .= mk_append($fixer, $event_root, ['relatedEventSet']);
                    # eventDescriptionSet
                    $event_code .= mk_append($fixer, $event_root, ['eventDescriptionSet']);
                    return $event_code;
                }
            );
            return $set_code;
        }
    );

    return $perl;
}

1;