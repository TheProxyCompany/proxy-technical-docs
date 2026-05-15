# Roster

The Roster is the set of agents available inside Proxy. It is where you inspect
who can work, what model or runtime they use, and what tools they can access.

## Agent Profile

An agent profile combines an identity with an active loadout.

| Field | Meaning |
| --- | --- |
| Agent identity | Name, avatar, description, and role |
| Active loadout | The selected configuration the agent runs with |
| Backend and model | Local Orchard model, cloud provider model, or other backend |
| Harness | Optional external runtime used to execute the agent |
| Tools and skills | Equipped integrations and local instructions |
| Appearance | Display name, avatar, tint, and accent color overrides |

## Loadouts

Loadouts let one agent have multiple operating modes. For example, the same
agent can have one loadout for local Orchard work, another for a cloud model,
and another for a harness-backed coding runtime.

A loadout can include:

- provider and model
- system prompt
- working directory
- Life Map context injection
- enabled integrations
- enabled skills
- harness ID and harness overrides
- sampling and reasoning settings

## Roster In Party Chat

The global Roster is the pool of available agents. A Party has its own seated
roster for that chat. Adding an agent to a Party gives that session access to
the agent's active loadout.

Proxy Mobile can show the roster for a Party thread and can add available
agents to the active Party.

## Mobile Roster

Proxy Mobile exposes Roster as a first-class tab. It lists real agents from the
desktop instance, opens agent profiles, and edits loadout-scoped fields through
Grand Central's client API.

The Mac remains the source of truth. Mobile mirrors enough data locally to keep
the interface responsive and refreshes when the desktop emits relevant events.

## Related

- [Integrations](integrations.md)
- [Harnesses](harnesses.md)
- [Party Chat](party.md)
