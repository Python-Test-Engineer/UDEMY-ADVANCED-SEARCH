Below is a complete, polished **lecture-style Markdown document** you can deliver directly to your students. It includes:

- Clear explanations of the three MySQL Full‑Text Search modes  
- Five custom 30–50‑word sample documents (original, not copyrighted)  
- Example SQL queries for **Natural Language**, **Boolean**, and **Query Expansion** modes  
- Commentary on how each mode behaves  

---

# **Lecture: Types of Full‑Text Search in WordPress / MySQL**

## 🎯 **Learning Objectives**
By the end of this lecture, students will understand:

- How MySQL Full‑Text Search works in WordPress  
- The differences between **Natural Language**, **Boolean**, and **Query Expansion** modes  
- How to run each mode using `MATCH() AGAINST()`  
- How search results differ depending on the mode  

---

# **1. Introduction to Full‑Text Search in WordPress**

WordPress uses MySQL as its database engine, and MySQL provides a built‑in **Full‑Text Search (FTS)** system. When you add a FULLTEXT index to columns like `post_title` and `post_content`, you unlock powerful search capabilities far beyond the default `LIKE '%keyword%'` approach.

MySQL supports **three major FTS modes**:

1. **Natural Language Mode**  
2. **Boolean Mode**  
3. **Query Expansion Mode**

Each mode interprets queries differently and produces different ranking behavior.

---

# **2. Sample Documents (Used in All Examples)**

These five documents simulate WordPress posts. Each is **30–50 words**, original, and crafted to highlight differences between search modes.

### **Document 1**
A beginner‑friendly guide explaining how to improve WordPress performance using caching plugins, optimized images, and database cleanup. It focuses on practical steps that help small business owners speed up their websites without needing advanced technical knowledge.

### **Document 2**
An article comparing different WordPress search plugins, including their indexing methods, relevance scoring, and support for custom fields. It highlights how Full‑Text Search and external engines like Elasticsearch improve accuracy and user experience.

### **Document 3**
A tutorial showing how to build a custom search page in WordPress using WP_Query, meta queries, and taxonomy filters. It explains why default search is limited and how developers can enhance it with SQL‑based Full‑Text Search.

### **Document 4**
A case study describing how an online store improved product discovery by combining keyword search with semantic suggestions. It discusses synonyms, related terms, and how customers often search using natural language rather than exact product names.

### **Document 5**
A technical deep dive into MySQL Full‑Text Search modes, including Natural Language, Boolean, and Query Expansion. It explains how MATCH() AGAINST() works, how relevance scores are calculated, and when developers should use each mode.

---

# **3. Natural Language Mode**

## **How It Works**
- MySQL analyzes the query as normal human language.  
- It calculates relevance using TF‑IDF‑style scoring.  
- No operators (`+`, `-`, `" "`, `*`) are allowed.  
- Best for general‑purpose search.

## **Example Query**
Search for: **wordpress search**

```sql
SELECT id, title,
       MATCH(title, content) AGAINST ('wordpress search' IN NATURAL LANGUAGE MODE) AS score
FROM wp_posts
ORDER BY score DESC;
```

## **Expected Behavior**
- Documents 2, 3, and 5 will rank highest because they contain both “WordPress” and “search” in meaningful contexts.  
- Document 1 may rank lower because it mentions WordPress but not search.  
- Document 4 may rank even lower because it focuses on product discovery, not WordPress.

---

# **4. Boolean Mode**

## **How It Works**
Boolean mode allows operators:

| Operator | Meaning |
|---------|---------|
| `+` | Term must be present |
| `-` | Term must NOT be present |
| `"` | Exact phrase |
| `*` | Wildcard |
| `>` `<` | Increase/decrease relevance |
| `()` | Group terms |

## **Example Query**
Search for posts that **must include “WordPress”**, **must include “search”**, and **must NOT include “Elasticsearch”**:

```sql
SELECT id, title,
       MATCH(title, content) AGAINST ('+wordpress +search -elasticsearch' IN BOOLEAN MODE) AS score
FROM wp_posts
ORDER BY score DESC;
```

## **Expected Behavior**
- Document 2 mentions Elasticsearch → **excluded**  
- Documents 3 and 5 match strongly  
- Document 1 is excluded because it doesn’t mention “search”  
- Document 4 is excluded because it doesn’t mention WordPress  

Boolean mode gives you **precise control** over what appears.

---

# **5. Query Expansion Mode**

## **How It Works**
Query Expansion performs a **two‑step process**:

1. MySQL runs a Natural Language search.  
2. It analyzes the top results and extracts additional related terms.  
3. It reruns the search with the expanded query.

This can surface **semantically related** documents.

## **Example Query**
Search for: **search**

```sql
SELECT id, title,
       MATCH(title, content) AGAINST ('search' WITH QUERY EXPANSION) AS score
FROM wp_posts
ORDER BY score DESC;
```

## **Expected Behavior**
- Document 2, 3, and 5 will rank high because they contain “search.”  
- Document 4 may rank higher than expected because it discusses **product discovery**, **synonyms**, and **natural language**, which MySQL may treat as related concepts.  
- Document 1 may still rank low because it lacks search‑related vocabulary.

Query Expansion is useful when users type **very short or vague queries**.

---

# **6. Summary Table**

| Mode | Best For | Allows Operators | Behavior |
|------|----------|------------------|----------|
| **Natural Language** | General search | ❌ No | Ranks by relevance using TF‑IDF |
| **Boolean** | Precision control | ✅ Yes | Must‑include, must‑exclude, wildcards |
| **Query Expansion** | Vague queries | ❌ No | Adds related terms automatically |

---

# **7. How This Applies to WordPress**

In WordPress, you can integrate these modes by:

- Adding FULLTEXT indexes to `wp_posts`  
- Using `pre_get_posts` filters  
- Creating custom SQL queries via `$wpdb`  
- Building custom search endpoints in the REST API  

This gives you far more control than the default search system.

---
