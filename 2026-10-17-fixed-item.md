---
title: "Asterix fixed item variations"
date: 2026-10-17
---

Some time ago an observation was presented during the AMG meeting that some
items labeled as "extended" do not reflect the structure of the extended item.
The `I048/030` is an example of such item. It has a distinct structure from the
normal extended item in that the same "chunk of data" repeats inside the
structure (like in the repetitive item), while each chunk is terminated with
the FX bit (like in the extended item). It is therefore "a mix" between
"extended" and "repetitive" item or a "variation of the repetitive" item.

# Two different kinds of fixed item

In the same vein, there is even more subtle distinction in the "fixed item",
which is one of the basic building blocks of asterix. The observation is that
there are actually 2 different kinds of fixed items. For example:

- `I062/010` is a fixed item
- `I062/015` is also a fixed item

Both are "fixed items in size", but there is a structural difference between
the two. Namely the former contains deeper structure (the SAC/SIC subitems)
while the latter does not. A simplified structure is:

```
010 "Data Source Identifier"            <- (fixed 16 bits with subitems)
    SAC "System Area Code"              <- (fixed 8 bits)
    SIC "System Identification Code"    <- (fixed 8 bits)

015 "Service Identification"            <- (fixed 8 bits)
```

> Items [`I062/010` and `I062/015`] are not of the same kind. However, items
> [`I062/015`, `I062/010/SAC` and `I062/010/SIC`] all share the same structure.

With this observation it makes sense to formally differentiate between:

- **fixed group** item (with deeper structure) and
- **fixed element** item (no more structure, just data)

There are several benefits of recognising the difference.

Consequent simplification is that there is no need for the toplevel item to
have subitems. Some toplevel items have a simple "fixed element shape". For
instance, in the `asterix2json` but also in other asterix related projects, the
`I062/015` structure has additional layer and looks something like this
instead:

```
015 "Service Identification"            <- (fixed 8 bits with subitem)
    Service_ID "Service Identification" <- (fixed 8 bits)
```

Please note that "`Service_ID`" identifier in this example is "forced" and is
not actually (does not need to be) present in the structure.

Some other implementations for example use "`SID`" identifier, instead of
"`Service_ID`", which already creates a small incompatibility between the
implementations. The reason is that the (unnecessary) second level identifier
is not standardized and needs to be selected by the implementator.

Another detail to note is the subitem access in programming languages. If an
asterix program follows the structure of asterix specification (as it should),
the item extraction looks something like this pseudo code:

```python
record = ...
item_010 = record.get_item("010")
item_015 = record.get_item("015")

# check item presence, extract data
if item_010 is present:
    # need to go deeper to get the data
    sac = item_010.get_item("SAC").convert_to_unsigned_int()
    sic = item_010.get_item("SIC").convert_to_unsigned_int()
    print("got 010/SAC and 010/SIC", sac, sic)

# check item presence, extract data
if item_015 is present:
    # already have what we need, no more subitems, just convert
    print("got 015", item_015.convert_to_unsigned_int())
```

On the other hand a 2-level top-item structure would lead users to do
something like this instead:

```python
if item_015 is present:
    # we first need to 'unwrap' the only subitem to get the data
    service_id = item_015.get_item("Service_ID")
    print("got 015/Service_ID", service_id.convert_to_unsigned_int())
```

> A distinction between "Fixed Element" and "Fixed Group" items simplifies
> overall asterix structure which is then reflected also in the asterix
> processing library or application.

This remark is also applicable to the item `I048/030`, mentioned earlier. The
issue is that there is no need for any additional subitem level, such as
`CODE`, `WarningError` or any similar identifier. In programming terms:

```python
item_030 = record.get_item("030")
if item_030 is present:
    # We can iterrate over it's list representation.
    for el in item_030.get_list():
        print('got ', el.convert_to_unsigned_int())

    # We don't need to access a subitem (wrong example).
    for el in item_030.get_list():
        code = el.get_item("CODE") # bogous subitem access
        print('got ', code.convert_to_unsigned_int())
```

# Conclusion

The current single "fixed item" view requires a structure to always anticipate
subitems (another layer in the strucutre), even in cases where there is no
further structure.

A better model is to "split" fixed item into:

- fixed **group** with a deeper structure
- fixed **element** wihout a structure

This distinction better models the actual structure of asterix specifications
and simplifies data processing.

Part-1 document should also mention this observation.

