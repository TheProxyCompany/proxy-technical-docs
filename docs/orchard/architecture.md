# Architecture

Orchard's inference stack is built from the bottom up for Apple Silicon.

## The Stack

```
┌─────────────────────────────────────────────────┐
│  Client Libraries (orchard-py, orchard-rs)       │
│  OpenAI-compatible API, streaming, tool calling  │
├─────────────────────────────────────────────────┤
│  PIE (Proxy Inference Engine)                    │
│  C++23 — core execution, batching, scheduling    │
├─────────────────────────────────────────────────┤
│  PSE (Proxy State Engine)                        │
│  Structured generation — grammars, JSON schemas  │
├─────────────────────────────────────────────────┤
│  PAL (Proxy Attention Lab)                       │
│  Custom Metal kernels — paged attention, RoPE    │
├─────────────────────────────────────────────────┤
│  Carbon (MLX fork)                               │
│  Array operations, JIT Metal compilation         │
└─────────────────────────────────────────────────┘
```

## PIE — Proxy Inference Engine

The core inference server, built from scratch for Apple Silicon.

### Key Capabilities

- **Continuous batching** — dynamically packs prefill and decode sequences into batches each step, so multiple agents can share one model
- **Paged KV cache** — fixed-size pages (16 tokens), managed by a page allocator, supports multi-tier layouts for architectures like Gemma 3
- **Prompt caching** — reuses KV cache pages across requests with shared prefixes
- **Streaming** — token-by-token streaming with structured events
- **Multimodal** — vision model support (image preprocessing, embedding)
- **Tool calling** — native function calling with structured output
- **Carbon JIT** — Metal kernels embedded as string literals at build time, JIT-compiled at runtime

### Execution Flow

```
Request (IPC)
  → Tokenize
  → Schedule (ARScheduler)
  → Batch pack (prefill + decode sequences)
  → Forward pass (model layers + Metal compute)
  → Logit processing (repetition, bias, temperature, top_k, top_p, min_p)
  → Sampling
  → PSE constraint check
  → Stream token back
  → Repeat until done
```


## PSE — Proxy State Engine

The structured generation engine. PSE augments language models at runtime, steering token generation to produce valid output without sacrificing creative capability.

### What PSE Does

- **JSON schema enforcement** — guarantees model output conforms to a JSON schema
- **Grammar constraints** — arbitrary context-free grammars
- **Tool call formatting** — ensures function calls have valid names and arguments
- **State tracking** — tracks where the model is in a behavioral graph (thinking states, answering states, coordinate generation)

### How It Works

PSE builds a hierarchical state machine from the constraint specification. At each token generation step, it produces a **bitmask** of valid next tokens. The bitmask is applied to the logits before sampling — invalid tokens get negative infinity, valid tokens pass through unchanged.

This is alignment through architecture, not fine-tuning. The model is structurally incapable of producing invalid output for the constrained portions.

## PAL — Proxy Attention Lab

Custom Metal GPU kernels for attention computation. PAL implements paged attention directly on Apple Silicon's GPU, bypassing the generic compute paths.

Key kernels:

- **Paged attention** — efficient attention over non-contiguous KV cache pages
- **RoPE** — rotary position embedding computation
- **Memory management** — GPU-side page table operations

## Carbon

A private fork of Apple's MLX framework. Carbon extends MLX with:

- **Multi-stream concurrency** — multiple compute streams for overlapping operations
- **`compile_with_stream`** — JIT compilation scoped to specific compute streams
- **Epoch-based buffer safety** — prevents use-after-free in concurrent execution

Carbon is the foundation — all array operations, Metal compilation, and GPU scheduling flow through it.
