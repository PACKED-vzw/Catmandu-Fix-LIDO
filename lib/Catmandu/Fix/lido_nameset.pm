package Catmandu::Fix::lido_nameset;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);

use strict;

with 'Catmandu::Fix::Base';

has value  => ( fix_arg => 1 );
has source => ( fix_opt => 1 );
has lang   => ( fix_opt => 1, default => sub { 'en' } );
has pref   => ( fix_opt => 1, default => sub { 'preferred' } );

sub emit {
    my ( $self, $fixer ) = @_;

    my $perl = '';
    my $h = $fixer->generate_var();
    $perl .= "my ${h} = {};";

    ##
    # appellationValue
    my $value_path = $fixer->split_path( $self->value );
    my $value_key = pop @$value_path;
    my $appellationValue = $fixer->generate_var();
    $perl .= "my ${appellationValue};";
    $perl .= walk($fixer, $value_path, $value_key, $appellationValue);

    ##
    # Create the appellationValue path in a way Lido::XML understands
    $perl .= $fixer->emit_create_path(
        $fixer->var, # At the root level, use a bind or a replace if you want to move this
        ['appellationValue', '$append'],
        sub {
            my $appellation_root = shift;
            return "${appellation_root} = {"
            ."'_' => ${appellationValue},"
            ."'lang' => '".$self->lang."',"
            ."'pref' => '".$self->pref."',"
            ."};";
        }
    );

    ##
    # The sourceAppellation is optional
    if ( $self->source ) {
        my $source_path = $fixer->split_path( $self->source );
        my $source_key = pop@$source_path;
        my $sourceAppellation = $fixer->generate_var();
        $perl .= "my ${sourceAppellation};";
        $perl .= walk($fixer, $source_path, $source_key, $sourceAppellation);
        $perl .= $fixer->emit_create_path(
            $fixer->var, # At the root level, use a bind or a replace if you want to move this
            ['sourceAppellation', '$append'],
            sub {
                my $appellation_root = shift;
                return "${appellation_root} = {"
                ."'_' => ${sourceAppellation},"
                ."'lang' => '".$self->lang."',"
                ."};";
            }
        );
    }

    return $perl;
}

1;

__END__