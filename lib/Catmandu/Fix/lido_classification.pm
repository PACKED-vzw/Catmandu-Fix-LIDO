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

    my $path = ['descriptiveMetadata', 'objectClassificationWrap'];
    my $perl = '';

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $r_root = shift;
            my $r_code = '';

            ##
            # classification
            if (defined($self->classification)) {
                $r_code .= mk_term($fixer, $r_root, 'classificationWrap.classification',
                            $self->classification, $self->classification_id, $self->lang, 'preferred', $self->classification_source,
                            $self->classification_type);
            }

            ##
            # objectWorkType
            if (defined($self->object_work_type)) {
                $r_code .= mk_term($fixer, $r_root, 'objectWorkTypeWrap.objectWorkType',
                            $self->object_work_type, $self->object_work_type_id, $self->lang, undef, $self->object_work_type_source,
                            $self->object_work_type_type);
            }

            return $r_code;
        }
    );

    return $perl;
}

1;