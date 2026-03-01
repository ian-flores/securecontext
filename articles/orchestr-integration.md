# RAG-Enabled Agents

## Why integrate retrieval with orchestration?

An LLM agent that retrieves information from a knowledge base before
answering can ground its responses in your documents rather than relying
on training data alone. But retrieval alone is not enough – you also
need to decide *when* to retrieve, *how much* context to include, and
*where* to store what the agent learns. These are orchestration
concerns.

securecontext handles document ingestion, embedding, vector search, and
token-aware context assembly. orchestr defines agent workflows as
directed graphs, manages state between nodes, and routes execution.
Together, they let you build RAG agents where retrieval is an explicit
graph node with its own inputs, outputs, and tests.

The sections below connect the two packages using the memory adapter
pattern and graph-based retrieve-then-generate workflows.

For securecontext basics, see
[`vignette("securecontext")`](https://ian-flores.github.io/securecontext/articles/securecontext.md)
and
[`vignette("retrieval-workflows")`](https://ian-flores.github.io/securecontext/articles/retrieval-workflows.md).
For orchestr basics, see
[`vignette("quickstart", package = "orchestr")`](https://ian-flores.github.io/orchestr/articles/quickstart.html).

## Building a knowledge base

Start by creating documents, chunking them, and loading them into a
retriever. This is the same pipeline from
[`vignette("retrieval-workflows")`](https://ian-flores.github.io/securecontext/articles/retrieval-workflows.md),
repeated here for completeness. Everything runs locally; no external API
calls required.

``` r
library(securecontext)
library(orchestr)
library(ellmer)

# Create documents from your corpus
docs <- list(
  document("R provides extensive facilities for statistical computing
and graphics. Linear models, time-series analysis, classification, and
clustering are all available out of the box.",
    metadata = list(source = "r-intro", topic = "statistics")),
  document("The tidyverse is a collection of R packages for data science.
Core packages include ggplot2, dplyr, tidyr, readr, and purrr.",
    metadata = list(source = "r-intro", topic = "tidyverse")),
  document("Shiny is an R package for building interactive web applications.
It combines R's analytical power with modern web UI components.",
    metadata = list(source = "r-intro", topic = "shiny"))
)

# Build embedder from the corpus
corpus <- vapply(docs, function(d) d@text, character(1))
embedder <- embed_tfidf(corpus)

# Create vector store and retriever
vs <- vector_store$new(dims = embedder@dims)
ret <- retriever(vs, embedder)
add_documents(ret, docs, chunk_strategy = "sentence")
```

## The `as_orchestr_memory()` adapter

orchestr agents expect a memory backend with
[`get()`](https://rdrr.io/r/base/get.html) and `set()` methods.
securecontext’s `knowledge_store` provides persistent key-value storage
backed by JSONL, but its interface does not match what orchestr expects
out of the box. The
[`as_orchestr_memory()`](https://ian-flores.github.io/securecontext/reference/as_orchestr_memory.md)
function bridges this gap.

The adapter pattern is simple: wrap a securecontext object in a thin
layer that exposes the interface another package expects. The underlying
storage, persistence, and search capabilities of the knowledge store are
fully preserved; the adapter just translates method calls.

``` r
# Create a persistent knowledge store
ks <- knowledge_store$new(path = "agent-memory.jsonl")

# Wrap it for orchestr
mem <- as_orchestr_memory(ks)

# The adapter exposes get/set -- the same interface orchestr expects
mem$set("user.name", "Alice")
mem$set("session.topic", "data analysis")
mem$get("user.name")
#> [1] "Alice"
```

The underlying JSONL file persists across R sessions, so agent memory
survives restarts. You can also access the knowledge store directly (via
`ks`) to use features like `$search()` and `$list()` that are not part
of the orchestr memory interface.

## Retrieval-in-the-loop graph

The core RAG pattern is: retrieve relevant context before each LLM call.
With orchestr’s
[`graph_builder()`](https://ian-flores.github.io/orchestr/reference/graph_builder.html),
you wire this as a two-node graph: a retrieval node followed by an agent
node.

The following diagram shows the flow:

      +----------+      +---------+      +-----+
      | retrieve | ---> |  agent  | ---> | END |
      +----------+      +---------+      +-----+
           |                  |
      Searches vector    Uses retrieved
      store, builds      context to
      token-limited      answer query
      context string     via LLM

The retrieval node runs the securecontext pipeline (retrieve + context
build). The agent node takes that context and passes it to an LLM
alongside the user’s question. By separating these concerns into
distinct graph nodes, each step is independently testable and
replaceable.

``` r
# Node 1: retrieve relevant chunks and build context
retrieve_node <- function(state, config) {
  query <- state$messages[[length(state$messages)]]

  # Retrieve and assemble token-limited context
  result <- context_for_chat(ret, query, max_tokens = 2000, k = 5)

  list(context = result$context)
}

# Node 2: LLM agent that uses the retrieved context
agent_node <- function(state, config) {
  context <- state$context %||% ""
  query <- state$messages[[length(state$messages)]]

  prompt <- paste0(
    "Use the following context to answer the question.\n\n",
    "Context:\n", context, "\n\n",
    "Question: ", query
  )

  chat <- chat_anthropic(system_prompt = "You are a helpful R assistant.")
  response <- chat$chat(prompt)

  list(messages = list(response))
}

# Wire the graph: retrieve -> agent -> END
schema <- state_schema(
  messages = "append:list",
  context = "character"
)

graph <- graph_builder(state_schema = schema)
graph$add_node("retrieve", retrieve_node)
graph$add_node("agent", agent_node)
graph$add_edge("retrieve", "agent")
graph$add_edge("agent", END)
graph$set_entry_point("retrieve")

rag_graph <- graph$compile()

# Run it
result <- rag_graph$invoke(list(
  messages = list("What packages are in the tidyverse?")
))
```

Every user query first passes through the retrieval node, which searches
the vector store and assembles a context string. The agent node then
answers using that context. Because the context builder enforces a token
budget, the agent node always receives a prompt that fits within the
model’s context window.

## Token budget management

When your knowledge base is large, retrieved chunks may exceed the LLM’s
context window. The
[`context_builder()`](https://ian-flores.github.io/securecontext/reference/context_builder.md)
controls this with a token budget and priorities. For a detailed
treatment of priority strategies and overflow behavior, see
[`vignette("context-building")`](https://ian-flores.github.io/securecontext/articles/context-building.md).

Here is a practical example using retrieval scores as priorities:

``` r
cb <- context_builder(max_tokens = 500)

# System prompt gets highest priority -- always included
cb <- cb_add(cb, "You are an R expert.", priority = 10, label = "system")

# Retrieved chunks get decreasing priority by relevance score
hits <- retrieve(ret, "statistical models", k = 5)
for (i in seq_len(nrow(hits))) {
  chunk_text <- hits$id[i]  # or look up the original text
  cb <- cb_add(cb, chunk_text, priority = hits$score[i], label = hits$id[i])
}

result <- cb_build(cb)
cat("Included:", paste(result$included, collapse = ", "), "\n")
cat("Excluded:", paste(result$excluded, collapse = ", "), "\n")
cat("Total tokens:", result$total_tokens, "\n")
```

The builder packs items in priority order until the budget is exhausted.
Dropped items are reported in `$excluded`, so you can log what was cut.

Use
[`cb_reset()`](https://ian-flores.github.io/securecontext/reference/cb_reset.md)
between turns to reuse the same builder:

``` r
cb <- cb_reset(cb)
# Now add fresh content for the next turn
```

## Persistent knowledge store

For agents that need memory across sessions, `knowledge_store` persists
to a JSONL file. Combined with the orchestr memory adapter, this gives
agents durable recall: the agent remembers user preferences, past
queries, and learned facts across restarts.

``` r
# Knowledge store persists to disk
ks <- knowledge_store$new(path = "long-term-memory.jsonl")

# Store structured facts
ks$set("user.preference", list(language = "R", theme = "dark"))
ks$set("session.2025-01-15", list(
  topic = "regression models",
  outcome = "built linear model for mtcars"
))

# Search by key pattern
ks$search("^session")
#> $`session.2025-01-15`
#> $`session.2025-01-15`$topic
#> [1] "regression models"

# Use in an orchestr agent via the adapter
mem <- as_orchestr_memory(ks)
```

## Putting it all together

Here is a complete RAG agent that combines retrieval, token management,
and persistent memory in an orchestr graph. Documents are ingested into
a local vector store, queries trigger retrieval and context assembly,
the LLM answers using grounded context, and the agent persists what it
learns for future sessions.

``` r
library(securecontext)
library(orchestr)
library(ellmer)

# --- Knowledge base ---
docs <- list(
  document("dplyr provides a grammar of data manipulation with verbs
like filter, select, mutate, summarise, and arrange."),
  document("ggplot2 implements the grammar of graphics. Build plots
layer by layer with aes(), geom_point(), geom_line(), and facet_wrap()."),
  document("tidyr helps tidy data with pivot_longer, pivot_wider,
separate, and unite.")
)

corpus <- vapply(docs, function(d) d@text, character(1))
embedder <- embed_tfidf(corpus)
vs <- vector_store$new(dims = embedder@dims)
ret <- retriever(vs, embedder)
add_documents(ret, docs, chunk_strategy = "sentence")

# --- Persistent memory ---
ks <- knowledge_store$new(path = tempfile(fileext = ".jsonl"))
mem <- as_orchestr_memory(ks)

# --- Graph nodes ---
retrieve_node <- function(state, config) {
  query <- state$messages[[length(state$messages)]]
  result <- context_for_chat(ret, query, max_tokens = 1500, k = 3)
  list(context = result$context)
}

agent_node <- function(state, config) {
  context <- state$context %||% ""
  query <- state$messages[[length(state$messages)]]

  prompt <- paste0("Context:\n", context, "\n\nQuestion: ", query)
  chat <- chat_anthropic(
    system_prompt = "Answer questions about R packages using the provided context."
  )
  response <- chat$chat(prompt)

  # Persist what we learned
  mem$set(paste0("query.", Sys.time()), query)

  list(messages = list(response))
}

# --- Build and run ---
schema <- state_schema(messages = "append:list", context = "character")
g <- graph_builder(state_schema = schema)
g$add_node("retrieve", retrieve_node)
g$add_node("agent", agent_node)
g$add_edge("retrieve", "agent")
g$add_edge("agent", END)
g$set_entry_point("retrieve")

rag <- g$compile()
result <- rag$invoke(list(
  messages = list("How do I reshape data from wide to long format?")
))
```

The retrieval node finds chunks about tidyr’s `pivot_longer`, the
context builder fits them within the token budget, and the agent answers
using that grounded context. The query is also persisted to the
knowledge store for future reference.
