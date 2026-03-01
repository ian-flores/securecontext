# Getting Started with securecontext

## What is securecontext?

Large language models only know what they were trained on. When you need
an LLM to answer questions about *your* documents (internal reports,
package documentation, domain-specific knowledge), you feed that
information into the model’s context window. This pattern is called
Retrieval-Augmented Generation (RAG).

securecontext implements a complete, local-first RAG pipeline for R.
Every component (chunking, embedding, vector search, and context
assembly) runs entirely on your machine with no external API calls. Your
documents never leave your environment.

The package is also token-aware. LLMs have finite context windows, and
naively stuffing retrieved text into a prompt wastes tokens or overflows
the limit. securecontext’s context builder packs the most important
information first under a priority-based budget and reports what was
included and what was dropped.

## The RAG pipeline at a glance

The following diagram shows the end-to-end flow from raw documents to an
LLM-ready context string:

     Documents     Chunk        Embed       Store        Query       Context     LLM
     ---------    -------      -------     -------      -------     ---------   -----
     |  doc  | -> | sent | ->  | TF- | ->  | vec | <-   | "my  | -> | token | -> | R |
     | text  |    | para |     | IDF |     | tor |      | query|    | aware |    |   |
     |       |    | rec  |     |     |     | str |      |      |    | build |    |   |
     ---------    -------      -------     -------      -------     ---------   -----
     document()  chunk_text() embed_tfidf  vector_store retrieve()  context_    chat()
                               ()          $new()                   builder()

Each step is independently useful, but they compose naturally into a
pipeline. The sections below cover three building blocks: documents,
chunking, and the knowledge store. For the full retrieval pipeline, see
[`vignette("retrieval-workflows")`](https://ian-flores.github.io/securecontext/articles/retrieval-workflows.md).

## Documents and chunking

The
[`document()`](https://ian-flores.github.io/securecontext/reference/document.md)
function wraps raw text with metadata and an auto-generated identifier.
Documents are the unit of ingestion throughout the package.

Chunking splits long text into smaller pieces suitable for embedding and
retrieval. Smaller chunks improve search precision because the embedder
can match a query against focused passages rather than entire documents.

securecontext ships four chunking strategies, each suited to different
content types:

| Strategy      | How it splits                             | Best for                   |
|:--------------|:------------------------------------------|:---------------------------|
| `"sentence"`  | On sentence boundaries (`.` + space)      | Prose, documentation       |
| `"paragraph"` | On double newlines                        | Structured reports         |
| `"fixed"`     | Fixed character width with overlap        | Uniform input requirements |
| `"recursive"` | Hierarchical separators (LangChain-style) | Mixed content              |

``` r
library(securecontext)

doc <- document(
  "R is a language for statistical computing. It has many packages for data
analysis. The tidyverse is a popular collection of packages.",
  metadata = list(source = "intro")
)

# Different chunking strategies
chunks_sent <- chunk_text(doc$text, strategy = "sentence")
chunks_para <- chunk_text(doc$text, strategy = "paragraph")
chunks_rec  <- chunk_text(doc$text, strategy = "recursive", max_size = 50)
```

The choice of strategy depends on your content. Sentence chunking works
well for narrative text where individual statements carry meaning.
Recursive chunking is more robust for mixed content because it tries
larger separators first (double newlines, then single newlines, then
spaces) before falling back to character splits.

## Knowledge store

The `knowledge_store` is a persistent key-value store backed by a JSONL
file. Unlike the vector store (which is optimized for similarity
search), the knowledge store holds structured facts that you look up by
key: user preferences, session state, agent memory. Stored data survives
across R sessions, making it suitable for agents that need durable
memory.

``` r
ks <- knowledge_store$new(path = tempfile(fileext = ".jsonl"))

ks$set("user.name", "Alice")
ks$set("user.preferences", list(theme = "dark", lang = "R"))

ks$get("user.name")
ks$search("^user")
```

Keys are plain strings, and values can be any R object that `jsonlite`
can serialize (lists, vectors, data frames). The `$search()` method
accepts a regular expression pattern to find keys by prefix or pattern.

## Next steps

With documents, chunking strategies, and the knowledge store in place,
the rest of the securecontext documentation covers the full pipeline:

- [`vignette("retrieval-workflows")`](https://ian-flores.github.io/securecontext/articles/retrieval-workflows.md):
  Build a complete RAG pipeline with TF-IDF embeddings, vector search,
  retrievers, and the
  [`context_for_chat()`](https://ian-flores.github.io/securecontext/reference/context_for_chat.md)
  convenience function.
- [`vignette("context-building")`](https://ian-flores.github.io/securecontext/articles/context-building.md):
  The token-aware context builder in depth, covering priority budgets,
  overflow behavior, and multi-source assembly.
- [`vignette("orchestr-integration")`](https://ian-flores.github.io/securecontext/articles/orchestr-integration.md):
  Wire retrieval into orchestr agent graphs with the memory adapter and
  retrieve-then-generate patterns.
