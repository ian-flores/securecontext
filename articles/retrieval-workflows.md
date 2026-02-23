# Retrieval Workflows

## Why Local Retrieval?

Retrieval-augmented generation (RAG) lets an LLM answer questions about
your own documents – internal reports, package documentation, domain
knowledge – by fetching relevant passages and injecting them into the
prompt. Most RAG tooling requires sending your documents to an external
embedding API, which introduces latency, cost, and privacy concerns.

securecontext takes a **local-first** approach. Its TF-IDF embedder runs
entirely in your R process: no API keys, no network calls, no data
leaving your machine. This makes it suitable for air-gapped
environments, privacy-sensitive workloads, and rapid prototyping where
you want results without configuring external services.

This vignette walks through the complete retrieval pipeline step by
step. Every operation – document creation, chunking, embedding, vector
search, knowledge storage, and context assembly – runs locally.

## The Full RAG Pipeline

The following diagram shows how data flows from raw documents to an
LLM-ready context string:

      Ingest                      Search                     Assemble
      ------                      ------                     --------
      document()                  retrieve()                 context_builder()
          |                           |                           |
          v                           v                           v
      chunk_text()              embed query               cb_add() per chunk
          |                      with TF-IDF                      |
          v                           |                           v
      embed_tfidf()              cosine similarity          cb_build()
          |                      against store                    |
          v                           |                           v
      vector_store$add()         ranked results             token-limited
                                                            context string

The left column (ingest) happens once when you load your corpus. The
middle column (search) runs on every query. The right column (assemble)
packs results into a token budget before sending to an LLM.

``` r
library(securecontext)
```

## Step 1: Create Documents

