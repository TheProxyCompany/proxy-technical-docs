# Moves

Moves are how Proxy hands you decisions and structured work. They keep important
agent output out of the churn of chat and turn it into something you can review,
accept, reject, defer, or complete.

## What A Move Contains

| Field | Meaning |
| --- | --- |
| Title | Short name for the decision or deliverable |
| Lede | One-sentence summary |
| Context | Why the Move exists |
| Blocks | Structured content such as text, choices, images, diffs, code, warnings, or progress |
| Status | Current review state |
| Response | Your answer, selection, or approval data |

## Move Statuses

| Status | Meaning |
| --- | --- |
| `pending` | Waiting for review |
| `active` | In progress or currently presented |
| `made` | Approved |
| `completed` | Finished after approval or execution |
| `rejected` | Declined |
| `later` | Deferred |
| `failed` | Could not complete |

Proxy Mobile counts `pending` and `active` Moves as waiting for you. Deferred
Moves stay visible in the pending stack until they are handled.

## Block Types

Move blocks are typed so the UI can render the right control.

| Block type | Typical use |
| --- | --- |
| `text` | Markdown or explanatory text |
| `image` | One image or image groups |
| `code`, `terminal`, `snippet` | Code or command output |
| `warning` | Risk, caveat, or attention marker |
| `progress` | Progress indicator |
| `choice`, `multi_choice` | User decision controls |
| `diff`, `before_after`, `side_by_side` | Comparison views |

## Review Flow

1. An agent or workflow creates a Move.
2. Proxy shows it in the Move stack.
3. You inspect the content and any requested choices.
4. You approve, reject, or defer it.
5. Proxy records the response and sends the result back to the agent or workflow.

On mobile, the basic actions are `Yes`, `No`, and `Later`. Detailed Moves can
open full screen, render their blocks, collect responses, and require local
confirmation before approval.

## How Moves Relate To Party Chat

Party chats are good for conversation and iteration. Moves are better when an
agent needs a durable answer or wants to present work for review. A Party can
create a Move, and the Move response can flow back into the Party or the
underlying workflow.
