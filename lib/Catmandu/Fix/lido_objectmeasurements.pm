package Catmandu::Fix::lido_objectmeasurements;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has extent => (fix_arg => 1); # should this be a path?
has type => (fix_arg => 1);
has unit => (fix_arg => 1);
has value => (fix_arg => 1); # path

sub emit {
    my ($self, $fixer) = @_;
    my $perl = '';

    my $path = ['objectIdentificationWrap', 'objectMeasurementsWrap', '$append', 'objectMeasurementsSet', 'objectMeasurements'];

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $root = shift;
            my $r_code = '';
            ##
            # extent
            $r_code .= $fixer->emit_create_path (
                $root,
                ['extentMeasurements', '$append', '_'],
                sub {
                    my $e_root = shift;
                    return "${e_root} = '".$self->extent."';";
                }
            );
            
            ##
            # type, unit, value
            $r_code .= $fixer->emit_create_path (
                $root,
                ['measurementsSet', '$append'],
                sub {
                    my $m_root = shift;
                    my $m_code = '';

                    ##
                    # type
                    $m_code .= $fixer->emit_create_path(
                        $m_root,
                        ['measurementType', '$append', '_'],
                        sub {
                            my $t_root = shift;
                            return "${t_root} = '".$self->type."'";
                        }
                    );

                    ##
                    # unit
                    $m_code .= $fixer->emit_create_path(
                        $m_root,
                        ['measurementUnit', '$append', '_'],
                        sub {
                            my $t_root = shift;
                            return "${t_root} = '".$self->unit."'";
                        }
                    );

                    ##
                    # value
                    my $f_val = $fixer->generate_var();
                    $m_code .= "my ${f_val};";
                    $m_code .= declare_source($fixer, $self->value, $f_val);
                    $m_code .= $fixer->emit_create_path(
                        $m_root,
                        ['measurementValue', '$append', '_'],
                        sub {
                            my $t_root = shift;
                            return "${t_root} = ${f_val}";
                        }
                    );

                    return $m_code;
                }
            );

            return $r_code;
        }
    );

    return $perl;
}

1;