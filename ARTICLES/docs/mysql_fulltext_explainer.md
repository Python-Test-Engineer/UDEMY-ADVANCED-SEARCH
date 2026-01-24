# 🔍 MySQL Full-Text Search - Complete Guide

## What is MySQL Full-Text Search?

MySQL Full-Text Search lets you search through text columns **FAST** without using slow `LIKE` queries!

### The Problem with LIKE:

```sql
-- Slow query (scans entire table!) 🐌
SELECT * FROM articles 
WHERE content LIKE '%machine learning%';

Time: 5 seconds for 1 million rows ❌
Cannot use indexes efficiently
```

### The Solution: Full-Text Search

```sql
-- Fast query (uses full-text index!) ⚡
SELECT * FROM articles 
WHERE MATCH(content) AGAINST('machine learning');

Time: 0.05 seconds for 1 million rows ✅
Uses specialized full-text indexes
```

**Speed improvement: 100x faster!** 🚀

---

## 📚 Three Types of Full-Text Search in MySQL

MySQL offers **3 different search modes**, each with unique capabilities:

```
┌─────────────────────────────────────────────────┐
│  1. NATURAL LANGUAGE MODE (Default)             │
│     - Simple, relevance-based search            │
│     - Like Google search                        │
│     - Most commonly used                        │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  2. BOOLEAN MODE                                │
│     - Advanced operators (+, -, *, "")          │
│     - Precise control over search               │
│     - Like advanced Google operators            │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  3. QUERY EXPANSION MODE                        │
│     - Two-pass search                           │
│     - Finds related terms automatically         │
│     - Best for broad exploration                │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Type 1: NATURAL LANGUAGE MODE

### What It Does:

Searches like you're talking naturally - just type your query!

**Key Features:**
- ✅ Ranks results by relevance (most relevant first)
- ✅ Ignores words that appear in 50%+ of rows (too common)
- ✅ Automatically handles word variations
- ✅ No special operators needed

### Visual Representation:

```
User Query: "machine learning tutorial"
              ↓
┌─────────────────────────────────────────────────┐
│  MySQL breaks it into words:                    │
│  • machine                                      │
│  • learning                                     │
│  • tutorial                                     │
└─────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  Searches documents for these words             │
│  Calculates relevance score for each            │
└─────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  RESULTS (Sorted by Score):                     │
│  📄 Doc 1: Score 2.5 ⭐⭐⭐⭐⭐                  │
│  📄 Doc 2: Score 1.8 ⭐⭐⭐⭐                    │
│  📄 Doc 3: Score 0.9 ⭐⭐                        │
└─────────────────────────────────────────────────┘
```

### Example Query:

```sql
-- Basic natural language search
SELECT 
    id, 
    title,
    MATCH(title, content) AGAINST('mysql database') AS relevance
FROM articles
WHERE MATCH(title, content) AGAINST('mysql database')
ORDER BY relevance DESC;
```

### Step-by-Step Example:

**Table: articles**
```
ID | Title                              | Content
---+------------------------------------+----------------------------------
1  | MySQL Database Tutorial            | Learn MySQL from scratch...
2  | PostgreSQL vs MySQL                | Comparing databases...
3  | Python Programming Guide           | Python basics for beginners...
4  | MySQL Performance Tips             | Optimize your MySQL database...
5  | Database Design Principles         | Good database design matters...
```

**Query:**
```sql
SELECT title, 
       MATCH(title, content) AGAINST('mysql database') AS score
FROM articles
WHERE MATCH(title, content) AGAINST('mysql database')
ORDER BY score DESC;
```

**Results:**
```
┌─────────────────────────────────┬────────┐
│ Title                           │ Score  │
├─────────────────────────────────┼────────┤
│ MySQL Database Tutorial         │  3.45  │ ⭐⭐⭐⭐⭐
│ MySQL Performance Tips          │  2.10  │ ⭐⭐⭐⭐
│ PostgreSQL vs MySQL             │  1.75  │ ⭐⭐⭐
│ Database Design Principles      │  0.85  │ ⭐⭐
└─────────────────────────────────┴────────┘

(Python Programming Guide not returned - no matches)
```

**Why these scores?**
```
Article 1: "MySQL Database Tutorial"
  • "mysql" in title (high weight) ████████
  • "database" in title (high weight) ████████
  • Both terms in content ██████
  Total: 3.45 ⭐⭐⭐⭐⭐

