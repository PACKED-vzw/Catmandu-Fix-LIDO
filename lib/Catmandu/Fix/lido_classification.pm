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
has lang                    => (fix_opt => 1, default => sub {'en'});

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

    # classification
    $perl .= mk_term($fixer, 'objectClassificationWrap.classificationWrap.$append.classification',
    $self->classification, $self->classification_id, $self->lang, 'preferred', $self->classification_source,
    $self->classification_type);

    # objectWorkType
    $perl .= mk_term($fixer, 'objectClassificationWrap.objectWorkTypeWrap.$append.objectWorkType',
    $self->object_work_type, $self->object_work_type_id, $self->lang, undef, $self->object_work_type_source,
    $self->object_work_type_type);

    return $perl;
}

1;