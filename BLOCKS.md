# Building Blocks
A collection of fixes that create a lot of the boilerplate (e.g. the wraps) inherent in a LIDO document.

A LIDO document broadly consists of three components, of which two (descriptiveMetadata and administrativeMetadata) can be created automatically by these fixes. They will create the component itself including all wraps below it until they arrive at a repeatable field (mostly a "set"). The last wrap (that contains the repeatable field, e.g. the leaf node) will be created as array.

The code will respect repeatable fields (creating them as an array), but not required/optional.

You can then use that path in a `with` bind to create the lower level elements (e.g. the eventSet). Note that both descriptiveMetadata and administrativeMetadata and the leaf nodes are created as array items, so you have to use a array positioning element (e.g. $first) in your `with` path.

Use `vacuum` to remove all empty fields.


## Example
```
lido_descriptionmetadata()
lido_administrativemetadata()

do with(path => lido.$first.descriptiveMetadata.objectClassificationWrap.objectWorkTypeWrap.0)
	add_field('foo', 'bar')
end
vacuum()
```

### Result:
```
---
lido:
- descriptiveMetadata:
    objectClassificationWrap:
      objectWorkTypeWrap:
      - foo: bar
...
```
