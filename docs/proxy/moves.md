# Moves

Moves are how Proxy hands you decisions and structured work. They keep important
agent output out of the churn of chat and turn it into something you can review,
accept, reject, defer, or complete.

## From a goal to a decision

For a first DJ set, a Move might contain a researched venue, signup requirements,
and a draft inquiry. You can inspect the recipient and exact message, ask for
changes, or approve sending it. For a job change, a Move might contain a
portfolio revision or a proposed introduction to a contact.

These are illustrative examples. The connected tools determine which actions
Proxy can carry out. Approval records your decision; completion records whether
the resulting work finished. A Move can also simply present a document for review.

## Connection requests are Moves too

If Steve invites your Proxy to coordinate a DJ set with his, the invitation
arrives as a Move. Review who is asking, which agent they want to work with,
and what access the connection opens. You can decide from your desktop or
[Proxy Mobile](devices.md#on-your-phone).

A Party invitation opens one conversation with the named agent. The host
cannot use it to read your whole Life Map or approve your Moves. See
[your Proxy address](../proxy-ing/index.md) for how connections work.

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
