# Credits

Proxy uses a **gas pump model** for cloud inference billing. Credits are displayed in dollars — what you see is what you spend.

## How It Works

Proxy supports three inference paths:

| Path | Cost | How |
|------|------|-----|
| **Local (Orchard)** | Free | Models run on your Mac via PIE |
| **BYOK (Bring Your Own Key)** | Your API bill | You provide API keys for Anthropic, OpenAI, Google, or xAI |
| **Proxy Credits** | Pay-as-you-go | Proxy routes through OpenRouter, you pay per token in dollars |

## Proxy Credits

When you don't have API keys and don't want to run locally, Proxy Credits provide cloud inference with zero setup.

- **Displayed in dollars**, not abstract credit units
- **Charged per token** at the model's rate plus a small margin
- **Starter credits** are provisioned during onboarding — enough to try the product
- **Top up via Stripe** — standard payment flow, billed in real dollars

### Architecture

```
Proxy → OpenRouter (inference) → Model Provider
  ↕
Stripe (payments) → Proxy billing
```

OpenRouter acts as the inference ledger. Stripe handles payments. Proxy is the middleman — it provisions credits, tracks spend, and shows you the cost.

There is no balance database. OpenRouter is the source of truth for credit balance. Stripe is the source of truth for payments.

### Per-Conversation Cost

Proxy shows per-conversation cost in the UI — how much each conversation has cost across all messages. This helps you understand which conversations and models are expensive.

## API Key Management

API keys are stored in the macOS Keychain:

```bash
# Set a provider key
proxy provider key set anthropic sk-ant-...

# Check key status
proxy provider key status anthropic

# Test a key
proxy provider key test anthropic
```

## Routing Priority

When multiple inference paths are available, Proxy routes based on your configuration. A single toggle in settings controls whether local or cloud models take priority.
