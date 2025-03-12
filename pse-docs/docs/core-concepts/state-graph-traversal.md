# State Graph Traversal Algorithm

The state graph traversal algorithm is at the heart of PSE's ability to efficiently navigate complex grammar structures while maintaining deterministic performance characteristics. This document provides a comprehensive explanation of the algorithm's design, implementation, and unique features.

## Algorithmic Foundation

PSE's state graph traversal algorithm extends traditional non-deterministic finite automata (NFA) theory with several novel enhancements to achieve both flexibility and efficiency.

### Key Innovations

1. **Hierarchical Composition**: Unlike traditional NFAs where transitions are atomic symbols, PSE transitions contain nested state machines, creating a recursive graph structure that enables context-free grammar expressivity while maintaining finite state machine efficiency.

2. **Immutable Exploration**: The algorithm employs persistent data structures through clone-based immutability, allowing concurrent evaluation of multiple interpretation paths without state interference.

3. **Breadth-First Multi-Path Exploration**: Rather than using backtracking for non-determinism, the algorithm maintains and advances multiple steppers simultaneously, exploring all viable paths in parallel.

4. **Partial Match Processing**: The algorithm can process tokens that match only partially with expected patterns, using longest-prefix matching through a HAT-trie data structure.

5. **Hierarchical Probabilistic Path Selection**: When multiple valid paths exist, the algorithm employs a multi-criteria probabilistic selection that balances structural correctness with model-assigned probabilities.

## Formal Algorithm Description

Let us define:
- $G = (S, E, s_0, S_f)$ as a state graph where $S$ is the set of states, $E : S \times M \times S$ is the set of edges with associated sub-machines $M$, $s_0$ is the start state, and $S_f$ is the set of final states
- $P = \{p_1, p_2, ..., p_n\}$ as the set of active paths through the graph
- $T = \{t_1, t_2, ..., t_m\}$ as the sequence of input tokens

The traversal algorithm can be described as:

```
function AdvanceGraph(G, P, t):
    P' ← ∅
    Q ← {(p, t) for p in P}
    
    while Q is not empty:
        (current_path, current_token) ← Dequeue(Q)
        
        if not CanStartStep(current_path, current_token):
            continue
            
        sub_paths ← ConsumeWithSubMachine(current_path, current_token)
        
        for each sub_path in sub_paths:
            next_paths ← CompleteStep(current_path, sub_path)
            
            for each next_path in next_paths:
                if HasRemainingInput(next_path):
                    remaining ← GetRemainingInput(next_path)
                    ClearRemainingInput(next_path)
                    Enqueue(Q, (next_path, remaining))
                else:
                    P' ← P' ∪ {next_path}
    
    if P' is empty and EnableHealing:
        P' ← AttemptTokenHealing(P, t)
        
    return SelectBestPaths(P')
```

This algorithm is implemented in PSE's `advance_stepper` and `advance_all_sequential` methods in the StateMachine class, employing a breadth-first approach to explore all possible valid paths concurrently.

## Path Selection Algorithm

The path selection algorithm is a critical component that determines which path(s) to follow when multiple valid interpretations exist. It implements a hierarchical selection approach with strict prioritization:

### Selection Criteria (Highest to Lowest Priority)

1. **Acceptance State Priority**
   - Paths that reach accept states are always preferred
   - This ensures that complete structures are prioritized

2. **Token Healing Status**
   - Non-healed paths (exact matches) are preferred over healed ones
   - Ensures that perfect matches take precedence over partial matches

3. **Probability Score**
   - Higher probability paths (based on LLM token probabilities) are preferred
   - Integrates the language model's preferences into selection

4. **Token Length**
   - When scores are effectively equal, longer token matches are preferred
   - Provides consistent tie-breaking for similarly scored paths

The selection algorithm is implemented in the `StepperDelta::choose_best_path` method, which efficiently applies these criteria to find the optimal path(s).

## Token Healing Integration

Token healing is a novel feature that addresses mismatches between token boundaries and grammar expectations:

1. When a token cannot be consumed exactly, PSE attempts to find the longest valid prefix
2. This prefix is "healed" to create a valid path, marked with a healing flag
3. Healed paths receive lower priority in the selection process
4. This allows PSE to recover from tokenization mismatches gracefully

The integration between token healing and the traversal algorithm enables robust parsing even when token boundaries don't align perfectly with grammar expectations.

## Theoretical Significance

This algorithm makes several theoretical contributions:

1. **Extension of NFA Theory**: By allowing transitions to contain entire state machines rather than just symbols, the algorithm creates a computational model that bridges finite state automata and context-free grammars.

