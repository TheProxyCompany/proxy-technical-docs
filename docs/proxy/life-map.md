# Life Map

**Life Map is the connected context your Proxy uses to understand your life.**
It links your people, projects, goals, files, commitments, and decisions on your
computer, so each conversation can build on what already matters to you.

## A concrete example

Suppose you want to change jobs. Your Life Map can connect that goal to your
target role, portfolio, people you want to contact, application deadlines, and
the reasons you chose a particular direction. A draft introduction belongs to
the person it is for and the goal it advances, rather than disappearing into a
chat history.

An agent can use those connections to prepare a relevant next step. A Move
might ask you to review a portfolio update or an introduction before sending it.

## Why it stays with you

The Life Map is stored locally, separate from any one model provider. Supported
agents can receive relevant context or query it through Proxy tools. You can
change models while keeping the same underlying projects and decisions.
This does not mean every model automatically sees everything: what it receives
depends on the agent configuration and tools. Using a cloud model sends the
context needed for that request to that provider.

## Build it over time

Start with one goal and the information needed to work on it. You can ask
your Proxy to help organize that context:

> Keep my job-change goal in my Life Map. Link it to my portfolio, the roles
> I am considering, and the people I want to contact. Record why I chose the
> first role to pursue.

Review the saved items and their connections. Check names, dates, and whether
an agent has mistaken a possibility for a commitment. Add or correct context
as your plans change. A conversation is useful input, but do not assume that
everything said in chat has been recorded in the Life Map.

Before a new piece of work, ask your agent to use the relevant goal and its
related context. After a decision, keep the outcome and its reasons with the
project. The [Timeline](timeline.md) shows those entries over time, while the
Life Map shows how the pieces relate.

## Change the model, keep the context

You might use one agent to research roles and another to edit your portfolio.
The goal, files, and past decisions can stay in the same Life Map as you change
models. Equip the agent with Life Map access or enable relevant context in
its [loadout](roster.md#loadouts), the configuration that chooses its model,
instructions, and tools.

Sharing a Party conversation with someone else's Proxy does not automatically
share your whole Life Map. Review what the connected agent will use and what
it shares back into that conversation.

The following reference describes the types of information and connections
used by the Life Map.

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
