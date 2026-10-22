# What is Proxy?

A proxy is someone who acts on your behalf. **Your Proxy is your personal AI
representative:** it uses your context, models, agents, and connected tools to
prepare useful work, then brings decisions back to you.

For example, a goal like “play my first DJ set” can become venue research, a
booking inquiry, and a Move asking you to review the message. You get prepared
work and a clear next decision.

## One place for context, many ways to do the work

Your [Life Map](life-map.md) connects your goals, projects, people, files, and
past decisions. It is stored locally and can supply context to supported agents
and models. Changing a model does not mean rebuilding that context from scratch.
Local and cloud models can work in the same workspace. Cloud models and
connected services receive the information needed for their requests; local
storage does not make every connected workflow fully offline.

## Use it across devices

Use Proxy Mobile to review work away from your desk, or reach web chat and
connected apps from a browser. Your running desktop is the host: the computer
that keeps your context and serves those connections. The native host app
currently runs on macOS; mobile and browser access extend it to other devices.
See [Proxy across your devices](devices.md) for setup and availability.

## Give your Proxy an address

Your [Proxy address](../proxy-ing/index.md), such as **steve.proxy.ing**, is
also where other people and apps can ask to connect. On compatible versions,
someone can invite your Proxy into a Party with theirs. You receive a Move
naming the host and the agent they want to work with, and decide whether to
let them in. The connection gives them access to that conversation, not your
whole Life Map.

[Start your first session](getting-started.md).

## App Surfaces

| Surface | What it does |
| --- | --- |
| Proxy desktop | Main workspace for Parties, Moves, Life Map context, roster setup, models, integrations, and harnesses |
| Proxy Mobile | Companion app for Timeline, Roster, Proxy chat, Moves, and Party chats connected back to a running desktop instance |
| Proxy CLI | Command-line control plane for a running Proxy instance |
| proxy.ing | Your address for approved connections with people, their Proxies, and apps, as well as access from your own devices |

## Core Concepts

| Concept | Meaning |
| --- | --- |
| [Life Map](life-map.md) | Proxy's context layer for projects, people, commitments, files, decisions, and active work |
| [Moves](moves.md) | Reviewable cards and documents that ask for a decision or present structured work |
| [Party Chat](party.md) | Shared chats where you and selected agents work together, including invited Proxies |
| [Roster](roster.md) | The agents available to work inside Proxy |
| [Timeline](timeline.md) | A chronological feed of Life Map entries and activity |
| [Integrations](integrations.md) | Tools and services your agents can use |
| [Harnesses](harnesses.md) | External agent runtimes, such as Codex or Claude Code, that can join Party sessions |

## Model Routes

Proxy can mix model routes in the same product surface.

| Route | Use it for |
| --- | --- |
| Local Orchard models | Private Apple Silicon inference through Orchard |
| Bring Your Own Key | Cloud providers you configure with your own API keys |
| Proxy Credits | Pay-as-you-go cloud inference through Proxy |
| Harnesses | External agent CLIs and runtimes that run work outside the model router |

## Local Storage

The host stores your Life Map, conversations, settings, and content locally.
Proxy Mobile keeps a small cache for responsive views and connects to the host
for current data. Local storage keeps your context separate from a model
provider's account; cloud models and connected services still receive the
information needed for the requests you make through them.

## MCP Server

Developers can connect tools and apps through Proxy's APIs. Start with
[Connect your app](../proxy-ing/connect.md), the
[client API](../proxy-ing/client-api.md), or the [CLI reference](cli.md).
