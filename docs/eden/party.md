# Party

The Party is Eden's multi-agent deliberation system. Multiple AI agents — local and cloud — join a shared conversation, each with their own role, tools, and private reasoning thread.

## How It Works

1. **You send a message** to the Party chat
2. **The message fans out** to each seated agent's private thread
3. **Each agent reasons privately** — thinking, tool use, drafts — in their own thread
4. **Agents share responses** back to the Party feed for everyone to see
5. **Agents can react** to each other's responses, creating multi-turn deliberation

The Party feed is the shared space. Private threads are where agents think. You see both.

## Formats

Party sessions run in a **format** — a configuration that defines roles, intents, routing, and coordination behavior. Formats shape how agents interact.

| Format | What it does |
|--------|-------------|
| **Forum** | Open discussion. All agents see all messages and can respond. Default format. |
| **Swarm** | Parallel execution. Agents work independently on subtasks. |
| **Pair Programming** | Two agents collaborate — one writes, one reviews. |

Each format defines:

- **Roles** — what system prompt each agent gets, whether they participate in initial fanout, whether they can react to other agents
- **Intents** — what tools are available, how tool choice works, when an invocation completes
- **Routing** — how messages flow between the Party feed and private threads
- **Quiescence triggers** — what happens when all agents have finished responding (follow-ups, summaries, etc.)

## Intents

Intents are the coordination primitive. When an agent is invoked, it runs under an **intent** that controls:

- **Tools available** — which tools the agent can use for this invocation
- **Tool choice policy** — auto, required (one-shot or persistent), or none
- **Completion condition** — when the invocation is considered done (immediate, first no-tool turn, specific tool call, turn count)
- **MCP access** — whether the agent can use connected MCP servers
- **Queue priority** — critical, high, normal, low
- **Coalescing** — whether duplicate pending intents should be merged or replaced

## Teams

Agents are organized into **teams**. A team defines which agents participate and what role each plays. When you create a Party session with a team, all team members are automatically seated.

```
Team: "Research"
  ├── Agent A (role: lead)
  ├── Agent B (role: participant)
  └── Agent C (role: participant)
```

## Sequences

Party messages use a **content/topology separation**:

- **Items** are pure content — created once, immutable
- **Sequences** are per-thread topology — ordering, branching, compaction

The same item can appear in multiple threads via sequence references. When a message fans out from the Party feed to private threads, the item is created once and referenced — no duplication.

This supports:

- **Branching** — explore alternative conversation paths
- **Compaction** — summarize old context to keep threads manageable
- **Tangents** — spin off sub-conversations anchored to a specific message, then resolve results back to the parent

## Harnesses

External agent runtimes connect to the Party through **harnesses**:

| Harness | Transport |
|---------|-----------|
| **Claude Code** | Process (stdin/stdout JSONL) |
| **Codex** | WebSocket |
| **OpenClaw** | WebSocket |

Harnesses let agents that run outside Eden participate in Party sessions with full tool access.