Article 4: "MySQL Performance Tips"
  • "mysql" in title ████████
  • "database" in content only ████
  Total: 2.10 ⭐⭐⭐⭐

Article 2: "PostgreSQL vs MySQL"
  • "mysql" in title ████████
  • "database" in content (implied) ██
  Total: 1.75 ⭐⭐⭐

Article 5: "Database Design Principles"
  • "database" in title ████
  • No "mysql" mention
  Total: 0.85 ⭐⭐
```

---

## ⚡ Type 2: BOOLEAN MODE

### What It Does:

Gives you **precise control** with special operators!

**Key Features:**
- ✅ Use operators: `+` (must have), `-` (must not have), `*` (wildcard)
- ✅ Use quotes `""` for exact phrases
- ✅ Combine multiple conditions
- ✅ No automatic relevance ranking (you control it!)

### Boolean Operators:

```
┌──────────┬─────────────────────────────────────────┐
│ Operator │ Meaning                                 │
├──────────┼─────────────────────────────────────────┤
│    +     │ MUST be present                         │
│    -     │ MUST NOT be present                     │
│   ""     │ Exact phrase match                      │
│    *     │ Wildcard (tech* = technology, technical)│
│    ()    │ Group terms                             │
│    >     │ Increase word importance                │
│    <     │ Decrease word importance                │
│    ~     │ Negation (reduce rank if present)       │
└──────────┴─────────────────────────────────────────┘
```

### Visual Examples:

#### Example 1: Must Include (+)

```
Query: "+mysql +tutorial"
       (MUST have mysql AND MUST have tutorial)

Document Analysis:
  📄 Doc 1: "MySQL Tutorial for Beginners"
     mysql ✓ | tutorial ✓ → MATCH! ✅
  
  📄 Doc 2: "MySQL Database Guide"
     mysql ✓ | tutorial ✗ → NO MATCH ❌
  
  📄 Doc 3: "SQL Tutorial"
     mysql ✗ | tutorial ✓ → NO MATCH ❌
```

#### Example 2: Must Exclude (-)

```
Query: "+database -oracle"
       (MUST have database, MUST NOT have oracle)

Document Analysis:
  📄 Doc 1: "MySQL Database Tutorial"
     database ✓ | oracle ✗ → MATCH! ✅
  
  📄 Doc 2: "Oracle Database Administration"
     database ✓ | oracle ✓ → NO MATCH ❌
  
  📄 Doc 3: "Database Design Principles"
     database ✓ | oracle ✗ → MATCH! ✅
```

#### Example 3: Exact Phrase ("")

```
Query: '"machine learning"'
       (Exact phrase, words must be adjacent)

Document Analysis:
  📄 Doc 1: "machine learning algorithms"
     "machine learning" ✓ → MATCH! ✅
  
  📄 Doc 2: "machine vision and learning"
     "machine learning" ✗ (not adjacent) → NO MATCH ❌
  
  📄 Doc 3: "learning about machine code"
     "machine learning" ✗ (wrong order) → NO MATCH ❌
```

#### Example 4: Wildcard (*)

```
Query: "develop*"
       (Matches: develop, developer, development, developing)

Document Analysis:
  📄 Doc 1: "web development tutorial"
     develop* ✓ (development) → MATCH! ✅
  
  📄 Doc 2: "hire a developer"
     develop* ✓ (developer) → MATCH! ✅
  
  📄 Doc 3: "developing software"
     develop* ✓ (developing) → MATCH! ✅
```

### Complex Boolean Query Example:

```sql
-- Find articles about MySQL or PostgreSQL tutorials,
-- but NOT about Oracle, and must mention "beginner"
SELECT title, content
FROM articles
WHERE MATCH(title, content) 
AGAINST('+beginner +(mysql postgresql) -oracle tutorial*' IN BOOLEAN MODE);
```

**Visual breakdown:**
```
┌─────────────────────────────────────────────────┐
│  Query Components:                              │
├─────────────────────────────────────────────────┤
│  +beginner          MUST have "beginner"        │
│  +(mysql postgresql) MUST have mysql OR postgres│
│  -oracle            MUST NOT have "oracle"      │
│  tutorial*          Optional, matches tutorial* │
└─────────────────────────────────────────────────┘

