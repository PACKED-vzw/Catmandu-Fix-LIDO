package Catmandu::Fix::lido_classification;

use Data::Dumper qw(Dumper);

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use Catmandu::Fix::LIDO::Term qw(mk_term);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

with 'Catmandu::Fix::Base';

has object_work_type        => (fix_arg => 1);
has classification          => (fix_arg => 1);
has object_work_type_id     => (fix_opt => 1);
has classification_id       => (fix_opt => 1);
has object_work_type_type   => (fix_opt => 1, default => sub { 'global' });
has object_work_type_source => (fix_opt => 1, default => sub { 'AAT' });
has classification_type     => (fix_opt => 1, default => sub { 'global' });
has classification_source   => (fix_opt => 1, default => sub { 'AAT' });

sub emit {
    my ($self, $fixer) = @_;

    my $path = ['objectClassificationWrap'];
    my $perl = '';

#    my $w_type = $fixer->generate_var();
#    $perl .= "my ${w_type};";
#    $perl .= declare_source($fixer, $self->object_work_type, $w_type);
#
#    my $cl = $fixer->generate_var();
#    $perl .= "my ${cl};";
#    $perl .= declare_source($fixer, $self->classification, $cl);
#
#    my $w_type_id = $fixer->generate_var();
#    $perl .= "my ${w_type_id};";
#    $perl .= declare_source($fixer, $self->object_work_type_id, $w_type_id);
#
#    my $cl_id = $fixer->generate_var();
#    $perl .= "my ${cl_id};";
#    $perl .= declare_source($fixer, $self->classification_id, $cl_id);

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $c_root = shift;

            my $c_code = '';
            #$c_code .= mk_term($fixer, 'objectClassificationWrap.objectWorkTypeWrap.$append.objectWorkType', $self->object_work_type, $self->object_work_type_id, undef, undef, $self->object_work_type_source, $self->object_work_type_type);
            # objectWorkTypeWrap
            #$c_code .= c_lido_term($fixer->var, 'objectClassificationWrap.objectWorkTypeWrap.$last.objectWorkType'
            #, $self->object_work_type);
            #$c_code .= $fixer->emit_create_path(
            #    $c_root,
            #    ['objectWorkTypeWrap', '$append', 'objectWorkType'],
            #    sub {
            #        my $ow_root = shift;
            #        #objectClassificationWrap.objectWorkTypeWrap.$last.objectWorkType
            #    }
            #);
            # classificationWrap
            $c_code .= $fixer->emit_create_path(
                $c_root,
                ['classificationWrap', '$append', 'classification'],
                sub {
                    my $cl_root = shift;
                    #objectClassificationWrap.classificationWrap.$last.classification
                    return '';
                }
            );
            return $c_code;
        }
    );
    
    $perl .= mk_term($fixer, 'objectClassificationWrap.objectWorkTypeWrap.$append.objectWorkType', $self->object_work_type, $self->object_work_type_id, undef, undef, $self->object_work_type_source, $self->object_work_type_type);

    return $perl;
}

1;