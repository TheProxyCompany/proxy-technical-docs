# Party Chat

Party chat is Proxy's shared workspace for talking with agents. You choose who
is in the room, send a message, and Proxy routes the work to the selected
participants.

Party is useful when you want several agents to look at the same situation from
different angles: a coding agent, a research agent, a reviewer, a local model,
or an external harness.

## Core Pieces

| Piece | Meaning |
| --- | --- |
| Party | The chat session |
| Participant | A seated agent, user, or system participant |
| Roster | The available agents you can add |
| Loadout | The active model, tools, skills, harness, and prompt for an agent |
| Shared feed | The messages visible in the Party chat |
| Private thread | The per-agent working thread used for reasoning and tool work |
| Move | A structured decision or deliverable created from chat work |

## Typical Flow

1. Create a Party or open an existing one.
2. Add agents from the Roster.
3. Send a message into the shared feed.
4. Proxy routes the request to the seated agents.
5. Agents respond, call tools, create Moves, or ask for clarification.
6. The Party keeps the shared transcript and the relevant activity events.

## Roster In Party Chat

Each Party has its own seated roster. You can have many agents available in the
global Roster while only a few are active in a specific Party.

Mobile shows the Party roster for each chat thread and can add available agents
to the active Party.

## Harness Participants

Some agents run through local or external harnesses instead of a direct model
call. A harness participant can still appear in Party chat, receive context,
use configured tools, and send results back into the shared feed.

See [Harnesses](harnesses.md) for the runtime setup layer.

## Party And Moves

Party chat is conversational. Moves are reviewable. When an agent reaches a
decision point, it should make a Move instead of burying the ask in a long chat
thread.

That keeps the chat useful for collaboration while preserving clear user
approval points.

## Party MCP

Proxy exposes Party operations through the Party MCP server. Public proxy.ing
addresses can route to:

```text
https://username.proxy.ing/mcp/party
```

Use the Party MCP surface when an external MCP client needs to work with Party
sessions through an approved Proxy device.
