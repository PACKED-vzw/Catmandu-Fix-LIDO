package Catmandu::Fix::lido_term;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Data::Dumper qw(Dumper);

use strict;

with 'Catmandu::Fix::Base';

has term      => ( fix_arg => 1 );
has conceptid => ( fix_opt => 1 );
has lang      => ( fix_opt => 1, default => sub { 'en' } );
has pref      => ( fix_opt => 1, default => sub { 'preferred' } );
has source    => ( fix_opt => 1, default => sub { 'AAT' } );

sub emit {
    my ( $self, $fixer ) = @_;

 #   print Dumper $fixer;

    my $perl = '';
    my $h = $fixer->generate_var();
    $perl .= "my ${h} = {};";

    ##
    # term
    my $term = $fixer->generate_var();
    $perl .= "my ${term};";
    $perl .= declare_source($fixer, $self->term, $term);

    ##
    # Create the term for Lido::XML
    $perl .= $fixer->emit_create_path(
        $fixer->var, # At the root level, use a bind or a move_field if you want it someplace else
        ['term', '$append'],
        sub {
            my $term_root = shift;
            return "${term_root} = {"
            ."'_' => ${term},"
            ."'lang' => '". $self->lang."',"
            ."'pref' => '".$self->pref."'"
            ."}";
        }
    );

    ##
    # conceptID
    if ( $self->conceptid ) {
        my $conceptid = $fixer->generate_var();
        $perl .= "my ${conceptid};";
        $perl .= declare_source($fixer, $self->conceptid, $conceptid);
        ##
        # Create the conceptID for Lido::XML
        $perl .= $fixer->emit_create_path(
            $fixer->var, # At the root level, use a bind or a move_field if you want it someplace else
            ['conceptID', '$append'],
            sub {
                my $concept_root = shift;
                return "${concept_root} = {"
                ."'_' => ${conceptid},"
                ."'pref' => '".$self->pref."'"
                ."}";
            }
        );
    }

    return $perl;
}

1;

__END__