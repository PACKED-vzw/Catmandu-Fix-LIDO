package Catmandu::Fix::lido_inscription;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Catmandu::Fix::LIDO::DescriptiveNote qw(mk_descriptive_note);
use Catmandu::Fix::LIDO::Value qw(mk_value);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has transcription => (fix_opt => 1);
has descriptive_note => (fix_opt => 1);
has type => (fix_opt => 1);
has label => (fix_opt => 1, default => sub { 'transcription' });
has lang => (fix_opt => 1, default => sub { 'en' });

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        ['objectIdentificationWrap', 'inscriptionsWrap', '$append', 'inscriptions'],
        sub {
            my $r_root = shift;
            my $r_code = '';

            ##
            # inscriptionTranscription
            $r_code .= mk_value($fixer, $r_root, '$append.inscriptionTranscription', $self->transcription, $self->lang, undef, $self->label, $self->type);

            ##
            # inscriptionDescription.descriptiveNoteValue
            $r_code .= mk_descriptive_note($fixer, $r_root, '$append.inscriptionDescription', $self->descriptive_note, $self->lang, $self->label);

            return $r_code;
        }
    );

    return $perl;
}

1;