Below is a fully developed, polished, and comprehensive **Markdown document** you can use as the foundation for your *Advanced Search in WordPress* course. It’s structured like a professional course handout—clear, detailed, and designed to support both teaching and learning.

---

# **Advanced Search in WordPress — Complete Course Outline & Teaching Guide**

## 🎯 **Course Purpose**
This course equips WordPress developers with the knowledge and practical skills to build **fast, relevant, scalable, and modern search experiences**. It bridges the gap between WordPress’s default search and advanced Information Retrieval (IR) techniques used in modern applications.

Learners will progress from understanding WordPress’s built‑in search limitations to implementing **FTS, BM25, semantic search, embeddings, reranking, and RAG‑style hybrid systems**.

---

# **1. Introduction to Search in WordPress**

## 1.1 Why Search Matters
- Search is often the **highest‑intent** user action.
- Poor search leads to:
  - Lower conversions
  - Higher bounce rates
  - Poor UX
- Modern users expect:
  - Instant results
  - Typo tolerance
  - Semantic understanding
  - Personalization

## 1.2 WordPress Search: The Default Behavior
- Uses `WP_Query` with `s=` parameter.
- Performs a **simple `LIKE` match** on `wp_posts.post_title` and `post_content`.
- No ranking algorithm beyond basic relevance.
- No stemming, synonyms, typo correction, or semantic understanding.

## 1.3 Limitations of Default Search
- Slow on large datasets.
- No scoring model.
- No custom fields or taxonomies unless manually added.
- No fuzzy matching.
- No vector or semantic capabilities.

---

# **2. Understanding Information Retrieval (IR) Fundamentals**

## 2.1 What Is Information Retrieval?
- The science of finding relevant information from large collections.
- Core concepts:
  - Indexing
  - Tokenization
  - Ranking
  - Relevance feedback

## 2.2 Classical IR vs Modern IR
| Classical IR | Modern IR |
|--------------|-----------|
| Keyword-based | Meaning-based |
| TF-IDF, BM25 | Embeddings, Transformers |
| Exact match | Semantic similarity |
| Inverted index | Vector index |

## 2.3 Key IR Concepts Explained
- **Tokenization**: breaking text into searchable units.
- **Normalization**: lowercasing, removing punctuation.
- **Stemming/Lemmatization**.
- **Stopwords**.
- **Inverted Index**.
- **Ranking Functions**.

---

# **3. Improving WordPress Search with SQL & MySQL FTS**

## 3.1 What Is Full‑Text Search (FTS)?
- A MySQL feature enabling fast, ranked keyword search.
- Supports:
  - Boolean mode
  - Natural language mode
  - Query expansion

## 3.2 How FTS Works
- Builds an inverted index.
- Uses TF-IDF‑like scoring.
- Supports phrase matching and boolean operators.

## 3.3 Implementing FTS in WordPress
### Steps:
1. Add FULLTEXT indexes to:
   - `post_title`
   - `post_content`
   - Custom fields (optional)
2. Replace default `LIKE` queries with `MATCH() AGAINST()`.
3. Integrate with `pre_get_posts` or custom endpoints.

### Example: Adding FULLTEXT Index
```sql
ALTER TABLE wp_posts
ADD FULLTEXT fulltext_index (post_title, post_content);
```

### Example: Using MATCH() AGAINST()
```sql
SELECT ID, post_title,
MATCH(post_title, post_content) AGAINST ('search terms') AS score
FROM wp_posts
WHERE MATCH(post_title, post_content) AGAINST ('search terms' IN NATURAL LANGUAGE MODE)
ORDER BY score DESC;
```

## 3.4 Strengths & Weaknesses of FTS
### Strengths
- Fast
- Native to MySQL
- Good for keyword search

### Weaknesses
- No semantic understanding
- Limited typo tolerance
- No embeddings

---

# **4. Ranking Algorithms: TF‑IDF & BM25**

## 4.1 TF‑IDF Refresher
- Measures importance of a term in a document relative to the corpus.

## 4.2 BM25: The Modern Standard
- A probabilistic ranking function.
- Used by Elasticsearch, Solr, Meilisearch, Vespa, and others.

### Why BM25 Is Better
- Handles document length normalization.
- More robust scoring.
- Better relevance ranking.

## 4.3 Using BM25 in WordPress
- MySQL 8+ supports BM25‑style ranking via `IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION`.
- Or implement BM25 manually in PHP for custom scoring.

---

