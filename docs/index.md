---
hide:
  - navigation
---
# The Proxy Company Documentation

Technical documentation for The Proxy Company's products and infrastructure.

## Our Products

<div class="grid cards" markdown>

-   :material-apple: __Eden__

    A macOS AI cockpit. Multiple agents deliberate together, then do the work. Life Map, Party system, local and cloud inference — one app.

    [:octicons-book-24: Eden Documentation](eden/){ .md-button .md-button--primary }

-   :material-tree-outline: __Orchard__

    Local Intelligence on Apple Silicon. A brand new inference engine, custom GPU kernels, continuous batching, multi-model generation, and error-free tool calling.

    [:octicons-book-24: Orchard Documentation](orchard/){ .md-button .md-button--primary }

</div>

## The Stack

```
Eden (SwiftUI macOS app)
  └── Glue (Rust FFI)
      └── Grand Central (coordination layer)
          ├── Trellis (graph database)
          ├── Pane (GPU rendering)
          ├── orchard-rs (local inference client)
          └── Cloud inference (Anthropic, OpenAI, Google, xAI)

Orchard (compute platform)
  └── PIE (C++ inference engine)
      ├── PAL (Metal GPU kernels)
      ├── PSE (structured generation)
      └── Carbon (private MLX fork)
```

Eden is the product. Orchard is the engine. Eden consumes Orchard for local inference and brings cloud models alongside it.

## Additional Resources

- [Company Website](https://theproxycompany.com)
- [GitHub Organization](https://github.com/TheProxyCompany)
- [orchard-py on PyPI](https://pypi.org/project/orchard-ai/)
- [orchard-rs on crates.io](https://crates.io/crates/orchard-rs)
