package Catmandu::Fix::lido_descriptivenote;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Catmandu::Fix::LIDO::DescriptiveNote qw(mk_descriptive_note);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has value => (fix_arg => 1);
has lang => (fix_opt => 1);
has label => (fix_opt => 1);

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

    my $new_path = $fixer->split_path($self->path);

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $new_path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            $r_code .= mk_descriptive_note($fixer, $r_root, '', $self->value, $self->lang, $self->label);

            return $r_code;
        }
    );

    return $perl;
}

1;