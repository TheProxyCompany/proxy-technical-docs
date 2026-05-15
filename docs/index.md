---
hide:
  - navigation
---
# The Proxy Company Documentation

Public documentation for Proxy, Orchard, and proxy.ing.

## Products

<div class="grid cards" markdown>

-   :material-apple: __Proxy__

    The desktop and mobile app layer. Proxy brings together the Life Map, Party
    sessions, agents, tools, local models, cloud models, and companion mobile
    workflows.

    [Docs](proxy/index.md){ .md-button .md-button--primary }
    [Getting Started](proxy/getting-started.md){ .md-button }

-   :material-leaf: __Orchard__

    Production local inference for Apple Silicon. Orchard is built for batched
    requests, streaming, high-throughput local serving, multiple loaded models,
    structured output, and Python or Rust clients.

    [Docs](orchard/index.md){ .md-button .md-button--primary }
    [Getting Started](orchard/getting-started.md){ .md-button }

-   :material-web: __proxy.ing__

    The public address layer for Proxy and Orchard. A `username.proxy.ing`
    address can serve web chat, an OpenAI-compatible route, and the Grand
    Central client, inference, and MCP routes from a local machine.

    [Docs](proxy-ing/index.md){ .md-button .md-button--primary }
    [Getting Started](proxy-ing/getting-started.md){ .md-button }

</div>

## The Three Layers

| Layer | What it is |
| --- | --- |
| Proxy | Desktop and mobile apps for Life Map, Party sessions, Moves, agents, and model routing |
| Orchard | Production local inference clients and servers for Python and Rust on Apple Silicon |
| proxy.ing | Public addresses that route web, API, Grand Central client, inference, and MCP traffic to a user's local machine |

## Start Here

| I want to... | Go to |
| --- | --- |
| Run a local model from Python | [Orchard getting started](orchard/getting-started.md) |
| Embed Orchard from Rust | [Orchard for Rust](orchard/rust.md) |
| Learn what Orchard is | [Orchard overview](orchard/index.md) |
| Run Orchard as a production local inference server | [Orchard production use](orchard/production.md) |
| Use Proxy on desktop or mobile | [Proxy overview](proxy/index.md) |
| Manage Proxy from the command line | [Proxy CLI reference](proxy/cli.md) |
| Understand `username.proxy.ing` addresses | [proxy.ing overview](proxy-ing/index.md) |

## Resources

- [Company website](https://theproxycompany.com)
- [Orchard website](https://orchard.md)
- [proxy.ing](https://proxy.ing)
- [GitHub organization](https://github.com/TheProxyCompany)
- [orchard on PyPI](https://pypi.org/project/orchard/)
- [orchard-rs on crates.io](https://crates.io/crates/orchard-rs)
