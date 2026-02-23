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
