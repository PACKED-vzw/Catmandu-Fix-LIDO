package Catmandu::Fix::lido_basevalue;

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use Catmandu::Fix::LIDO::Utility qw(walk);
use Catmandu::Fix::LIDO::Value qw(mk_value);

use strict;

#https://librecatproject.wordpress.com/2014/03/26/create-a-fixer-part-2/

use Data::Dumper qw(Dumper);

with 'Catmandu::Fix::Base';

has path => (fix_arg => 1);
has value => (fix_arg => 1);
has pref => (fix_opt => 1);
has lang => (fix_opt => 1);
has label => (fix_opt => 1);
has type => (fix_opt => 1);

sub emit {
    my ($self, $fixer) = @_;

    my $perl = '';

#$fixer, $root, $path, $value, $lang, $pref, $label, $type
    $perl .= mk_value($fixer, $fixer->var, $self->path, $self->value, $self->lang, $self->pref, $self->label, $self->type);

    return $perl;
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::lido_basevalue - Create a basic XML node in a C<path>

=head1 SYNOPSIS

    lido_basevalue(
        path,
        value,
        pref: node.pref,
        lang: node.lang,
        label: node.label,
        type: node.type
    )

=head1 DESCRIPTION

Creates a basic XML node in a specified C<path>. This fix can be used in places where a simple node is expected, but where the parent can have multiple nodes of this type. It can't be used for non-repeatable items.

=head2 Parameters

=head3 Required parameters

C<path> and C<value> are required paths.

=over

=item C<path>

=item C<value>

=back

=head3 Optional parameters

All optional parameters are strings.

=over

=item C<pref>

=item C<lang>

=item C<label>

=item C<type>

=back

=head1 EXAMPLE

=head2 Fix

    lido_basevalue(
        descriptiveMetadata.objectRelationWrap.subjectWrap.subjectSet.displaySubject,
        recordList.record.object_name
    )

=head2 Result

    <lido:descriptiveMetadata>
        <lido:objectRelationWrap>
            <lido:subjectWrap>
                <lido:subjectSet>
                    <lido:displaySubject>olieverfschilderij</lido:displaySubject>
                </lido:subjectSet>
            </lido:subjectWrap>
        </lido:objectRelationWrap>
    </lido:descriptiveMetadata>