Documents:
  📄 "MySQL Tutorial for Beginners"
     beginner ✓ | mysql ✓ | oracle ✗ | tutorial ✓
     Result: MATCH! ✅⭐⭐⭐⭐⭐
  
  📄 "PostgreSQL Beginner Guide"
     beginner ✓ | postgresql ✓ | oracle ✗ | tutorial ✗
     Result: MATCH! ✅⭐⭐⭐⭐
  
  📄 "Oracle Database for Beginners"
     beginner ✓ | mysql ✗ | oracle ✓ | tutorial ✗
     Result: NO MATCH (has oracle) ❌
  
  📄 "Advanced MySQL Performance"
     beginner ✗ | mysql ✓ | oracle ✗ | tutorial ✗
     Result: NO MATCH (no beginner) ❌
```

---

## 🔄 Type 3: QUERY EXPANSION MODE

### What It Does:

Performs **TWO searches** - first finds matches, then searches again using words from those matches!

**How It Works:**
```
┌─────────────────────────────────────────────────┐
│  PASS 1: Initial Search                         │
│  Query: "database"                              │
│  Finds: Top 10 most relevant documents          │
└─────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  EXTRACTION: Find Common Words                  │
│  From top 10 docs, extract frequent terms:      │
│  • database (original)                          │
│  • mysql (found in many results)                │
│  • sql (found in many results)                  │
│  • table (found in many results)                │
└─────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────┐
│  PASS 2: Expanded Search                        │
│  New Query: "database mysql sql table"          │
│  Finds: More documents using expanded terms     │
└─────────────────────────────────────────────────┘
```

### Visual Example:

**Original Query:** "mysql"

**Pass 1 Results:**
```
📄 Doc 1: "MySQL Tutorial"
📄 Doc 2: "MySQL Performance"
📄 Doc 3: "MySQL vs PostgreSQL"
📄 Doc 4: "MySQL Database Design"
📄 Doc 5: "MySQL Best Practices"
```

**Extracted Terms from Pass 1:**
```
Common words across top results:
  • mysql (100% - original term)
  • database (80%)
  • query (60%)
  • performance (60%)
  • table (50%)
```

**Pass 2 - Expanded Query:**
```
Now searching for: "mysql database query performance table"

Additional Results Found:
📄 Doc 6: "Database Query Optimization" ← NEW!
📄 Doc 7: "Table Performance Tuning" ← NEW!
📄 Doc 8: "SQL Query Best Practices" ← NEW!
```

### SQL Example:

```sql
-- Query expansion mode
SELECT title, content
FROM articles
WHERE MATCH(title, content) 
AGAINST('mysql' WITH QUERY EXPANSION);
```

**Comparison:**

```
┌─────────────────────────────────────────────────┐
│  WITHOUT Query Expansion:                       │
│  Query: "mysql"                                 │
│  Results: 5 documents                           │
│                                                 │
│  📄 MySQL Tutorial                              │
│  📄 MySQL Performance                           │
│  📄 MySQL Database                              │
│  📄 MySQL vs PostgreSQL                         │
│  📄 MySQL Best Practices                        │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  WITH Query Expansion:                          │
│  Query: "mysql"                                 │
│  Results: 12 documents (more comprehensive!)    │
│                                                 │
│  📄 MySQL Tutorial                              │
│  📄 MySQL Performance                           │
│  📄 MySQL Database                              │
│  📄 MySQL vs PostgreSQL                         │
│  📄 MySQL Best Practices                        │
│  📄 Database Query Optimization ← NEW           │
│  📄 SQL Performance Tips ← NEW                  │
│  📄 Relational Database Design ← NEW            │
│  📄 Table Indexing Strategies ← NEW             │
│  📄 Query Performance Tuning ← NEW              │
│  📄 Database Best Practices ← NEW               │
│  📄 SQL Optimization Guide ← NEW                │
└─────────────────────────────────────────────────┘
```

**When to use:**
- ✅ Exploratory searches
- ✅ When you want comprehensive results
- ✅ When users might use different terminology
- ❌ When you need precise, narrow results

---

## 🏗️ Setting Up Full-Text Search

### Step 1: Create Full-Text Index

```sql
-- Create table with full-text index
CREATE TABLE articles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    content TEXT,
    author VARCHAR(100),
    created_at DATETIME,
    FULLTEXT INDEX ft_idx (title, content)
) ENGINE=InnoDB;
```

**Visual representation:**
```
┌──────────────────────────────────────────────┐
│  Table: articles                             │
├──────────────────────────────────────────────┤
│  id          [Primary Key]                   │
│  title       [Indexed in full-text] ⚡       │
│  content     [Indexed in full-text] ⚡       │
│  author      [Not indexed]                   │
│  created_at  [Not indexed]                   │
├──────────────────────────────────────────────┤
│  FULLTEXT INDEX: ft_idx                      │
│  Columns: (title, content)                   │
│  ⚡ Lightning fast searches! ⚡              │
└──────────────────────────────────────────────┘
```

### Step 2: Add Index to Existing Table

```sql
-- Add full-text index to existing table
ALTER TABLE articles 
ADD FULLTEXT INDEX ft_content (title, content);
```

### Step 3: Multiple Indexes

```sql
-- Create separate indexes for different use cases
ALTER TABLE articles 
ADD FULLTEXT INDEX ft_title (title);

