package Catmandu::Fix::lido_event_place;

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
        ['eventPlace'],
        sub {
            my $ep_root = shift;
            my $ep_code = '';

            # displayPlace
            $ep_code .= mk_append($fixer, $ep_root, ['displayPlace']);
            # place
            $ep_code .= $fixer->emit_create_path(
                $ep_root,
                ['place'],
                sub {
                    my $p_root = shift;
                    my $p_code = '';

                    # placeID
                    $p_code .= mk_append($fixer, $p_root, ['placeID']);
                    # namePlaceSet
                    # gml
                    # partOfPLace
                    # placeClassification

                    return $p_code;
                }
            );

            return $ep_code;
        }
    );

    return $perl;
}

1;