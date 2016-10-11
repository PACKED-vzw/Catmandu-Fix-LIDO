package Catmandu::Fix::lido_actor;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Term qw(mk_term);
use Catmandu::Fix::LIDO::ID qw(mk_id);
use Catmandu::Fix::LIDO::Nameset qw(mk_nameset);
use Catmandu::Fix::LIDO::Value qw(mk_value);
use Data::Dumper qw(Dumper);

use strict;

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has id => (fix_arg => 1);
has name => (fix_arg => 1);
has id_label => (fix_opt => 1);
has id_source => (fix_opt => 1);
has nationality => (fix_opt => 1); # Path
has birthdate => (fix_opt => 1);
has deathdate => (fix_opt => 1);
has role => (fix_opt => 1);
has role_id => (fix_opt => 1);
has role_id_type => (fix_opt => 1);
has role_id_source => (fix_opt => 1);
has qualifier => (fix_opt => 1);

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

            ##
            # actorID
            # $fixer, $root, $path, $id, $source, $label, $type
            if (defined($self->id)) {
                $r_code .= mk_id($fixer, $r_root, 'actorInRole.actor.actorID', $self->id, $self->id_source, $self->id_label, undef);
            }

            ##
            # nameActorSet
            # $fixer, $root, $path, $appellation_value, $appellation_value_lang, $appellation_value_type,
            # $appellation_value_pref, $source_appellation, $source_appellation_lang
            if (defined($self->name)) {
                $r_code .= mk_nameset($fixer, $r_root, 'actorInRole.actor.nameActorSet', $self->name);
            }

            ##
            # nationalityActor
            # $fixer, $root, $path, $term, $conceptid, $lang, $pref, $source, $type
            if (defined($self->nationality)) {
                $r_code .= mk_term($fixer, $r_root, 'actorInRole.actor.nationalityActor', $self->nationality);
            }

            ##
            # vitalDatesActor
            $r_code .= $fixer->emit_create_path(
                $r_root,
                ['actorInRole', 'actor', '$append', 'vitalDatesActor'],
                sub {
                    my $d_root = shift;
                    my $d_code = '';

                    ##
                    # earliestDate
                    if (defined($self->birthdate)) {
                        $d_code .= mk_value($fixer, $d_root, 'earliestDate', $self->birthdate);
                    }

                    ##
                    # latestDate
                    if (defined($self->deathdate)) {
                        $d_code .= mk_value($fixer, $d_root, 'latestDate', $self->deathdate);
                    }

                    return $d_code;
                }
            );

            ##
            # roleActor
            if (defined($self->role)) 
                {$r_code .= mk_term($fixer, $r_root, 'actorInRole.actor.roleActor', $self->role, $self->role_id, undef, undef, $self->role_id_source, $self->role_id_type);
            }
            
            ##
            # attributionQualifierActor
            # $fixer, $root, $path, $value, $lang, $pref, $label, $type
            if (defined($self->qualifier)) {
                $r_code .= mk_value($fixer, $r_root, 'actorInRole.actor.attributionQualifierActor', $self->qualifier);
            }
            
            return $r_code;
        }
    );

    return $perl;
}

1;