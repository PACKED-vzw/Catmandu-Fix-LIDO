package Catmandu::Fix::lido_administrativemetadata;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk mk_wrap);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

sub emit {
    my ($self, $fixer) = @_;
    my $path = ['lido', '$append', 'administrativeMetadata'];
    my $perl = '';

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $a_root = shift;
            my $a_code = '';
            # rightsWorkWrap
            $a_code .= mk_wrap($fixer, $a_root, ['rightsWorkWrap', '$append']);
            # recordWrap
            $a_code .= mk_wrap($fixer, $a_root, ['recordWrap', '$append']);
            # resourceWrap
            $a_code .= mk_wrap($fixer, $a_root, ['resourceWrap', '$append']);
            return $a_code;
        }
    );

    return $perl;
}

1;