A
[`document()`](https://ian-flores.github.io/securecontext/reference/document.md)
wraps raw text with metadata and an auto-generated identifier. Metadata
travels with the document through the pipeline, making it easy to trace
which source a retrieved chunk came from. Documents are S7 objects, so
properties are accessed with `@`.

``` r
doc_r <- document(
  "R is a programming language for statistical computing and graphics.
It is widely used among statisticians and data scientists. R provides
a wide variety of statistical and graphical techniques, including
linear and nonlinear modelling, classical statistical tests, time-series
analysis, classification, and clustering.",
  metadata = list(source = "intro", topic = "R")
)

doc_python <- document(
  "Python is a high-level, general-purpose programming language.
Its design philosophy emphasizes code readability. Python supports
multiple programming paradigms, including structured, object-oriented,
and functional programming. It is often used for machine learning,
web development, and data analysis.",
  metadata = list(source = "intro", topic = "Python")
)

doc_julia <- document(
  "Julia is a high-level, high-performance programming language for
technical computing. It was designed for numerical analysis and
computational science. Julia features optional typing, multiple dispatch,
and good performance approaching that of statically-typed languages
like C and Fortran.",
  metadata = list(source = "intro", topic = "Julia")
)

# S7 property access with @
doc_r@id
#> [1] "doc_20260223024631_c6be45ee"
doc_r@metadata
#> $source
#> [1] "intro"
#> 
#> $topic
#> [1] "R"
```

## Step 2: Chunk Text

Chunking splits long text into smaller pieces suitable for embedding and
retrieval. Smaller, focused chunks improve search precision because the
embedder can match a query against a specific passage rather than an
entire document. The tradeoff is that very small chunks may lose
surrounding context.

securecontext offers four strategies:

| Strategy      | How it splits                             |
|:--------------|:------------------------------------------|
| `"sentence"`  | On sentence boundaries (`.` + space)      |
| `"paragraph"` | On double newlines                        |
| `"fixed"`     | Fixed character width with overlap        |
| `"recursive"` | Hierarchical separators (LangChain-style) |

### Choosing a Chunking Strategy

The right strategy depends on your content and how users will query it:

- **Sentence chunking** works best for narrative text (documentation,
  articles) where individual statements carry meaning. Queries like
  “What does dplyr do?” match well against single-sentence chunks.

- **Paragraph chunking** preserves more context per chunk, which helps
  when meaning spans multiple sentences. It works well for structured
  documents with clear paragraph breaks.

- **Fixed-size chunking** guarantees uniform chunk lengths, which is
  useful when downstream components expect consistent input sizes. The
  `overlap` parameter ensures that information near chunk boundaries is
  not lost.

- **Recursive chunking** is the most robust general-purpose strategy. It
  tries larger separators first (double newlines, then single newlines,
  then spaces, then characters), producing natural-looking chunks that
  respect document structure. This is a good default when you are
  unsure.

``` r
# Sentence-level chunking
sentences <- chunk_text(doc_r@text, strategy = "sentence")
cat("Sentence chunks:", length(sentences), "\n")
#> Sentence chunks: 3
sentences
#> [1] "R is a programming language for statistical computing and graphics."                                                                                                                               
#> [2] "It is widely used among statisticians and data scientists."                                                                                                                                        
#> [3] "R provides\na wide variety of statistical and graphical techniques, including\nlinear and nonlinear modelling, classical statistical tests, time-series\nanalysis, classification, and clustering."

# Recursive chunking with a small max_size to demonstrate splitting
small_chunks <- chunk_text(doc_r@text, strategy = "recursive", max_size = 120)
cat("\nRecursive chunks (max 120 chars):", length(small_chunks), "\n")
#> 
#> Recursive chunks (max 120 chars): 5
small_chunks
#> [1] "R is a programming language for statistical computing and graphics."     
#> [2] "It is widely used among statisticians and data scientists. R provides"   
#> [3] "a wide variety of statistical and graphical techniques, including"       
#> [4] "linear and nonlinear modelling, classical statistical tests, time-series"
#> [5] "analysis, classification, and clustering."
```

Fixed-size chunking is useful when you need consistent chunk lengths,
for example when working with models that expect uniform input sizes.
The `overlap` parameter creates a sliding window, ensuring that
information near chunk boundaries appears in both adjacent chunks:

``` r
long_text <- paste(
  "The tidyverse is a collection of R packages designed for data science.",
  "It includes ggplot2 for visualization, dplyr for data manipulation,",
  "tidyr for data tidying, readr for reading data, purrr for functional",
  "programming, tibble for modern data frames, stringr for string",
  "manipulation, and forcats for factor handling.",
  "All tidyverse packages share an underlying design philosophy,",
  "grammar, and data structures."
)

fixed_chunks <- chunk_fixed(long_text, size = 100, overlap = 20)
cat("Fixed chunks (size=100, overlap=20):", length(fixed_chunks), "\n\n")
#> Fixed chunks (size=100, overlap=20): 5
for (i in seq_along(fixed_chunks)) {
  cat(sprintf("Chunk %d (%d chars): %s\n\n", i, nchar(fixed_chunks[i]), fixed_chunks[i]))
}
#> Chunk 1 (100 chars): The tidyverse is a collection of R packages designed for data science. It includes ggplot2 for visua
#> 
#> Chunk 2 (100 chars): es ggplot2 for visualization, dplyr for data manipulation, tidyr for data tidying, readr for reading
#> 
#> Chunk 3 (100 chars): g, readr for reading data, purrr for functional programming, tibble for modern data frames, stringr 
#> 
#> Chunk 4 (100 chars): ata frames, stringr for string manipulation, and forcats for factor handling. All tidyverse packages
#> 
#> Chunk 5 (89 chars): l tidyverse packages share an underlying design philosophy, grammar, and data structures.
```

## Step 3: Build a TF-IDF Embedder

Embeddings are numerical representations of text that capture semantic
similarity. Texts about similar topics produce vectors that are close
together in the embedding space, enabling search by meaning rather than
exact keywords.

[`embed_tfidf()`](https://ian-flores.github.io/securecontext/reference/embed_tfidf.md)
builds a vocabulary from a corpus and returns an embedder that can
project new texts into that TF-IDF space. TF-IDF (Term Frequency-Inverse
Document Frequency) weighs words by how important they are to a specific
document relative to the corpus. Common words like “the” get low
weights; distinctive words like “regression” get high weights.

Everything runs locally – no API keys required.

``` r
# Gather all document texts as the training corpus
corpus <- c(doc_r@text, doc_python@text, doc_julia@text)

embedder <- embed_tfidf(corpus)

# The embedder is an S7 object; dims equals the vocabulary size
cat("Embedding dimensions:", embedder@dims, "\n")
#> Embedding dimensions: 79

# Embed a new query
query_matrix <- embed_texts(embedder, "statistical analysis in R")
cat("Query embedding shape:", nrow(query_matrix), "x", ncol(query_matrix), "\n")
#> Query embedding shape: 1 x 79
```

## Step 4: Vector Store

The `vector_store` is an R6 class providing in-memory cosine-similarity
search with optional RDS persistence. It stores embedding vectors keyed
by ID and retrieves the closest matches to a query vector. Since it is
R6, use `$` for method access.

Cosine similarity measures the angle between two vectors, ignoring
magnitude. A score of 1.0 means identical direction (maximum
similarity); 0.0 means orthogonal (no similarity).

``` r
vs <- vector_store$new(dims = embedder@dims)

# Embed and store each document manually
ids <- c("r", "python", "julia")
embeddings <- embed_texts(embedder, corpus)
vs$add(ids, embeddings)

cat("Store size:", vs$size(), "vectors\n")
#> Store size: 3 vectors

# Search for the closest match to a query
query_emb <- embed_texts(embedder, "data science and statistics")
results <- vs$search(query_emb, k = 3)
print(results)
#>       id      score
#> 1 python 0.07428944
#> 2      r 0.06359400
#> 3  julia 0.00000000
```

Persistence is straightforward with `$save()` and `$load()`. This lets
you build an embedding index once and reuse it across R sessions without
re-embedding your corpus:

``` r
tmp <- tempfile(fileext = ".rds")
vs$save(tmp)

vs2 <- vector_store$new(dims = embedder@dims)
vs2$load(tmp)
cat("Loaded store size:", vs2$size(), "\n")
#> Loaded store size: 3

# Clean up
unlink(tmp)
```

## Step 5: Retriever – the High-Level Interface

The previous steps (chunk, embed, store, search) are the building
blocks. The
[`retriever()`](https://ian-flores.github.io/securecontext/reference/retriever.md)
combines a vector store and an embedder into a single object that
handles the full ingest-and-search workflow. Use
[`add_documents()`](https://ian-flores.github.io/securecontext/reference/add_documents.md)
to chunk, embed, and store documents in one call, then
[`retrieve()`](https://ian-flores.github.io/securecontext/reference/retrieve.md)
to search.

This is the recommended interface for most applications – it reduces
boilerplate and ensures that chunking and embedding are consistent
between ingest and query time.

``` r
# Fresh store for the retriever
vs_ret <- vector_store$new(dims = embedder@dims)
ret <- retriever(vs_ret, embedder)

# add_documents handles chunking + embedding internally
docs <- list(doc_r, doc_python, doc_julia)
add_documents(ret, docs, chunk_strategy = "sentence")

cat("Chunks in store:", vs_ret$size(), "\n\n")
#> Chunks in store: 10

# Retrieve the top 3 chunks for a query
hits <- retrieve(ret, "machine learning", k = 3)
print(hits)
#>                                    id     score
#> 1 doc_20260223024631_e35844e7_chunk_4 0.3992843
#> 2 doc_20260223024631_c6be45ee_chunk_1 0.0000000
#> 3 doc_20260223024631_c6be45ee_chunk_2 0.0000000
```

The returned data frame contains chunk IDs and cosine similarity scores.
Higher scores indicate greater relevance. You can use these scores
directly as priorities in the context builder (see
[`vignette("context-building")`](https://ian-flores.github.io/securecontext/articles/context-building.md)).

## Step 6: Knowledge Store

The `knowledge_store` is an R6 class providing persistent key-value
storage backed by JSONL. While the vector store is optimized for
similarity search over embeddings, the knowledge store is designed for
structured data you look up by key: agent memory, user preferences,
session history, learned facts.

The JSONL format (one JSON object per line) makes the store
append-friendly and human-readable. Data persists across R sessions
automatically.

``` r
ks <- knowledge_store$new(path = tempfile(fileext = ".jsonl"))

# Store some facts
ks$set("lang.r", list(type = "statistical", year = 1993))
ks$set("lang.python", list(type = "general-purpose", year = 1991))
ks$set("lang.julia", list(type = "numerical", year = 2012))
ks$set("user.preference", "R")

cat("Total entries:", ks$size(), "\n")
#> Total entries: 4

# Retrieve a value
ks$get("lang.r")
#> $type
#> [1] "statistical"
#> 
#> $year
#> [1] 1993

# Search keys by regex
ks$search("^lang")
#> [1] "lang.r"      "lang.python" "lang.julia"

# List all keys
ks$list()
#> [1] "lang.r"          "lang.python"     "lang.julia"      "user.preference"

# Clean up
unlink(ks$.__enclos_env__$private$.path)
```

## Step 7: Context Builder

The
[`context_builder()`](https://ian-flores.github.io/securecontext/reference/context_builder.md)
assembles a token-limited context string from multiple sources,
prioritizing the most important content. This is the final step before
sending context to an LLM – it ensures you stay within the model’s
context window while including the most relevant information.

For a deep dive into priority strategies, overflow behavior, and
multi-turn patterns, see
[`vignette("context-building")`](https://ian-flores.github.io/securecontext/articles/context-building.md).

``` r
cb <- context_builder(max_tokens = 100)

# Add content with different priorities (higher = included first)
cb <- cb_add(cb, "You are a helpful assistant.", priority = 10, label = "system")
cb <- cb_add(cb,
  "R is great for statistics and data visualization.",
  priority = 5, label = "retrieved_chunk_1"
)
cb <- cb_add(cb,
  "Python is popular for machine learning and web development.",
  priority = 4, label = "retrieved_chunk_2"
)
cb <- cb_add(cb,
  "Julia offers high performance for numerical computing workloads.",
  priority = 3, label = "retrieved_chunk_3"
)

result <- cb_build(cb)

cat("Assembled context:\n")
#> Assembled context:
cat(result$context, "\n\n")
#> You are a helpful assistant.
#> 
#> R is great for statistics and data visualization.
#> 
#> Python is popular for machine learning and web development.
#> 
#> Julia offers high performance for numerical computing workloads.
cat("Included:", paste(result$included, collapse = ", "), "\n")
#> Included: system, retrieved_chunk_1, retrieved_chunk_2, retrieved_chunk_3
cat("Excluded:", paste(result$excluded, collapse = ", "), "\n")
#> Excluded:
cat("Total tokens:", result$total_tokens, "\n")
#> Total tokens: 41
```

The builder processes items in priority order and stops adding when the
token budget is exhausted. Items that do not fit are reported in
`$excluded`, making it easy to log what was dropped.

Use
[`cb_reset()`](https://ian-flores.github.io/securecontext/reference/cb_reset.md)
to clear all items and reuse the same builder with a new turn of
conversation:

``` r
cb2 <- cb_reset(cb)
cb2 <- cb_add(cb2, "New system prompt.", priority = 10, label = "system_v2")
result2 <- cb_build(cb2)
cat("After reset -- included:", paste(result2$included, collapse = ", "), "\n")
#> After reset -- included: system_v2
```

## Full Pipeline: Retrieve and Build Context

[`context_for_chat()`](https://ian-flores.github.io/securecontext/reference/context_for_chat.md)
combines retrieval and context building in a single call. Given a
retriever and a query, it retrieves the top-k chunks and packs them into
a token-limited context string. This is the typical integration point
for an agent: retrieve relevant information, assemble a context window,
and pass it to an LLM provider.

``` r
context_result <- context_for_chat(ret, "statistical computing", max_tokens = 2000, k = 5)

cat("Context for LLM:\n")
#> Context for LLM:
cat(context_result$context, "\n\n")
#> R is a programming language for statistical computing and graphics.
#> 
#> R provides
#> a wide variety of statistical and graphical techniques, including
#> linear and nonlinear modelling, classical statistical tests, time-series
#> analysis, classification, and clustering.
#> 
#> It is widely used among statisticians and data scientists.
#> 
#> Python is a high-level, general-purpose programming language.
#> 
#> Its design philosophy emphasizes code readability.
cat("Included chunks:", length(context_result$included), "\n")
#> Included chunks: 5
cat("Total tokens:", context_result$total_tokens, "\n")
#> Total tokens: 73
```

## Summary

The securecontext retrieval pipeline follows these steps:

1.  **[`document()`](https://ian-flores.github.io/securecontext/reference/document.md)**
    – wrap text with metadata
2.  **[`chunk_text()`](https://ian-flores.github.io/securecontext/reference/chunk_text.md)**
    – split into retrieval units
3.  **[`embed_tfidf()`](https://ian-flores.github.io/securecontext/reference/embed_tfidf.md)**
    – build a local embedder from a corpus
4.  **`vector_store$new()`** – store and search embeddings
5.  **[`retriever()`](https://ian-flores.github.io/securecontext/reference/retriever.md)** +
    **[`add_documents()`](https://ian-flores.github.io/securecontext/reference/add_documents.md)**
    – high-level ingest
6.  **[`retrieve()`](https://ian-flores.github.io/securecontext/reference/retrieve.md)**
    – semantic search
7.  **`knowledge_store$new()`** – persistent key-value memory
8.  **[`context_builder()`](https://ian-flores.github.io/securecontext/reference/context_builder.md)** +
    **[`cb_add()`](https://ian-flores.github.io/securecontext/reference/cb_add.md)** +
    **[`cb_build()`](https://ian-flores.github.io/securecontext/reference/cb_build.md)**
    – token-aware assembly
9.  **[`context_for_chat()`](https://ian-flores.github.io/securecontext/reference/context_for_chat.md)**
    – one-call retrieve-and-build

For more on context building strategies, see
[`vignette("context-building")`](https://ian-flores.github.io/securecontext/articles/context-building.md).
To wire retrieval into orchestr agent graphs, see
[`vignette("orchestr-integration")`](https://ian-flores.github.io/securecontext/articles/orchestr-integration.md).
