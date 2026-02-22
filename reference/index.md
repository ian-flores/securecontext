# Package index

## Documents

- [`document()`](https://ian-flores.github.io/securecontext/reference/document.md)
  : Create a document
- [`securecontext_document()`](https://ian-flores.github.io/securecontext/reference/securecontext_document.md)
  : S7 class for securecontext documents
- [`is_document()`](https://ian-flores.github.io/securecontext/reference/is_document.md)
  : Test if object is a document

## Chunking

- [`chunk_text()`](https://ian-flores.github.io/securecontext/reference/chunk_text.md)
  : Chunk text into smaller pieces
- [`chunk_fixed()`](https://ian-flores.github.io/securecontext/reference/chunk_fixed.md)
  : Fixed-size text chunking
- [`chunk_sentence()`](https://ian-flores.github.io/securecontext/reference/chunk_sentence.md)
  : Sentence-based text chunking
- [`chunk_paragraph()`](https://ian-flores.github.io/securecontext/reference/chunk_paragraph.md)
  : Paragraph-based text chunking
- [`chunk_recursive()`](https://ian-flores.github.io/securecontext/reference/chunk_recursive.md)
  : Recursive text chunking

## Embeddings

- [`new_embedder()`](https://ian-flores.github.io/securecontext/reference/new_embedder.md)
  : Create an embedder
- [`securecontext_embedder()`](https://ian-flores.github.io/securecontext/reference/securecontext_embedder.md)
  : S7 class for securecontext embedders
- [`embed_tfidf()`](https://ian-flores.github.io/securecontext/reference/embed_tfidf.md)
  : Create a TF-IDF embedder
- [`embed_texts()`](https://ian-flores.github.io/securecontext/reference/embed_texts.md)
  : Embed texts using an embedder

## Vector Store

- [`vector_store`](https://ian-flores.github.io/securecontext/reference/vector_store.md)
  : Vector Store

## Knowledge Store

- [`knowledge_store`](https://ian-flores.github.io/securecontext/reference/knowledge_store.md)
  : Knowledge Store

## Retrieval

- [`retriever()`](https://ian-flores.github.io/securecontext/reference/retriever.md)
  : Create a retriever
- [`securecontext_retriever()`](https://ian-flores.github.io/securecontext/reference/securecontext_retriever.md)
  : S7 class for securecontext retrievers
- [`retrieve()`](https://ian-flores.github.io/securecontext/reference/retrieve.md)
  : Retrieve relevant chunks
- [`add_documents()`](https://ian-flores.github.io/securecontext/reference/add_documents.md)
  : Add documents to a retriever

## Context Building

- [`context_builder()`](https://ian-flores.github.io/securecontext/reference/context_builder.md)
  : Create a context builder
- [`securecontext_context_builder()`](https://ian-flores.github.io/securecontext/reference/securecontext_context_builder.md)
  : S7 class for securecontext context builders
- [`cb_add()`](https://ian-flores.github.io/securecontext/reference/cb_add.md)
  : Add content to a context builder
- [`cb_build()`](https://ian-flores.github.io/securecontext/reference/cb_build.md)
  : Build the context string
- [`cb_reset()`](https://ian-flores.github.io/securecontext/reference/cb_reset.md)
  : Reset a context builder

## Token Counting

- [`count_tokens()`](https://ian-flores.github.io/securecontext/reference/count_tokens.md)
  : Count tokens in text
- [`estimate_tokens()`](https://ian-flores.github.io/securecontext/reference/estimate_tokens.md)
  : Estimate token count

## Integration

- [`as_orchestr_memory()`](https://ian-flores.github.io/securecontext/reference/as_orchestr_memory.md)
  : Wrap knowledge store as orchestr-compatible memory
- [`context_for_chat()`](https://ian-flores.github.io/securecontext/reference/context_for_chat.md)
  : Build context for LLM chat