ALTER TABLE articles 
ADD FULLTEXT INDEX ft_content (content);

ALTER TABLE articles 
ADD FULLTEXT INDEX ft_all (title, content, author);
```

**When to use multiple indexes:**
```
┌────────────────────────────────────────────────┐
│  ft_title: Search titles only (fast)          │
│  Use: Quick title lookups                     │
│  Speed: ⚡⚡⚡⚡⚡                               │
├────────────────────────────────────────────────┤
│  ft_content: Search content only              │
│  Use: Deep content search                     │
│  Speed: ⚡⚡⚡⚡                                 │
├────────────────────────────────────────────────┤
│  ft_all: Search everything                    │
│  Use: Comprehensive search                    │
│  Speed: ⚡⚡⚡                                   │
└────────────────────────────────────────────────┘
```

---

## 📊 Comparison: All Three Modes

### Example Query: "database tutorial"

**Table Data:**
```
ID | Title                           | Content (excerpt)
---+---------------------------------+----------------------------------
1  | MySQL Database Tutorial         | Learn database management...
2  | Database Design Principles      | Good database design tutorial...
3  | Oracle Administration Guide     | Advanced database topics...
4  | SQL Query Tutorial              | Master SQL queries and joins...
5  | NoSQL Database Overview         | Modern database solutions...
```

### Mode 1: Natural Language

```sql
SELECT title, 
       MATCH(title, content) AGAINST('database tutorial') AS score
FROM articles
WHERE MATCH(title, content) AGAINST('database tutorial')
ORDER BY score DESC;
```

**Results:**
```
┌─────────────────────────────────┬────────┬──────────┐
│ Title                           │ Score  │ Why?     │
├─────────────────────────────────┼────────┼──────────┤
│ MySQL Database Tutorial         │  4.2   │ Both words│
│ Database Design Principles      │  3.8   │ Both words│
│ NoSQL Database Overview         │  2.1   │ 1 word   │
│ Oracle Administration Guide     │  1.5   │ 1 word   │
│ SQL Query Tutorial              │  1.2   │ 1 word   │
└─────────────────────────────────┴────────┴──────────┘
```

### Mode 2: Boolean

```sql
SELECT title
FROM articles
WHERE MATCH(title, content) 
AGAINST('+database +tutorial' IN BOOLEAN MODE);
```

**Results:**
```
┌─────────────────────────────────┬──────────┐
│ Title                           │ Match?   │
├─────────────────────────────────┼──────────┤
│ MySQL Database Tutorial         │ ✅ MATCH │ (both)
│ Database Design Principles      │ ✅ MATCH │ (both)
│ NoSQL Database Overview         │ ❌ NO    │ (only database)
│ Oracle Administration Guide     │ ❌ NO    │ (only database)
│ SQL Query Tutorial              │ ❌ NO    │ (only tutorial)
└─────────────────────────────────┴──────────┘

Only 2 results (strict matching)
```

### Mode 3: Query Expansion

```sql
SELECT title
FROM articles
WHERE MATCH(title, content) 
AGAINST('database tutorial' WITH QUERY EXPANSION);
```

**Results:**
```
┌─────────────────────────────────┬────────────────┐
│ Title                           │ Found How?     │
├─────────────────────────────────┼────────────────┤
│ MySQL Database Tutorial         │ Direct match   │
│ Database Design Principles      │ Direct match   │
│ NoSQL Database Overview         │ Direct match   │
│ Oracle Administration Guide     │ Direct match   │
│ SQL Query Tutorial              │ Direct match   │
│ PostgreSQL Best Practices       │ Expanded ⭐    │
│ Table Design Guide              │ Expanded ⭐    │
│ SQL Performance Tips            │ Expanded ⭐    │
└─────────────────────────────────┴────────────────┘

