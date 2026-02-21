# securecontext -- Development Guide

## What This Is

An R package for memory, knowledge persistence, RAG retrieval, and context window management for R LLM agents.

## Architecture

- S3 classes for value objects: document, retriever, context_builder, embedder
- R6 classes for stateful stores: vector_store, knowledge_store
- TF-IDF embeddings work locally with no external API
- Token counting uses word-based approximation (1.3 tokens/word)

## Development Commands

```bash
Rscript -e "devtools::test('.')"
Rscript -e "devtools::check('.')"
Rscript -e "devtools::document('.')"
```

## Test Structure

- test-document.R -- S3 document class
- test-chunk.R -- chunking strategies
- test-embeddings.R -- TF-IDF embedder
- test-vector-store.R -- vector store CRUD + search
- test-knowledge-store.R -- JSONL persistence
- test-retriever.R -- end-to-end retrieval
- test-context-builder.R -- token-aware assembly
- test-token-count.R -- token counting
- test-integration.R -- orchestr/ellmer helpers
