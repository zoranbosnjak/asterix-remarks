---
title: "The major problem of 'asterix part-1'"
date: 2026-07-25
---

Part-1 document is suppose to be a *complete description* of asterix data
format, describing all structural details and covering all cases. Instead,
it seems like the document only covers the latest categories/editions and the
most common usecases. In particular:

- Some categories are explicitely excluded from the document;
- Historic problems in asterix structure are not covered or are explicitely
  removed;
- Part-1 lags behind the new editions of asterix specifications. It is often
  updated years "after the fact";

> There is no "ultimate part-1" which covers all asterix.

This has created a confusing situation where some asterix categories, perhaps
up to some editions follow "part-1, edition say 1.2", following asterix
editions are in accordance with "part-1, edition 2.3", other
categories/editions to "part-1, edition 3.1" and so on...

This is really a problem for users trying to implement a generic asterix
processor (suitable for all asterix categories/editions). For example, if we
design a receiver, we might still want to be able to process old sources, just
by switching the edition in a configuration. The wireshark asterix decoder is a
perfect example of such generic processor. If we try to implement it, we must
follow *some* structure, which is generic enough for all asterix.

In this context, the main objectives of Asterix Maintenance Group - AMG should
be to:

- Consider all asterix standards, all categories, all editions, all REFs...
  with maybe very rare exceptions which are considered "not asterix". Keep 001,
  002, 008 and all similar categories under the same umbrella. Keep in mind
  that old editions of asterix specification are potentially still in use.
- Create the next edition of part-1, such that it covers them all... in the
  spirit: *Part-1 describes asterix data format in full.*
- Make sure that no new unintentional problems are created with new asterix
  editions. All future editions are in line with the latest edition of part-1.
- Changing the structure is *a breaking change* and shall be avoided, unless
  absolutely necessary. In that case, the part-1 shall be updated first and
  only then a new category/ref/edition shall be published. Such that part-1
  always covers "all asterix".

# Required updates to part-1

It is important to note that required updates to part-1 do not in any way
prevent to keep the new asterix editions "clean" as already intended. It merly
documents all facts about asterix, including historic ones. Just to be
complete.

> A user who studied part-1 should get no "surprises" when confronted with
> any asterix specification, either a basic category or a REF. This includes
> the old editions.

## Part-1 shall respect the RFS indicator

Part-1 shall document the RFS indicator bit and the RFS mechanism. I understand
it's not intended to be used with new categories. It does not have to be!

Part-1 is only required to include the text in lines with: "The UAP can include
a so called RFS bit indicator..., followed by a short description of how the
mechanism works... and a note: It is present in some old categories. It is not
foreseen to be used with the new categories."

This small update can not harm new categories/editions in any way, but it
*brings back* categories 002 and 008, which are excluded from the current
version (3.1) of part-1.

## Part-1 shall consider multiple UAPs

Some (old) categories contain multiple UAPs. The part-1 shall only mention this
fact, again with the remark that it's a *legacy*.

> There is no need to exclude category 001 and some others from part-1, just
> for this minor problem.

## Part-1 shall handle the problem with the extended length item

This problem is more involved...

The I021/271, up to edition 2.1 is without a trailing FX bit. It's likely an
unintentional mistake, but it's there and the edition is still in use. This
does not fit to the structure, described in part-1, chapter "Extended Length
Data Items".

To fix the problem, the concept of extended item shall be generalized, from
"primary part of 'n1+fx' bits, followed by (zero or more) secondary parts of
'n2+fx' bits each", to a more general form, allowing to have each secondary
part different number of bits and the last FX bit to be optional. The concept
of octets remains. If the FX bit is present, it must be the last bit in the
octet.

The category 021, prior and including edition 2.1 now becomes "valid asterix".
All other "regular" editions remain valid too. The new structure is just more
general, to cope with the problem.

Without this fix, some editions of category 021 are "non-asterix", which is a
shame. To support such edition in the current setting, users will need to
hardcode the exceptional case to the application and duplicate a lot of code,
which is error prone. The other alternative for a user is to "invent" some
generalization of extended, to be able to cope with the problem.

## Part-1 shall fix the blocking/non-blocking concept

Blocking/non-blocking property should not be "attached" to any particular
category in a first place. It introduces the unwanted "until and including
edition XY" statement to the part-1.

> Attaching blocking/non-blocking flag to each category or even to a
> particular edition was a mistake.

After all, the blocking/non-blocking mode is just a configuration of the
asterix data transmitter and can be used on any category, even on so called
blocking categories.

> The name "blocking" is already misleading.

The receiver must simply "know" what is the maximum number of records per
datablock. Not by category number alone, as intended by
"categories-and-statuses-2025" document, but by some other means. Just like it
must know what is the category/edition in use on a particular data flow.

The "ASTERIX Data Block" chapter could be described way more general, by only
describing the "multi record per datablock" situation. The follow up text can
describe the benefits of encoding only one record per datablock, which is to
mitigate asterix edition compatibility problem to some degree. The part-1 can
also encourag using this mode of operation on any new setup (regardless of a
category), if this is the intention.

Just as a side note..., the category 247 which contain version number
information could be extended with a new subitem under the I247/550 structure,
indicating what is the maximum number of records per datablock. Specified as
'enum', for example:

```json
0: "unspecified"
1: "max 1 record per datablock (non-blocking mode)"
2: "max 2 records per datablock"
3: "max 3 records per datablock"
... and so on, depending on the number of allocated bits
```

This information is more general than a single blocking bit indicator. In
addition to the "non-blocking" indication, the receiver might benefit from
knowing what is the maximum number of records per datablock. For some upfront
memory allocation, maybe.

## Part-1 shall describe the problem with dependent structures

This is likely the hardest asterix structure problem... Some items are defined
based on the "value" of some other item. The `I062/380/IAS` is a notable
example, and so is the `I004/120` with even more complicated dependency.

The part-1 shall highlight anomalies and decribe the problem in detail.

> This problem is not suppose to be ignored by part-1.

# Remarks about the implementations

It is usually reasonable for a particular asterix implementation to only
implement the relevant cases. But this is not the case for a base document,
such as part-1. In other words:

- The part-1 shall be complete.
- A particular implementation might decide to skip some non-relevant aspects of
  asterix, depending on a use case. For example, it might skip all corner cases
  described in this document and only implement "the simple asterix".

