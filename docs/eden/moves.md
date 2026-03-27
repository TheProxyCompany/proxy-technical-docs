# Moves

Moves are structured deliverables in Eden. They're block-based documents that agents execute on your behalf — research briefs, onboarding flows, analysis reports, action plans.

## What a Move Is

A Move is a structured document made of **blocks**. Each block has a type (text, heading, checklist, code, image, executable) and content. Moves are stored as files and tracked in the Life Map.

Think of Moves as the output artifacts of agent work — not chat messages, but real deliverables.

## Block Types

| Block Type | What it is |
|-----------|-----------|
| **Text** | Markdown text content |
| **Heading** | Section headers |
| **Checklist** | Actionable items with completion state |
| **Code** | Code blocks with language annotation |
| **Image** | Embedded images |
| **Executable** | Blocks that agents can run — shell commands, API calls, or other actions |

## Executable Blocks

Executable blocks are the bridge between documentation and action. An agent can define a block that, when executed:

- Runs a shell command
- Calls an API
- Mutates the Life Map
- Triggers another agent


## How Moves Work

1. An agent (or you) creates a Move with a set of blocks
2. The Move appears in Eden's UI as a structured document
3. You can review, edit, approve, or reject blocks
4. Executable blocks can be run individually or as a batch
5. Progress is tracked — completed blocks, pending actions, overall status

