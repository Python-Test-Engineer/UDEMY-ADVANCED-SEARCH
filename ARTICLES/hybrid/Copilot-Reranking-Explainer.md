Hybrid Search with Reranking Using BM25 and Vector Embeddings in PHP & MySQL (WordPress)

📖 Introduction

Information retrieval has traditionally relied on keyword-based search methods like BM25, which excel at matching exact terms but struggle with semantic meaning. Modern systems use vector embeddings to capture semantic similarity, enabling more natural search experiences. A hybrid search combines both approaches, and reranking ensures the most relevant results rise to the top.

🔎 BM25: Keyword-Based Search

BM25 is a ranking function used by search engines to evaluate relevance based on keyword frequency and document length.

Strengths:

Precise keyword matching

Efficient for large text corpora

Limitations:

Cannot capture semantic meaning (e.g., "car" vs. "automobile")

Icon: 📑 (represents keyword search)

🧠 Vector Embeddings: Semantic Search

Embeddings represent text as high-dimensional vectors.

Similarity is measured using cosine similarity or dot product.

Strengths:

Captures meaning beyond exact words

Handles synonyms and contextual similarity

Icon: 🧩 (represents semantic connections)

⚡ Hybrid Search: Combining BM25 and Embeddings

Hybrid search merges BM25 and vector search results:

BM25 Search → Retrieve keyword matches from MySQL (WordPress posts, pages, custom tables).

Vector Search → Retrieve semantically similar results using embeddings stored in a vector table.

Merge Results → Combine both sets into a unified candidate list.

Diagram:

[Query] → [BM25 in MySQL] → [Keyword Results]
       ↘ [Vector Embeddings Table] → [Semantic Results]

[Merge] → [Unified Candidate List]

Icon: 🔀 (represents merging results)

🔄 Reranking: Improving Result Quality

Reranking applies a secondary model to reorder results:

Input: Candidate list from BM25 + embeddings

Process: Score each result using a reranker (e.g., cross-encoder model)

Output: Optimized ranking list

Diagram:

[Unified Candidate List] → [Reranker Model] → [Final Ranked Results]

Icon: 📊 (represents ranking)

🛠️ Implementation in PHP & MySQL (WordPress)

Step 1: BM25 Search in MySQL

WordPress uses MySQL for content storage. BM25-like ranking can be approximated with MATCH() AGAINST in full-text search.

$query = "SELECT ID, post_title, post_content,
          MATCH(post_content) AGAINST(:search IN NATURAL LANGUAGE MODE) AS score
          FROM wp_posts
          WHERE MATCH(post_content) AGAINST(:search IN NATURAL LANGUAGE MODE)
          ORDER BY score DESC
          LIMIT 20";

Step 2: Vector Embeddings Table

Store embeddings in a custom table:

CREATE TABLE wp_embeddings (
  post_id BIGINT PRIMARY KEY,
  embedding VECTOR(768) -- Example dimension
);

Query embeddings with cosine similarity (requires plugin or external vector DB integration).

Step 3: Merge Results in PHP

$bm25_results = get_bm25_results($search);
$vector_results = get_vector_results($search_embedding);

$merged = array_merge($bm25_results, $vector_results);

Step 4: Reranking

Use a reranker model (via API or local inference) to rescore results:

foreach ($merged as $result) {
    $result['rerank_score'] = call_reranker_api($query, $result['content']);
}

usort($merged, function($a, $b) {
    return $b['rerank_score'] <=> $a['rerank_score'];
});

📚 Practical Example

Query: "eco-friendly cars"

BM25 finds posts with exact keywords "eco-friendly" and "cars".

Embeddings find posts about "green vehicles" or "electric automobiles".

Reranker prioritizes the most contextually relevant posts.

🖼️ Visual Summary

[User Query]
   ↓
[BM25 Search] + [Vector Search]
   ↓
[Merge Results]
   ↓
[Reranker]
   ↓
[Final Ranked Results]

Icons: 📑 BM25 | 🧩 Embeddings | 🔀 Merge | 📊 Rerank

✅ Key Takeaways

BM25 ensures precision, embeddings ensure semantic coverage.

Hybrid search combines both for balanced retrieval.

Reranking optimizes final results for user satisfaction.

PHP + MySQL (WordPress) can implement hybrid search with custom tables and external reranker APIs.

This document is course-ready and can be expanded with exercises, demos, and hands-on coding labs.