package Catmandu::Fix::lido_descriptionmetadata;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk mk_wrap);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

sub emit {
    my ($self, $fixer) = @_;
    my $path = ['lido', '$append', 'descriptiveMetadata'];
    my $perl = '';

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $d_root = shift;
            # We have to go level + 1, assigning empty arrays doesn't work
            my $d_code = '';
            # objectClassificationWrap
            $d_code .= $fixer->emit_create_path(
                $d_root,
                ['objectClassificationWrap'],
                sub {
                    my $oc_root = shift;
                    my $oc_code = '';
                    $oc_code .= mk_wrap($fixer, $oc_root, ['objectWorkTypeWrap', '$append']);
                    $oc_code .= mk_wrap($fixer, $oc_root, ['classificationWrap', '$append']);
                    return $oc_code;
                }
            );
            # objectIdentificationWrap
            $d_code .= $fixer->emit_create_path(
                $d_root,
                ['objectIdentificationWrap'],
                sub {
                    my $oi_root = shift;
                    my $oi_code = '';
                    $oi_code .= mk_wrap($fixer, $oi_root, ['titleWrap', '$append']);
                    $oi_code .= mk_wrap($fixer, $oi_root, ['inscriptionsWrap', '$append']);
                    $oi_code .= mk_wrap($fixer, $oi_root, ['repositoryWrap', '$append']);
                    $oi_code .= mk_wrap($fixer, $oi_root, ['displayStateEditionWrap', '$append']);
                    $oi_code .= mk_wrap($fixer, $oi_root, ['objectDescriptionWrap', '$append']);
                    $oi_code .= mk_wrap($fixer, $oi_root, ['objectMeasurementsWrap', '$append']);
                    return $oi_code;
                }
            );
            # eventWrap
            $d_code .= mk_wrap($fixer, $d_root, ['eventWrap', '$append']);
            # objectRelationWrap
            $d_code .= $fixer->emit_create_path(
                $d_root,
                ['objectRelationWrap'],
                sub {
                    my $or_root = shift;
                    my $or_code = '';
                    $or_code .= mk_wrap($fixer, $or_root, ['subjectWrap', '$append']);
                    $or_code .= mk_wrap($fixer, $or_root, ['relatedWorksWrap', '$append']);
                    return $or_code;
                }
            );
            return $d_code;
        }
    );

    return $perl;
}

1;