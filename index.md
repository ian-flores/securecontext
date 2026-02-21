# securecontext

> \[!CAUTION\] **Alpha software.** This package is part of a broader
> effort by [Ian Flores Siaca](https://github.com/ian-flores) to develop
> proper AI infrastructure for the R ecosystem. It is under active
> development and should **not** be used in production until an official
> release is published. APIs may change without notice.

Memory, knowledge persistence, RAG retrieval, and context management for
R LLM agents.

## Installation

``` r
# install.packages("pak")
pak::pak("ian-flores/securecontext")
```

## Features

- **Document chunking** – fixed-size, sentence, paragraph, and recursive
  strategies
- **TF-IDF embeddings** – local embeddings with no external API required
- **Vector store** – in-memory cosine similarity search with RDS
  persistence
- **Knowledge store** – persistent JSONL key-value storage
- **Semantic retrieval** – query documents by meaning
- **Context builder** – token-aware priority-based context assembly
- **Integration helpers** – works with orchestr and ellmer

## Quick start

``` r
library(securecontext)

# Create documents
docs <- list(
  document("R is great for statistics.", metadata = list(topic = "R")),
  document("Python excels at machine learning.", metadata = list(topic = "Python"))
)

# Build embeddings and index documents
emb <- embed_tfidf(vapply(docs, `[[`, character(1), "text"))
vs <- vector_store$new(dims = emb$dims)
ret <- retriever(vs, emb)
add_documents(ret, docs)

# Retrieve relevant context
result <- context_for_chat(ret, "statistical computing", max_tokens = 2000)
cat(result$context)
```

## License

MIT