8 results (finds related content)
```

---

## 🎯 Practical Use Cases

### Use Case 1: E-commerce Product Search

```sql
-- Natural language for user-friendly search
SELECT 
    product_name,
    description,
    price,
    MATCH(product_name, description) AGAINST('wireless headphones') AS relevance
FROM products
WHERE MATCH(product_name, description) AGAINST('wireless headphones')
ORDER BY relevance DESC, price ASC
LIMIT 20;
```

**Visual Results:**
```
┌──────────────────────────────────┬────────┬────────┐
│ Product                          │ Score  │ Price  │
├──────────────────────────────────┼────────┼────────┤
│ Sony Wireless Headphones WH-1000 │  5.2   │ $299   │ ⭐⭐⭐⭐⭐
│ Beats Wireless Over-Ear          │  4.8   │ $199   │ ⭐⭐⭐⭐⭐
│ JBL Wireless Bluetooth Headset   │  4.1   │ $89    │ ⭐⭐⭐⭐
│ Bose QuietComfort Wireless       │  3.9   │ $329   │ ⭐⭐⭐⭐
└──────────────────────────────────┴────────┴────────┘
```

### Use Case 2: Blog Post Search with Filters

```sql
-- Boolean mode for precise filtering
SELECT title, author, publish_date
FROM blog_posts
WHERE MATCH(title, content) 
AGAINST('+javascript +tutorial -jquery -deprecated' IN BOOLEAN MODE)
AND publish_date > DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

**Logic Flow:**
```
┌─────────────────────────────────────────────┐
│  Requirements:                              │
│  ✓ Must have "javascript"                   │
│  ✓ Must have "tutorial"                     │
│  ✗ Must NOT have "jquery"                   │
│  ✗ Must NOT have "deprecated"               │
│  ✓ Published within last year               │
└─────────────────────────────────────────────┘

Results:
  ✅ "Modern JavaScript Tutorial 2024"
  ✅ "JavaScript ES6 Tutorial Guide"
  ❌ "jQuery Tutorial for Beginners" (has jquery)
  ❌ "JavaScript Basics from 2020" (too old)
```

### Use Case 3: Documentation Search

```sql
-- Query expansion for comprehensive results
SELECT 
    doc_title,
    category,
    url,
    MATCH(doc_title, content) AGAINST('authentication') AS score
FROM documentation
WHERE MATCH(doc_title, content) 
AGAINST('authentication' WITH QUERY EXPANSION)
ORDER BY score DESC
LIMIT 50;
```

**Expansion Process:**
```
Original: "authentication"
    ↓
Found docs mention:
  • authentication (original)
  • login
  • security
  • password
  • oauth
  • jwt
    ↓
Searches again with expanded terms
    ↓
Returns comprehensive results:
  📄 "Authentication Methods"
  📄 "OAuth 2.0 Implementation"
  📄 "JWT Token Guide"
  📄 "Login Security Best Practices"
  📄 "Password Hashing"
  📄 "Two-Factor Authentication"
```

---

## ⚙️ Important Configuration

### Minimum Word Length

```sql
-- Check current minimum word length
SHOW VARIABLES LIKE 'ft_min_word_len';

-- Default: 4 (words must be 4+ characters)
-- Example: "car" won't be indexed, "cars" will be
```

**Visual:**
```
ft_min_word_len = 4

Indexed:
  ✅ "mysql" (5 chars)
  ✅ "database" (8 chars)
  ✅ "tutorial" (8 chars)

NOT Indexed:
  ❌ "sql" (3 chars)
  ❌ "php" (3 chars)
  ❌ "car" (3 chars)
```

**To change (requires restart):**
```sql
-- In my.cnf or my.ini
[mysqld]
ft_min_word_len = 3
innodb_ft_min_token_size = 3

-- Then rebuild indexes
ALTER TABLE articles DROP INDEX ft_idx;
ALTER TABLE articles ADD FULLTEXT INDEX ft_idx (title, content);
```

### Stopwords (Ignored Words)

MySQL ignores common words like: "the", "is", "at", "which", "on", etc.

```
┌─────────────────────────────────────────────┐
│  Default Stopwords (36 words):              │
│  a, about, an, are, as, at, be, by, com,    │
│  for, from, how, in, is, it, of, on, or,    │
│  that, the, this, to, was, what, when,      │
│  where, who, will, with, the, www           │
└─────────────────────────────────────────────┘
```

**Example:**
```
Query: "the best mysql tutorial"
Actually searches: "best mysql tutorial"
(Ignores "the")
```

### 50% Threshold Rule