2. **Real-time Non-determinism Resolution**: Unlike traditional NFA-to-DFA conversion approaches, this algorithm maintains non-determinism through real-time exploration, selecting optimal paths based on probabilistic measures.

3. **Token Boundary Independence**: Through token healing, the algorithm achieves independence from tokenization boundaries, enabling robust parsing regardless of token segmentation.

4. **Probability-Guided Parsing**: The algorithm integrates probabilistic language model outputs with deterministic grammar constraints, creating a hybrid system that can navigate ambiguity through probability distributions.

## Computational Complexity

The algorithm has several complexity characteristics:

- **Time Complexity**: O(n×m) where n is the number of tokens and m is the number of active steppers
- **Average Case**: O(n) - Linear time complexity in most practical scenarios
- **Worst Case**: O(b^d) where b is the branching factor and d is the depth of exploration, though practical performance is significantly better due to early pruning of invalid paths
- **Space Complexity**: O(|P|) where |P| is the number of active paths, controlled through selective path advancement and pruning

## Performance Optimizations

Several optimizations make this algorithm efficient in practice:

1. **Trie-Based Token Matching**: Using HAT-trie data structures for O(k) token matching where k is token length
2. **Early Path Pruning**: Invalid paths are eliminated at the earliest opportunity
3. **Cached Transitions**: Common transition patterns can be cached for reuse
4. **Immutable Clone Optimization**: Strategic implementation of the clone operation with minimal copying
5. **Reference Counting**: Efficient memory management through intrusive reference counting

## Comparison to Traditional Approaches

| Approach | Time Complexity | Memory Usage | Backtracking | Handles Ambiguity |
|----------|----------------|--------------|--------------|-------------------|
| Recursive Descent | O(2^n) worst case | Low | Yes | Limited |
| Table-Driven LR | O(n) | High (tables) | No | Poor |
| PSE Traversal | O(n) average | Moderate | No | Excellent |

The PSE approach offers an optimal balance of performance, expressivity, and ambiguity handling.

## Example: Complex State Graph Traversal

To illustrate the algorithm in action, consider a complex JSON example:

```json
{
  "user": {
    "name": "John Doe",
    "tags": ["admin", "active"]
  }
}
```

### Step-by-Step Traversal

1. **Token: `{`**
   - Initial stepper at start state
   - Advances to object state
   - Only one possible path

2. **Token: `"user"`**
   - Stepper advances to property name state
   - Creates sub-stepper for string processing
   - Sub-stepper processes the quoted string
   - Returns to parent with completed property name

3. **Token: `:`**
   - Advances to property value state
   - Prepares for value processing

4. **Token: `{`**
   - Creates sub-stepper for nested object
   - Hierarchical traversal begins
   - Stepper stack now tracks both outer and inner objects

5. **Token: `"name"`**
   - Inner object property processing
   - Multiple potential continuations exist
   - All paths maintained concurrently

6. **Token: `:`**
   - Advances inner property to value state

7. **Token: `"John Doe"`**
   - String value processed by string state machine
   - Multiple attractive paths exist

In real implementations, each of these steps can involve multiple potential paths through the state graph, all explored concurrently and prioritized using the hierarchical selection criteria.

## Advanced Use Cases

The state graph traversal algorithm enables several powerful capabilities:

1. **Grammar-Constrained Generation**: Guiding language model generation through arbitrary grammar constraints while preserving model creativity.

2. **Robust Parsing**: Correctly parsing imperfect outputs even when token boundaries don't align with grammar expectations.

3. **Hierarchical Composition**: Building complex grammars from simple components through nesting and composition.

4. **Probabilistic Disambiguation**: Leveraging token probabilities to select the most likely interpretation when grammar is ambiguous.

5. **Schema Validation**: Ensuring outputs conform to precise schema requirements while maintaining natural language.

## Integration with Other Components

The state graph traversal algorithm integrates closely with other PSE components:

- **Stepper System**: Provides the position-tracking foundation for traversal
- **Token Healing**: Recovers from tokenization mismatches during traversal
- **Multi-Token Processing**: Handles grammar tokens that map to multiple LLM tokens
- **Engine**: Orchestrates the overall traversal process and integrates with LLMs

## Conclusion

PSE's state graph traversal algorithm represents a significant advancement in the intersection of formal language theory and probabilistic language modeling. By bridging non-deterministic state machines with hierarchical composition and probabilistic selection, it creates a powerful system for structured text generation and parsing.

This innovation enables PSE to maintain the perfect balance between grammar constraints and model creativity, ensuring outputs are both structurally correct and linguistically natural.

For detailed information on related components, see:
- [Core Architecture](core-architecture.md)
- [Stepper System](stepper.md)
- [Token Healing](token-healing.md)
- [Multi-Token Processing](multi-token-processing.md)