# Catmandu Lido Fixes

Support for the minimal requirements of [CIDOC-CRM](https://www.projectcest.be/wiki/Standaard:CIDOC-richtlijnen):

* institution name -> `lido_repository(institution_name, work_id)`
* inventory number -> `lido_recid(rec_id)`
* object key word -> `lido_worktype(work_type)`
* title -> `lido_title(title, source)`
* brief description -> `lido_description(description)`
* acquisition method
* acquired from
* acquisition date

> 
```
lido_event(
	type: string (mandatory),
	id: path (optional),
	name: path (optional),
	actor_name: path (optional, but required if actor_role or actor_id),
	actor_role: string (optional),
	actor_id: path (optional),
	date_display: path (optional),
	date_iso: string (optional)
)
```

* permanent location
