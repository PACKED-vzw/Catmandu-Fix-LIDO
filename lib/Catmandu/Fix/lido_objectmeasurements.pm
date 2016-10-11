package Catmandu::Fix::lido_objectmeasurements;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk declare_source);
use Catmandu::Fix::LIDO::Value qw(mk_value);

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

    my $path = ['descriptiveMetadata', 'objectIdentificationWrap', 'objectMeasurementsWrap', 'objectMeasurementsSet', 'objectMeasurements'];

    $perl .= $fixer->emit_create_path(
        $fixer->var,
        $path,
        sub {
            my $r_root = shift;
            my $r_code = '';
            ##
            # extent
            if (defined($self->extent)) {
                $r_code .= mk_value($fixer, $r_root, 'extentMeasurements', $self->extent, undef, undef, undef, undef, 1);
            }
            
            ##
            # type, unit, value
            $r_code .= $fixer->emit_create_path (
                $r_root,
                ['measurementsSet'],
                sub {
                    my $m_root = shift;
                    my $m_code = '';

                    ##
                    # type
                    if (defined($self->type)) {
                        #$fixer, $root, $path, $value, $lang, $pref, $label, $type, $is_string
                        $m_code .= mk_value($fixer, $m_root, 'measurementType', $self->type, undef, undef, undef, undef, 1);
                    }

                    ##
                    # unit
                    if (defined($self->unit)) {
                        $m_code .= mk_value($fixer, $m_root, 'measurementUnit', $self->unit, undef, undef, undef, undef, 1);
                    }

                    ##
                    # value
                    if (defined($self->value)) {
                        $m_code .= $fixer->emit_create_path(
                            $m_root,
                            ['measurementValue'],
                            sub {
                                my $v_root = shift;
                                my $v_code = '';

                                my $m_value = $fixer->generate_var();
                                $v_code .= "my ${m_value};";
                                $v_code .= declare_source($fixer, $self->value, $m_value);

                                $v_code .= "${v_root} = ${m_value};";
                                return $v_code;
                            }
                        );
                    }

                    return $m_code;
                }
            );

            return $r_code;
        }
    );

    return $perl;
}

1;