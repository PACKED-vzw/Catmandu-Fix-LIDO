package Catmandu::Fix::lido_descriptivenote;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has value => (fix_arg => 1);
has value_lang => (fix_opt => 1, default => sub { 'en' });
has value_label => (fix_opt => 1, default => sub { 'description' });

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

    my $h = $fixer->generate_var();
    my $new_path = $fixer->split_path($self->path);

    my $f_value = $fixer->generate_var();
    $perl .= "my ${f_value};";
    $perl .= declare_source($fixer, $self->value, $f_value);

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $new_path,
        sub {
            my $root = shift;
            my $r_code = '';

            $r_code .= $fixer->emit_create_path(
                $root,
                ['$append', 'descriptiveNoteValue', '$append'],
                sub {
                    my $dn_root = shift;
                    return "${dn_root} = {"
                    ."'_' => ${f_value},"
                    ."'lang' => '".$self->value_lang."',"
                    ."'label' => '".$self->value_label."'"
                    ."};";
                }
            );

            return $r_code;
        }
    );

    return $perl;
}

1;