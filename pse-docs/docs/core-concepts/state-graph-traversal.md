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
