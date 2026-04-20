# Orchard

Orchard is the Local Intelligence compute platform for Apple Silicon. It's the engine that powers Proxy's local inference — running open models natively on your Mac with no cloud dependency.

## What Orchard Is

Orchard is a vertically integrated inference stack:

```
orchard-py (Python SDK) ──┐
                          ├──→ PIE (C++ inference engine)
orchard-rs (Rust SDK) ────┘       ├── PAL (Metal GPU kernels)
                                  ├── PSE (structured generation)
                                  └── Carbon (private MLX fork)
```

- **PIE** (Proxy Inference Engine) — C++23 inference server optimized for Apple Silicon
- **PAL** (Proxy Attention Lab) — Custom Metal GPU kernels for paged attention
- **PSE** (Proxy State Engine) — Grammar and structured generation engine
- **Carbon** — Private fork of Apple's MLX framework with multi-stream concurrency and epoch-based buffer safety

## Design Philosophy

Orchard exists because local inference on consumer hardware is a fundamentally different problem than cloud inference on GPU clusters.

- **Single device** — no distributed coordination, no fleet management, no network hops
- **Apple Silicon** — unified memory, Metal compute, exceptional performance-per-watt
- **Continuous batching** — multiple agents can share the same model simultaneously
- **Structured generation** — PSE guarantees models produce valid output (JSON, function calls, schema-constrained responses) without sacrificing creative capability

The bet: local gives velocity to outrun cloud. No server farm reconfiguration. No distributed KV cache coordination. Everything on one device means faster iteration.

## How Proxy Uses Orchard

Proxy connects to Orchard through **orchard-rs**, the Rust client library. The connection flows:

```
Proxy (SwiftUI)
  └── Glue (Rust FFI)
      └── Grand Central
          └── orchard-rs ──→ PIE (IPC) ──→ Model inference
```

PIE runs as a separate process. orchard-rs communicates with it over IPC (nanomsg). Grand Central manages the lifecycle — starting PIE when needed, routing inference requests, handling streaming responses.

## Client Libraries

| Library | Language | Distribution | Purpose |
|---------|----------|-------------|---------|
| **orchard-py** | Python | [PyPI](https://pypi.org/project/orchard-ai/) | Python SDK, FastAPI server, OpenAI-compatible API |
| **orchard-rs** | Rust | [crates.io](https://crates.io/crates/orchard-rs) | Rust SDK, IPC client, used by Grand Central |
| **orchard-swift** | Swift | SPM | Telemetry only (not inference) |

Both orchard-py and orchard-rs expose an OpenAI-compatible API surface — chat completions, streaming, tool calling, structured output.