# **5. Custom Search Indexing in WordPress**

## 5.1 Why Build a Custom Index?
- Include custom fields
- Include taxonomies
- Include metadata
- Exclude irrelevant content
- Improve performance

## 5.2 Designing a Custom Search Table
Recommended schema:
```sql
CREATE TABLE wp_search_index (
  id BIGINT PRIMARY KEY,
  post_id BIGINT,
  title TEXT,
  content LONGTEXT,
  custom_data JSON,
  vector BLOB,
  updated_at DATETIME
);
```

## 5.3 Indexing Strategy
- Use cron jobs or action hooks.
- Normalize and clean text.
- Tokenize and store embeddings (if using semantic search).

---

# **6. Semantic Search in WordPress**

## 6.1 What Is Semantic Search?
- Search based on **meaning**, not keywords.
- Uses vector embeddings.

## 6.2 How Embeddings Work
- Convert text into high‑dimensional vectors.
- Similarity measured via cosine similarity.

## 6.3 Implementing Semantic Search
### Steps:
1. Generate embeddings for posts.
2. Store vectors in MySQL, SQLite, or a vector DB.
3. Generate embeddings for user queries.
4. Compute similarity.
5. Return top‑k results.

## 6.4 Vector Databases to Consider
- MySQL 8.0.36+ (native vector support)
- SQLite + pgvector-like extensions
- Qdrant
- Pinecone
- Weaviate

---

# **7. Hybrid Search: Combining Keyword + Semantic**

## 7.1 Why Hybrid Search?
- Keyword search handles:
  - Exact matches
  - Names
  - IDs
- Semantic search handles:
  - Concepts
  - Synonyms
  - Natural language queries

## 7.2 Reranking Pipeline
1. Retrieve candidates using FTS/BM25.
2. Generate embeddings for candidates.
3. Generate embedding for query.
4. Compute similarity.
5. Rerank results.

## 7.3 Benefits
- Faster than pure semantic search.
- More accurate than pure keyword search.

---

# **8. Building a Custom Search API in WordPress**

## 8.1 Why Use a Custom API?
- Decouple search from theme.
- Enable SPA/React/Vue frontends.
- Improve performance.

## 8.2 Designing the Endpoint
Example:
```
GET /wp-json/search/v1/query?q=...
```

## 8.3 Response Structure
```json
{
  "query": "search term",
  "results": [
    {
      "id": 123,
      "title": "Example",
      "score": 0.89,
      "excerpt": "..."
    }
  ]
}
```

---

# **9. Performance Optimization**

## 9.1 Caching Strategies
- Object cache
- Query caching
- Precomputed embeddings
- Prebuilt indexes

## 9.2 Pagination & Result Windows
- Use `LIMIT` and `OFFSET`.
- Avoid large offsets with deep pagination.

## 9.3 Scaling Search
- Offload to external search engines:
  - Elasticsearch
  - OpenSearch
  - Meilisearch
  - Algolia

---

# **10. UX & Frontend Search Experience**

## 10.1 Autocomplete & Instant Search
- Use AJAX or REST API.
- Debounce input.
- Show suggestions.

## 10.2 Faceted Search
- Filter by:
  - Categories
  - Tags
  - Custom taxonomies
  - Price ranges
  - Dates

## 10.3 Result Presentation
- Highlight matched terms.
- Provide excerpts.
- Show relevance scores (optional).

---

# **11. Security & Privacy Considerations**

## 11.1 Preventing Data Leaks
- Exclude private posts.
- Exclude sensitive metadata.

## 11.2 Rate Limiting Search
- Prevent abuse.
- Protect server resources.

## 11.3 Sanitizing Input
- Prevent SQL injection.
- Escape output.

---

# **12. Real‑World Examples & Case Studies**

## 12.1 E‑commerce Search
- Product attributes
- SKU search
- Fuzzy matching

## 12.2 Membership Sites
- Role‑based search
- Private content indexing

## 12.3 Large Content Sites
- News portals
- Documentation sites
- Knowledge bases

---

# **13. Capstone Project: Build a Full Hybrid Search System**

Students will:
1. Build a custom search index.
2. Implement FTS + BM25.
3. Add semantic embeddings.
4. Implement hybrid reranking.
5. Build a custom search API.
6. Build a modern search UI.

---

# **14. Additional Resources**

- MySQL FTS documentation
- BM25 academic papers
- Vector database documentation
- WordPress REST API handbook
- PHP performance best practices

---
