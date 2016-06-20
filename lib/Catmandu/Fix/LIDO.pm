package Catmandu::Fix::LIDO;

use strict;

# Stolen from Catmandu::Fix::Date
use parent 'Exporter';
our @EXPORT;
@EXPORT = qw(
    lido_title
    lido_repository
    lido_recid
    lido_worktype
    lido_description
    lido_event
    lido_recordwrap
);

our $VERSION = '0.001';

foreach my $fix (@EXPORT) {
    eval <<EVAL; ## no critic
        require Catmandu::Fix::$fix;
        Catmandu::Fix::$fix ->import( as => '$fix' );
EVAL
    die "Failed to use Catmandu::Fix::$fix\n" if $@;
}

1;

__END__

=pod

=head1 NAME

Catmandu::Fix::LIDO - Implement LIDO fixes

=head1 SYNOPSIS

A set of fixes for the Catmandu project to convert data to the LIDO XML format.

These fixes generate a data structure that can be exported to XML using the Catmandu LIDO exporter.

=head1 MODULES

=over

=item * L<Catmandu::Fix::lido_description>

=item * L<Catmandu::Fix::lido_event>

=item * L<Catmandu::Fix::lido_recid>

=item * L<Catmandu::Fix::lido_recordwrap>

=item * L<Catmandu::Fix::lido_repository>

=item * L<Catmandu::Fix::lido_title>

=item * L<Catmandu::Fix::lido_worktype>

=back

=head1 DESCRIPTION

=begin markdown

A set of [fixes](http://librecat.org/Catmandu/#fixes-cheat-sheet) for the [Catmandu project](http://librecat.org/) to convert data to the [LIDO XML](http://lido-schema.org/) format.

These fixes generate a data structure that can be exported to XML using the [Catmandu LIDO exporter](https://github.com/LibreCat/Catmandu-LIDO).

## Supported LIDO elements

The required elements of the [CIDOC-CRM](https://www.projectcest.be/wiki/Standaard:CIDOC-richtlijnen) standard (minimal requirements) and the minimal requirements to get a valid LIDO XML record are supported. More elements may be added later.

All elements can be repeated.

### Institution name

* _descriptiveMetadata.objectIdentificationWrap.repositoryWrap.repositoryName.legalBodyName.appellationValue_
* _descriptiveMetadata.objectIdentificationWrap.repositoryWrap.workID_

As `lido_repository(legalBodyName, workID, lang: en)` where `legalBodyName` and `workID` are paths and required and `lang` is an optional string (default: `en`).

### Inventory number

* _lidoRecID_

As `lido_recid(lidoRecID, type)` where `lidoRecID` is a required path and `type` a required string..

This element is required.

### Object keyword

* _descriptiveMetadata.objectClassificationWrap.objectWorkTypeWrap.objectWorkType.term_
* _descriptiveMetadata.objectClassificationWrap.objectWorkTypeWrap.objectWorkType.conceptID_

As `lido_worktype(workType, conceptid: conceptID, lang: en)` where `workType` is a required path, `conceptid` an optional path and `lang` an optional string (default: `en`).

### Title

* _descriptiveMetadata.objectIdentificationWrap.titleWrap.titleSet.appellationValue_
* _descriptiveMetadata.objectIdentificationWrap.titleWrap.titleSet.sourceAppellation_

As `lido_title(appellationValue, sourceAppellation, lang: en)` where `appellationValue` and `sourceAppellation` are required paths and `lang` is an optional string (default: `en`).

This element is required.

### Brief description

* _descriptiveMetadata.objectIdentificationWrap.objectDescriptionWrap.objectDescriptionSet.descriptiveNoteValue_

As `lido_description(description, lang: en)` where `description` is a required path and `lang` an optional string( default: `en`).

### Events

The _acquisition method_, _acquired from_ and _acquisition date_ elements from the CIDOC-CRM guidelines are modelled as events.

* _descriptiveMetadata.eventWrap.eventSet.event.eventActor.actorInRole.nameActorSet.appellationValue_
* _descriptiveMetadata.eventWrap.eventSet.event.eventActor.actorInRole.actor.actorID_
* _descriptiveMetadata.eventWrap.eventSet.event.eventActor.actorInRole.roleActor.term_
* _descriptiveMetadata.eventWrap.eventSet.event.eventDate.displayDate_
* _descriptiveMetadata.eventWrap.eventSet.event.eventDate.date.earliestDate_ &  _descriptiveMetadata.eventWrap.eventSet.event.eventDate.date.latestDate_ (from a single source; both elements are equal)
*  _descriptiveMetadata.eventWrap.eventSet.event.eventID_
*  _descriptiveMetadata.eventWrap.eventSet.event.eventName.appellationValue_
*  _descriptiveMetadata.eventWrap.eventSet.event.eventType.term_

As `lido_event()`:
>

```
lido_event(
    type,
    lang: en,
    id: eventID,
    name: eventName,
    actor_name: nameActorSet.appellationValue,
    actor_role: roleActor.term,
    actor_id: actorID,
    date_display: displayDate,
    date_iso: date.earliestDate
)

```

Where `type` is a required path, `id`, `name`, `actor_name`, `actor_id` & `date_display` are optional paths and `lang`, `actor_role` & `date_iso` are optional strings. The default value for `lang` is `en`. Note that `date_iso` is not validated.

`actor_name` or `actor_id` are required when `actor_role` is set.

### Record

This element implements `permanent location` from CIDOC-CRM.

* _administrativeMetadata.recordWrap.recordID_
* _administrativeMetadata.recordWrap.recordType.term_
* _administrativeMetadata.recordWrap.recordSource.legalBodyName.appellationValue_

As `lido_recordwrap()`:
>

```
lido_recordwrap(
    recordID,
    recordID_type,
    recordType,
    recordSource,
    lang: en
)
```

Where `recordID`, `recordType` and `recordSource` are required paths, `recordID_type` is a required string and `lang` is an optional string (default: `en`).

This element is required.

=end markdown

=head1 SEE ALSO

L<Catmandu>,
L<Catmandu::Fix>

=head1 AUTHOR

Pieter De Praetere, C<< <pieter at packed.be> >>

=head1 CONTRIBUTORS

=over

=item * Pieter De Preatere, C<< <pieter at packed.be> >>

=item * Matthias Vandermaesen, C<< <matthias at colada.be> >>

=back

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
