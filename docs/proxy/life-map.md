# Life Map

The Life Map is Proxy's knowledge graph — your life, mapped as a graph — a structured representation of everything you're working on, tracking, and thinking about. It's stored in Trellis, a graph database built on sled (an embedded key-value store).

## The 8-8-7 System

The Life Map uses a unified type system: **8 node types, 8 edge types, 7 entry types.**

### Node Types

Nodes are things that exist in the graph.

| Node Type | What it is | Key Fields | Examples |
|-----------|-----------|------------|----------|
| **Category** | A grouping or domain | `color`, `icon` | Work, Health, Finance |
| **Action** | Work with defined scope | `phase` | "Ship v1", "Fix CI" |
| **Entity** | A thing, person, or object | — | "PIE", "Proxy", a person's name |
| **Event** | Something that happens at a time | `occurs_at` | "v1 Launch", "Board Meeting" |
| **Condition** | A state that can be true or false | — | "Runway > 12mo", "CI Green" |
| **Concept** | An idea or principle | — | "Local Intelligence", "PageRank2" |
| **File** | Reference to content-addressed storage | `content_hash`, `filename`, `mime_type`, `size`, `uri` | "prd.pdf", "mockup.png" |
| **Entry** | A log-like record attached to any node | `entry_type`, `title`, `content`, `author` | Progress notes, decisions, metrics |

All non-Entry nodes share: `id`, `name`, `description` (optional), `created_at`, `updated_at`.

**Action phases:** `planned` → `doing` → `done` or `stopped`.

### Edge Types

Edges connect nodes with semantic meaning.

| Edge Type | Meaning | Extra Fields | Example |
|-----------|---------|-------------|---------|
| **HAS** | Containment or ownership | — | "Work HAS Ship-v1" |
| **ABOUT** | Entry relates to a node | — | "progress-note ABOUT ship-v1" |
| **NEEDS** | Dependency or prerequisite | `met` (bool) | "v1-launch NEEDS ci-green" |
| **WANTS** | Aspirational pull (softer than NEEDS) | — | "proxy WANTS semantic-search" |
| **MAKES** | Production or creation | — | "PIE MAKES embeddings" |
| **FOR** | Purpose or beneficiary | — | "protocol FOR body-recomp" |
| **IMPACTS** | Weighted influence | `weight` (f64) | "sleep-quality IMPACTS focus" |
| **DYNAMIC** | Freeform relationship | `weight` (f64), `description` | Any user-defined relationship |

### Entry Types

Entries are log-like records attached to nodes via `ABOUT` edges.

| Entry Type | What it captures |
|-----------|------------------|
| **update** | Progress on an action or entity |
| **note** | General observations |
| **issue** | A problem to address |
| **decision** | A choice that was made and why |
| **reference** | A pointer to external information |
| **takeaway** | A lesson learned |
| **metric** | A measurement |

## Structure

The graph is **flat nodes connected by edges.** There is no enforced hierarchy. Structure emerges from edge relationships:

- A `Category` can `HAS` Actions, Entities, or other nodes to create groupings
- An `Action` can `NEEDS` a `Condition` to express a blocker
- An `Entity` can `IMPACTS` an `Action` with a weight

## Leverage

PageRank2 runs over the graph to compute which nodes have the highest **leverage** — completing them unblocks the most downstream progress.

Key outputs:

- **Leverage score** — how structurally important completing this node is
- **Transitive unlocks** — how many downstream nodes it frees
- **Direct blockers** — what `NEEDS` edges point at this node with `met = false`

The `NEEDS` edges (with their `met` boolean) are the primary input to leverage computation. `IMPACTS` edges with weights provide secondary signal. The algorithm uses a Laplacian voltage solve — two-stage centrality then voltage — to propagate value through the graph topology.

## Mutations

Both humans and agents mutate the graph through the same pipeline:

```
Human (Proxy UI)  ──┐
                   ├──→ Glue FFI → Trellis → graph/
Agent (MCP tool) ──┘
```

Every mutation goes to the undo stack (for Cmd+Z) and gets batched into changesets (for sync). The graph doesn't know or care whether a human or agent made the change.

## MCP Access

When Proxy is running, the Life Map is queryable via MCP tools on `localhost:51711`:

```bash
# List all actions in progress
proxy_list entity_type=action filters={"phase": "doing"}

# Get a specific node
proxy_get entity_type=action id="ship-v1"

# See the structural overview
proxy_overview limit=10 depth=2

# Recent activity
proxy_recent limit=20

# Add an edge
proxy_add_edge from_id="a" to_id="b" edge_type="NEEDS"
```
