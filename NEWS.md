# securecontext 0.2.0

## New public API

* `vector_store$metadata(id)` and `vector_store$ids()` accessors for
  safely inspecting store contents without reaching into R6 privates.
* `knowledge_store$get_metadata(key)` accessor for retrieving the
  metadata list attached to a key.
* `embed_custom(fn, dims, name)` — generic adapter that wraps any
  function producing `n x dims` embedding matrices as a
  `securecontext_embedder`.
* `embed_openai(model, dims, api_key, ...)` — convenience embedder that
  calls the OpenAI `/v1/embeddings` endpoint via `httr2` (Suggests).

## Fixes

* `context_for_chat()` no longer reaches into R6 private fields
  (`..__enclos_env__$private$.metadata`) to pull chunk text; it now uses
  the new public `vector_store$metadata()` accessor.

## Notes on embedding coverage

* ellmer does not currently expose embeddings, so there is no
  `embed_ellmer()`. Build on `embed_custom()` if you need to route
  through a different SDK.

# securecontext 0.1.0

* Initial CRAN release.
* S7-based `securecontext_document` class for representing text documents with
  metadata.
* `chunk_text()` for splitting documents into overlapping chunks by token count.
* TF-IDF embedder (`embed_tfidf()`) for local, dependency-free text embeddings.
* `vector_store` R6 class with cosine similarity search and RDS persistence.
* `knowledge_store` R6 class for persistent JSONL key-value storage.
* `context_builder` for token-aware, priority-based context assembly.
* `count_tokens()` utility using word-based approximation.
* Optional integration with 'ellmer' and 'orchestr' for LLM agent workflows.
