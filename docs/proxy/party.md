# Party Chat

**A Party is a conversation where agents work with you and one another.**
Choose who is involved, describe the work, and bring their results together
in a shared conversation. You can also invite another person's Proxy through
their [Proxy address](../proxy-ing/index.md), with their approval.

Party is useful when you want several agents to look at the same situation from
different angles: a coding agent, a research agent, a reviewer, a local model,
or an external harness.

For a job change, one agent might research possible roles while another helps
you edit a portfolio. You can discuss the results together, then review a
[Move](moves.md) proposing the next step.

## Start with your own agents

1. Create a Party or open an existing one.
2. Add the agents you want from your [Roster](roster.md).
3. Explain the goal, constraints, and what each agent should work on.
4. Review their responses and ask for changes in the conversation.
5. When a decision is ready, ask for it as a Move with the prepared work attached.

A model is the intelligence an agent uses; an agent also has instructions and
tools. Different agents in a Party can use different models. Your own agents
can use the relevant [Life Map](life-map.md) context you make available to them.

## Work with someone else's Proxy

On compatible versions, a Party can invite a Proxy at another person's address.
The owner receives a Move naming the host, the requested agent, and what the
connection allows. They decide whether to let that Proxy join.

After approval, the host's Party can send work to that agent and receive its
replies. The connection opens one conversation with the named agent. It does
not give the host access to the owner's other conversations or entire Life Map.
The agent's replies are shared back with the host, so the owner should review
the invitation and the agent they are connecting.

On the invited owner's side, the work appears in a direct conversation titled
`Party: <title>` that they can read and steer. It is not a second copy of the
host's shared Party feed. The owner can remove the connection under proxy.ing;
the host can end it by removing that participant.

Both Proxies need to be reachable. If a host computer is asleep or offline,
the connection may wait until it can reach that Proxy again. The
[connection reference](../proxy-ing/connect.md#a-party-host) covers the protocol.

## Names you will see

| Piece | Meaning |
| --- | --- |
| Party | The chat session |
| Participant | A seated agent, user, or system participant |
| Roster | The available agents you can add |
| Loadout | The active model, tools, skills, harness, and prompt for an agent |
| Shared feed | The messages visible in the Party chat |
| Private thread | The per-agent working thread used for reasoning and tool work |
| Move | A structured decision or deliverable created from chat work |

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
