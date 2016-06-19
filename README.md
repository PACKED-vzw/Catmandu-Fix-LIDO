# NAME

Catmandu::Fix::LIDO - Implement LIDO fixes

# SYNOPSIS

A set of fixes for the Catmandu project to convert data to the LIDO XML format.

These fixes generate a data structure that can be exported to XML using the Catmandu LIDO exporter.

# MODULES

- [Catmandu::Fix::lido\_description](https://metacpan.org/pod/Catmandu::Fix::lido_description)
- [Catmandu::Fix::lido\_event](https://metacpan.org/pod/Catmandu::Fix::lido_event)
- [Catmandu::Fix::lido\_recid](https://metacpan.org/pod/Catmandu::Fix::lido_recid)
- [Catmandu::Fix::lido\_recordwrap](https://metacpan.org/pod/Catmandu::Fix::lido_recordwrap)
- [Catmandu::Fix::lido\_repository](https://metacpan.org/pod/Catmandu::Fix::lido_repository)
- [Catmandu::Fix::lido\_title](https://metacpan.org/pod/Catmandu::Fix::lido_title)
- [Catmandu::Fix::lido\_worktype](https://metacpan.org/pod/Catmandu::Fix::lido_worktype)

# DESCRIPTION

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

# SEE ALSO

[Catmandu](https://metacpan.org/pod/Catmandu),
[Catmandu::Fix](https://metacpan.org/pod/Catmandu::Fix)

# AUTHOR

Pieter De Praetere, `<pieter at packed.be>`

# CONTRIBUTORS

- Pieter De Preatere, `<pieter at packed.be>`
- Matthias Vandermaesen, `<matthias at colada.be>`

# LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
