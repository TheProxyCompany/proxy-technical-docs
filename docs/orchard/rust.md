# Orchard For Rust

Use `orchard-rs` when you want Orchard inside a Rust application or service.
The crate manages the local engine lifecycle, model loading, IPC connection,
and streamed responses.

## Install

```toml
[dependencies]
orchard-rs = "2026.5.6"
serde_json = "1"
tokio = { version = "1", features = ["macros", "rt-multi-thread"] }
```

The library name is `orchard`:

```rust
use orchard::{Client, ChatResult, InferenceEngine, ModelRegistry, SamplingParams};
```

## Run A Prompt

```rust
use std::collections::HashMap;
use std::sync::Arc;

use orchard::{ChatResult, Client, InferenceEngine, ModelRegistry, SamplingParams};

fn message(role: &str, content: &str) -> HashMap<String, serde_json::Value> {
    HashMap::from([
        ("role".to_string(), serde_json::json!(role)),
        ("content".to_string(), serde_json::json!(content)),
    ])
}

#[tokio::main]
async fn main() -> orchard::Result<()> {
    let _engine = InferenceEngine::new().await?;
    let registry = Arc::new(ModelRegistry::new()?);
    let client = Client::connect(Arc::clone(&registry)).await?;

    let model = "google/gemma-4-E2B-it";
    let messages = vec![message("user", "Write one sentence about local AI.")];
    let params = SamplingParams {
        max_tokens: 64,
        temperature: 0.0,
        ..Default::default()
    };

    match client.achat(model, messages, params, false).await? {
        ChatResult::Complete(response) => println!("{}", response.text),
        ChatResult::Stream(_) => unreachable!("streaming was disabled"),
    }

    Ok(())
}
```

On first use, Orchard downloads the engine binary and model weights. Later runs
reuse the cached files.

## When To Use Rust

Use `orchard-rs` when you are:

- Building a Rust desktop app, daemon, worker, or service
- Embedding Orchard next to other Rust systems
- Managing multiple requests from a long-running process
- Integrating with Proxy internals or other Rust infrastructure

For scripts, notebooks, and quick local experiments, start with
[Orchard Python](getting-started.md).
