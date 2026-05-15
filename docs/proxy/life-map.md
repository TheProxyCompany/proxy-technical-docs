# Life Map

The Life Map is Proxy's context layer. It keeps track of the projects, people,
files, commitments, decisions, events, and open loops that should shape how
your agents help you.

The visible product goal is simple: Proxy should know what you have going on
right now, what is blocked, what is stale, and what deserves attention next.

## What It Contains

| Kind | What it captures |
| --- | --- |
| Categories | Broad areas such as work, health, money, family, or creative projects |
| Actions | Work that can move through planned, doing, done, or stopped |
| Entities | People, companies, products, repos, places, and other named things |
| Events | Dated moments, deadlines, meetings, launches, or milestones |
| Conditions | States that can be true or false, such as a blocker being cleared |
| Concepts | Ideas, principles, preferences, and mental models |
| Files | References to stored documents, images, screenshots, or other content |
| Entries | Notes, updates, issues, decisions, references, takeaways, and metrics |

## Relationships

Life Map items are connected by relationships such as:

| Relationship | Meaning |
| --- | --- |
| `HAS` | One thing contains or owns another |
| `ABOUT` | An entry is about a node |
| `NEEDS` | One thing depends on another |
| `WANTS` | Softer desire or pull |
| `MAKES` | One thing creates or produces another |
| `FOR` | Purpose or beneficiary |
| `IMPACTS` | Weighted influence |
| `DYNAMIC` | Custom relationship with a description |

These relationships let Proxy see more than a flat task list. A Move can be
connected to the project it advances, the file it reviews, the condition it
unblocks, and the person it is for.

## Timeline Entries

Entries are the Life Map's activity records. They are what power the Timeline.

| Entry type | Use it for |
| --- | --- |
| `update` | Progress on work |
| `note` | General context |
| `issue` | Something that needs attention |
| `decision` | A choice and why it was made |
| `reference` | External context |
| `takeaway` | A lesson or synthesis |
| `metric` | A measured value |

## Agent Context

Agents use the Life Map to understand the current situation before acting. For
example, a coding agent can see the active project, relevant files, recent
decisions, and unresolved blockers instead of only seeing the last chat message.

Life Map context can be injected into an agent's active loadout. It can also be
queried through Proxy's MCP tools when an external client needs current context.

## Under The Hood

Internally, the Life Map is stored as nodes and edges in the local graph store.
That implementation detail matters for sync, undo, references, and agent tools,
but the user-facing purpose is context: what matters, how it connects, and what
should happen next.