Words appearing in 50%+ of rows are ignored in **Natural Language Mode**!

```
Table with 100 rows:

Word "database":
  Appears in 60 rows (60%)
  Result: IGNORED ❌
  
Word "mysql":
  Appears in 30 rows (30%)
  Result: USED ✅
```

**Solution:** Use Boolean Mode to bypass this rule!

```sql
-- Natural language (ignores common words)
MATCH(content) AGAINST('database')

-- Boolean mode (includes all words)
MATCH(content) AGAINST('database' IN BOOLEAN MODE)
```

---

## 📈 Performance Tips

### 1. Index Only What You Search

```sql
-- ❌ Bad: Index everything
ALTER TABLE articles 
ADD FULLTEXT INDEX ft_all (title, content, author, tags, comments);

-- ✅ Good: Index only searched columns
ALTER TABLE articles 
ADD FULLTEXT INDEX ft_search (title, content);
```

### 2. Use Smaller Indexes for Faster Searches

```
┌──────────────────────────────────────────────┐
│  Index Size vs Speed:                        │
├──────────────────────────────────────────────┤
│  Title only:          10 MB  ⚡⚡⚡⚡⚡        │
│  Title + Content:     50 MB  ⚡⚡⚡⚡          │
│  Everything:         200 MB  ⚡⚡             │
└──────────────────────────────────────────────┘
```

### 3. Limit Results

```sql
-- Always use LIMIT for better performance
SELECT title, content
FROM articles
WHERE MATCH(title, content) AGAINST('mysql')
LIMIT 100;
```

### 4. Use Covering Indexes

```sql
-- Include frequently selected columns in index
ALTER TABLE articles 
ADD FULLTEXT INDEX ft_idx (title, content);

-- Query only indexed columns (faster!)
SELECT title FROM articles
WHERE MATCH(title, content) AGAINST('mysql');
```

---

## 🆚 Full-Text Search vs LIKE

```
┌───────────────────────────────────────────────────┐
│  Feature          │  LIKE          │  Full-Text   │
├───────────────────┼────────────────┼──────────────┤
│  Speed (1M rows)  │  5-10 sec      │  0.05 sec    │
│  Relevance Score  │  No            │  Yes         │
│  Word Boundary    │  No            │  Yes         │
│  Boolean Ops      │  No            │  Yes         │
│  Phrase Search    │  Manual        │  Built-in    │
│  Wildcards        │  % _           │  *           │
│  Index Support    │  Limited       │  Specialized │
│  Memory Usage     │  Low           │  High        │
└───────────────────┴────────────────┴──────────────┘
```

**Example comparison:**

```sql
-- LIKE (slow, no relevance)
SELECT * FROM articles 
WHERE content LIKE '%mysql%' 
AND content LIKE '%tutorial%';
Time: 8 seconds ❌

-- Full-Text (fast, with relevance)
SELECT *, MATCH(content) AGAINST('mysql tutorial') AS score
FROM articles 
WHERE MATCH(content) AGAINST('mysql tutorial')
ORDER BY score DESC;
Time: 0.05 seconds ✅
```

---

## 🎓 Quick Reference

### Natural Language Mode:
```sql
-- Simple relevance search
MATCH(column) AGAINST('search terms')
```

### Boolean Mode:
```sql
-- Precise control
MATCH(column) AGAINST('+must -not "exact phrase" wild*' IN BOOLEAN MODE)
```

### Query Expansion:
```sql
-- Broad exploration
MATCH(column) AGAINST('term' WITH QUERY EXPANSION)
```

### Common Patterns:

```sql
-- Pattern 1: Basic search with score
SELECT title, MATCH(title) AGAINST('mysql') AS relevance
FROM articles
WHERE MATCH(title) AGAINST('mysql')
ORDER BY relevance DESC;

-- Pattern 2: Multi-column search
SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('database tutorial');

-- Pattern 3: Combined with other conditions
SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('mysql')
AND author = 'John Doe'
AND publish_date > '2024-01-01';

-- Pattern 4: Boolean with required terms
SELECT * FROM articles
WHERE MATCH(title, content) 
AGAINST('+mysql +innodb -myisam' IN BOOLEAN MODE);
```

---

## 🚀 Best Practices Summary

```
✅ DO:
  • Create full-text indexes on searched columns
  • Use appropriate mode for your use case
  • Limit results with LIMIT
  • Use Boolean mode for precise searches
  • Test different modes for best results

❌ DON'T:
  • Index