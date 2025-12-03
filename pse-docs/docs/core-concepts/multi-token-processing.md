# Multi-Token Processing

Multi-Token Processing (MTP) is an optional optimization within the Proxy State Engine (PSE) designed to accelerate generation when the grammar requires a specific sequence of characters that corresponds to multiple tokens in the language model's vocabulary.

## The Problem: Inefficient Generation for Fixed Sequences

Grammars often require specific keywords, operators, or phrases (e.g., `"function"`, `">="`, `"null"`). While PSE guarantees these are generated correctly, standard one-token-at-a-time generation can be inefficient if the sequence is long and represented by many tokens (e.g., `"metacognition"` might be tokenized as `["meta", "cognition"]`). If the grammar dictates that `"metacognition"` is the *only* valid continuation at a certain point, making the LLM generate `"meta"` and then separately generate `"cognition"` involves unnecessary steps.

## How Multi-Token Processing Optimizes

When MTP is enabled (`multi_token_sampling=True` in the `StructuringEngine`, default is `False`), PSE attempts to identify these unambiguous multi-token sequences:

1.  **Identify Required Sequence:** PSE determines the valid continuation strings required by the current state(s) of the grammar (e.g., only `"metacognition"` is allowed next).
2.  **Tokenize Sequence:** It finds the corresponding sequence of tokens from the model's vocabulary (e.g., `["meta", "cognition"]`).
3.  **Check for Ambiguity:** PSE checks if the *first* token of this sequence (e.g., `"meta"`) could *also* be the start of any *other* valid multi-token sequence allowed by the grammar at this exact point.
4.  **Unambiguous Case - Proactive Return:** If the sequence is unambiguous (i.e., only `"metacognition"` can follow the sampling of `"meta"` according to the grammar), PSE can proactively return the *entire* sequence of tokens (`["meta", "cognition"]`) to the generation loop in a single step, even though the LLM only sampled the first one.
5.  **Ambiguous Case - Cautious Return:** If the first token is ambiguous (e.g., the grammar allows both `"less_than"` represented by `["less", "_than"]` and `"less_than_or_equal_to"` represented by `["less", "_than", "_or", "_equal", "_to"]`), PSE will only return the common prefix sequence (`["less", "_than"]`) or potentially just the first sampled token (`"less"`). This avoids prematurely committing to the wrong grammatical path.

## Benefits

*   **Increased Efficiency:** Reduces the number of LLM forward passes required when the grammar dictates specific, unambiguous multi-token keywords or phrases.
*   **Faster Generation:** Can significantly speed up the generation of boilerplate text, fixed syntax elements, or required keywords within the structured output.

## User Experience

This optimization works automatically behind the scenes when enabled. Users define their grammar using strings and high-level constructs; PSE handles the token-level analysis and potential multi-token returns to improve generation speed where possible without sacrificing the structural guarantee.
