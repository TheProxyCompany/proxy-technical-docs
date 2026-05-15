# Timeline

Timeline is the chronological view of Life Map entries and recent activity. It
is the fastest way to skim what Proxy knows has happened recently.

## What Appears In Timeline

Timeline entries come from the Life Map entry store. Each entry has:

| Field | Meaning |
| --- | --- |
| Title | Optional explicit title |
| Entry type | `update`, `note`, `issue`, `decision`, `reference`, `takeaway`, or `metric` |
| Content | Markdown body |
| Author | Human or agent source |
| Created time | When the entry was recorded |
| Updated time | When the entry last changed |

If an entry has no title, Proxy uses the first meaningful line of content as
the display title.

## Mobile Timeline

Proxy Mobile starts on Timeline. It loads entries from the desktop instance,
keeps a local cache, supports pagination, and opens a full detail view for each
entry.

If the phone is not paired, Timeline shows the connection state instead of
stale data.

## How Timeline Relates To The Life Map

The Life Map stores the durable context. Timeline is the time-ordered reading
surface for that context. It is useful for:

- seeing recent decisions
- reviewing what changed today
- checking agent-authored updates
- reopening reference material
- understanding why a Move or Party exists

## Related

- [Life Map](life-map.md)
- [Moves](moves.md)
- [Party Chat](party.md)
