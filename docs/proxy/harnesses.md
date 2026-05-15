# Harnesses

Harnesses connect external agent runtimes to Proxy. A harness lets a runtime
such as Codex, Claude Code, or OpenCode participate in Party chat as an agent
instead of only being launched separately.

## What A Harness Does

| Job | Meaning |
| --- | --- |
| Launch | Start or connect to the external runtime |
| Authenticate | Use the runtime's own local auth state |
| Route context | Send Party messages, working directory, and selected context |
| Receive output | Stream messages, tool activity, and completion events back to Proxy |
| Track readiness | Report whether the runtime is installed, configured, and reachable |

## Harnesses And Loadouts

Harness selection is loadout-scoped. That means one agent can use a normal model
loadout for general chat and a harness-backed loadout for code work.

Common loadout fields for harness use include:

- `harness_id`
- `working_directory`
- `harness_overrides`
- enabled integrations
- enabled skills
- Life Map context injection

## Readiness Is Not Execution

The Harnesses screen tells you whether a runtime is installed, authenticated,
and connected. That is setup state. A real Party run is still the proof that the
selected agent, model, tools, auth, and working directory all work together.

If a Party run fails, check the Party error and the harness logs instead of
assuming the readiness badge was wrong.

## Harness Integration

Proxy can watch harness session events and translate them into Party activity.
For supported runtimes, this includes parsing the runtime's event format,
tracking tool calls, and attaching the result to the right Party participant.

Harness setup is managed on the Mac because it may need local binary paths,
shell environment, local auth, and file-system hooks.

## Related

- [Roster](roster.md)
- [Integrations](integrations.md)
- [Party Chat](party.md)
