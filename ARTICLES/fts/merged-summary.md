# 🔍 Full-Text Search: A Complete Guide
*From fundamentals to BM25 scoring*

---

## 📚 Table of Contents

1. [What is Full-Text Search?](#what-is-full-text-search)
2. [The Inverted Index: The Engine Behind Search](#the-inverted-index)
3. [Understanding TF, IDF, and TF-IDF](#understanding-tf-idf-and-tf-idf)
4. [BM25: The Modern Ranking Function](#bm25-the-modern-ranking-function)
5. [MySQL Full-Text Search Modes](#mysql-full-text-search-modes)
6. [Boolean Search Operators](#boolean-search-operators)
7. [Practical Applications](#practical-applications)

---

## 🎯 What is Full-Text Search?

Full-Text Search (FTS) is a technique for searching text within documents that goes far beyond simple pattern matching. When you search for "python programming" in a search engine, FTS helps answer:

> **"Which documents are most relevant to this query?"**

### The Problem with Simple Search

Traditional database searches use pattern matching:

```sql
SELECT * FROM posts 
WHERE content LIKE '%python%'
```

**Problems:**
- ❌ Scans every row (slow for large datasets)
- ❌ No relevance ranking
- ❌ Can't handle synonyms or related terms
- ❌ Poor handling of common vs. rare words

### The FTS Solution

Full-Text Search provides:
- ✅ Fast lookups via inverted indexes
- ✅ Relevance scoring (best matches first)
- ✅ Phrase matching and proximity searches
- ✅ Boolean operators (AND, OR, NOT)
- ✅ Intelligent ranking based on word importance

---

## 🗂️ The Inverted Index: The Engine Behind Search

### What is an Inverted Index?

An inverted index "inverts" the natural document structure:

```
📄 Forward Index (natural):
Document → Words it contains

🔄 Inverted Index:
Word → Documents that contain it
```

This inversion is what makes searching lightning-fast.

### Building an Inverted Index

Let's walk through a complete example:

#### Step 1: Start with Documents

```
Doc 1: "The quick brown fox jumps over the lazy dog"
Doc 2: "The lazy cat sleeps all day"
Doc 3: "Quick brown dogs run fast"
```

#### Step 2: Tokenization

Break each document into individual words:

```
Doc 1: [the, quick, brown, fox, jumps, over, the, lazy, dog]
Doc 2: [the, lazy, cat, sleeps, all, day]
Doc 3: [quick, brown, dogs, run, fast]
```

#### Step 3: Normalization

Clean up tokens (lowercase, handle plurals):

```
Doc 1: [the, quick, brown, fox, jump, over, the, lazy, dog]
Doc 2: [the, lazy, cat, sleep, all, day]
Doc 3: [quick, brown, dog, run, fast]
```

#### Step 4: Build the Inverted Index

```
"the"    → [Doc 1, Doc 2]
"quick"  → [Doc 1, Doc 3]
"brown"  → [Doc 1, Doc 3]
"fox"    → [Doc 1]
"jump"   → [Doc 1]
"over"   → [Doc 1]
"lazy"   → [Doc 1, Doc 2]
"dog"    → [Doc 1, Doc 3]
"cat"    → [Doc 2]
"sleep"  → [Doc 2]
"all"    → [Doc 2]
"day"    → [Doc 2]
"run"    → [Doc 3]
"fast"   → [Doc 3]
```

### Enhanced Inverted Index

Real-world indexes store much more:

```
"brown" → {
    Doc 1: {
        frequency: 1,
        positions: [2],
        field: "content"
    },
    Doc 3: {
        frequency: 1,
        positions: [1],
        field: "content"
    }
}
```

This enables:
- **Phrase searches** (check if words are adjacent)
- **Proximity searches** (words within N positions)
- **Relevance scoring** (term frequency)

### Why It's So Fast

```
                 SEARCH PERFORMANCE
┌──────────────────────────────────────────────────┐
│ Linear Search (LIKE '%word%'):                  │
│ ████████████████████████████ 1,000,000 checks   │
│                                                  │
│ Inverted Index:                                  │
│ █ 1 lookup + 10 results                         │
└──────────────────────────────────────────────────┘

Speed improvement: 100,000x faster! ⚡
```

**Time Complexity:**
- Linear search: O(n) where n = all documents
- Inverted index: O(1) lookup + O(k) where k = matching documents

---

## 📊 Understanding TF, IDF, and TF-IDF

Now that we have an inverted index, how do we rank results? Enter the three fundamental concepts.

### 1️⃣ Term Frequency (TF)

**Intuition:** How often does a term appear in a document?

```
TF(t, d) = number of times term t appears in document d
```

**Example:**

```
Doc 1: "Python is great. Python is popular."
Doc 2: "Java is a programming language."
Doc 3: "Cooking recipes and tips."

TF("python", Doc 1) = 2
TF("python", Doc 2) = 0
TF("python", Doc 3) = 0
```

**Key Insight:** Documents with higher TF for a term are probably more about that term.

---

### 2️⃣ Inverse Document Frequency (IDF)

**Intuition:** How rare or common is a term across all documents?

```
IDF(t) = ln((N - n + 0.5) / (n + 0.5))

Where:
N = total number of documents
n = number of documents containing term t
```

#### IDF Visual Intuition

```
          TERM RARITY → IDF VALUE
┌──────────────────────────────────────────────┐
│ Rare Terms    │ Medium Terms │ Common Terms  │
│ (n small)     │ (n ≈ N/2)    │ (n large)     │
│               │              │               │
│  + Positive   │     Zero     │  - Negative   │
└──────────────────────────────────────────────┘

Examples:
Rare    → "neutrino"     → IDF: +2.5
Medium  → "database"     → IDF:  0.0
Common  → "the"          → IDF: -3.2
```

#### Why IDF Can Be Negative

```
IDF = ln((N - n + 0.5) / (n + 0.5))

When n is small (rare term):
   (N - n + 0.5)
   ─────────────  > 1   → ln > 0   ✅ Positive
    (n + 0.5)

When n ≈ N/2 (medium term):
   (N - n + 0.5)
   ─────────────  = 1   → ln = 0   ➖ Zero
    (n + 0.5)

When n is large (common term):
   (N - n + 0.5)
   ─────────────  < 1   → ln < 0   ⬇️ Negative
    (n + 0.5)
```

**Example with 3 Documents:**

```
N = 3

Term "python" appears in 1 doc:
IDF("python") = ln((3 - 1 + 0.5) / (1 + 0.5))
              = ln(2.5 / 1.5)
              = ln(1.667)
              ≈ 0.51  ✅ Positive (rare)

Term "programming" appears in 2 docs:
IDF("programming") = ln((3 - 2 + 0.5) / (2 + 0.5))
                   = ln(1.5 / 2.5)
                   = ln(0.6)
                   ≈ -0.51  ⬇️ Negative (common)
```

**🔑 Key Insight:** Negative IDF is normal and expected for common terms!

---

### 3️⃣ TF-IDF: Combining Both

**The Formula:**

```
TF-IDF(t, d) = TF(t, d) × IDF(t)
```

**Mental Model:**

```
TF-IDF = "How much does this document        × "How special is
          talk about this term?"               this term overall?"
```

**Example:**

```
TF("python", Doc 1) = 2
IDF("python") = 0.51

TF-IDF("python", Doc 1) = 2 × 0.51 = 1.02  ✅ High score

TF("python", Doc 2) = 0
TF-IDF("python", Doc 2) = 0  ❌ No match
```

#### TF-IDF as Bonus/Penalty System

```
         BM25/TF-IDF SCORING CONCEPT
┌──────────────────────────────────────────────┐
│ For each term:                               │
│                                              │
│ Rare Term     → + Bonus (positive IDF)      │
│ Common Term   → - Penalty (negative IDF)    │
│                                              │
│ Final Score = Σ (Bonuses + Penalties)       │
└──────────────────────────────────────────────┘
```

---

## 🎯 BM25: The Modern Ranking Function

### Why BM25 Over TF-IDF?

TF-IDF has limitations:

❌ **Linear TF:** The 10th occurrence of a term counts as much as the 1st  
❌ **No length normalization:** Long documents naturally have higher TF  
❌ **Unrealistic saturation:** Real relevance plateaus after a few occurrences

**BM25 Improvements:**

✅ **Saturating TF:** Diminishing returns for repeated terms  
✅ **Length normalization:** Adjusts for document length  
✅ **Better ranking quality:** Closer to human judgment

### The BM25 Formula

For a single term `t` in document `d`:

```
BM25(t, d) = IDF(t) × [TF(t,d) × (k₁ + 1)] / [TF(t,d) + k₁ × (1 - b + b × |d|/avgdl)]

Where:
TF(t, d)  = term frequency in document
|d|       = document length (number of terms)
avgdl     = average document length
k₁        = TF saturation parameter (typically 1.2-2.0)
b         = length normalization (typically 0.75)
IDF(t)    = inverse document frequency
```

For multi-term queries, sum all terms:

```
BM25(query, doc) = Σ BM25(term, doc) for all terms in query
```

### 📐 BM25 Pipeline

```
          BM25 RANKING PIPELINE
┌──────────────────────────────────────────────┐
│ 1. Parse query into terms                   │
│ 2. For each document:                        │
│      • Count term frequency (TF)            │
│      • Compute IDF for each term            │
│      • Apply length normalization           │
│      • Combine contributions                │
│ 3. Sum all term scores → BM25 score         │
│ 4. Sort documents by score (DESC)           │
└──────────────────────────────────────────────┘
```

---

## 🧮 Complete BM25 Worked Example

### Our Documents

```python
Doc 1: "Python is a great programming language. Python is popular."
       Length: 9 tokens

Doc 2: "Java is a programming language."
       Length: 5 tokens

Doc 3: "Cooking recipes and kitchen tips."
       Length: 5 tokens

N = 3 documents
avgdl = (9 + 5 + 5) / 3 = 6.33
```

### Parameters

```
k₁ = 1.5
b = 0.75
```

### Query: "python programming"

---

#### Step 1: Calculate IDF Values

**Term: "python"**
- Appears in: Doc 1 only → n = 1

```
IDF("python") = ln((N - n + 0.5) / (n + 0.5))
              = ln((3 - 1 + 0.5) / (1 + 0.5))
              = ln(2.5 / 1.5)
              = ln(1.667)
              ≈ 0.51  ✅ Positive (rare)
```

**Term: "programming"**
- Appears in: Doc 1, Doc 2 → n = 2

```
IDF("programming") = ln((3 - 2 + 0.5) / (2 + 0.5))
                   = ln(1.5 / 2.5)
                   = ln(0.6)
                   ≈ -0.51  ⬇️ Negative (common)
```

---

#### Step 2: Calculate TF for Doc 1

```
TF("python", Doc 1) = 2
TF("programming", Doc 1) = 1
```

---

#### Step 3: Length Normalization for Doc 1

```
L = 1 - b + b × (|d| / avgdl)
  = 1 - 0.75 + 0.75 × (9 / 6.33)
  = 0.25 + 0.75 × 1.42
  = 0.25 + 1.065
  = 1.315
```

---

#### Step 4: BM25 Score for "python" in Doc 1

```
BM25("python", Doc 1) = IDF × [TF × (k₁ + 1)] / [TF + k₁ × L]

Numerator:
TF × (k₁ + 1) = 2 × (1.5 + 1) = 2 × 2.5 = 5

Denominator:
TF + k₁ × L = 2 + 1.5 × 1.315 = 2 + 1.97 = 3.97

Fraction:
5 / 3.97 ≈ 1.26

Final:
BM25("python", Doc 1) = 0.51 × 1.26 ≈ 0.64  ✅
```

---

#### Step 5: BM25 Score for "programming" in Doc 1

```
BM25("programming", Doc 1) = IDF × [TF × (k₁ + 1)] / [TF + k₁ × L]

Numerator:
TF × (k₁ + 1) = 1 × 2.5 = 2.5

Denominator:
TF + k₁ × L = 1 + 1.5 × 1.315 = 1 + 1.97 = 2.97

Fraction:
2.5 / 2.97 ≈ 0.84

Final:
BM25("programming", Doc 1) = -0.51 × 0.84 ≈ -0.43  ⬇️
```

---

#### Step 6: Total BM25 Score

```
BM25(query, Doc 1) = BM25("python", Doc 1) + BM25("programming", Doc 1)
                   = 0.64 + (-0.43)
                   = 0.21  ✅ Positive overall
```

---

### 🎨 Understanding Negative Scores

#### The BM25 Score Spectrum

```
          BM25 SCORE RANGE
────────────────────────────────────────────────
  Negative              Zero            Positive
────────────────┬──────────────┬────────────────
     -8  -5  -3  -1   0   +1  +3  +6  +10
                 ↑
         Higher is better
```

**🔑 Key Insight:** Even in the negative zone, **-1 beats -5**!

---

#### When Scores Are Negative

```
Query: "the programming language"

Document Scores:
┌───────────────┬──────────────┐
│ Document      │ BM25 Score   │
├───────────────┼──────────────┤
│ Doc 2         │   -4.8       │  ← Best match ✅
│ Doc 1         │   -5.2       │
│ Doc 3         │    0.0       │  ← No match ❌
└───────────────┴──────────────┘

Ranking: -4.8 > -5.2 > 0.0
```

**Why negative?** All query terms ("the", "programming", "language") are common, giving negative IDF values.

**Does it matter?** No! Ranking still works perfectly.

---

### 🧠 Mental Model: When Scores Take Each Sign

```
          WHEN DO SCORES TAKE EACH SIGN?
┌──────────────────────────────────────────────┐
│ Positive → Rare terms dominate query        │
│ Zero     → No matching terms OR balanced    │
│ Negative → Very common terms dominate       │
└──────────────────────────────────────────────┘
```

---

## 🔧 MySQL Full-Text Search Modes

MySQL provides three different FTS modes, each with unique behavior.

### Mode Comparison

```
┌─────────────────────────────────────────────────┐
│              MySQL FTS MODES                    │
├─────────────────┬───────────┬───────────────────┤
│ Mode            │ Operators │ Best For          │
├─────────────────┼───────────┼───────────────────┤
│ Natural Lang.   │ ❌ No     │ General search    │
│ Boolean         │ ✅ Yes    │ Precision control │
│ Query Expansion │ ❌ No     │ Vague queries     │
└─────────────────┴───────────┴───────────────────┘
```

---

### 1️⃣ Natural Language Mode

**How it works:**
- Analyzes query as normal human language
- Calculates relevance using TF-IDF/BM25 scoring
- No special operators allowed
- Default mode

**SQL Example:**

```sql
SELECT id, title,
       MATCH(title, content) 
       AGAINST ('wordpress search' IN NATURAL LANGUAGE MODE) AS score
FROM wp_posts
WHERE MATCH(title, content) AGAINST ('wordpress search')
ORDER BY score DESC;
```

**Use cases:**
- General-purpose search
- User-facing search boxes
- When you want MySQL to handle relevance automatically

---

### 2️⃣ Boolean Mode

**How it works:**
- Supports special operators for precise control
- No minimum word length restrictions
- No 50% threshold (unlike natural mode)

**SQL Example:**

```sql
SELECT id, title,
       MATCH(title, content) 
       AGAINST ('+wordpress +search -elasticsearch' IN BOOLEAN MODE) AS score
FROM wp_posts
ORDER BY score DESC;
```

**Use cases:**
- Advanced search forms
- Filter-style searches
- When users need precise control

---

### 3️⃣ Query Expansion Mode

**How it works:**
1. Runs initial Natural Language search
2. Analyzes top results for related terms
3. Reruns search with expanded query
4. Surfaces semantically similar documents

**SQL Example:**

```sql
SELECT id, title,
       MATCH(title, content) 
       AGAINST ('search' WITH QUERY EXPANSION) AS score
FROM wp_posts
ORDER BY score DESC;
```

**Use cases:**
- Short/vague queries
- "Did you mean..." functionality
- Discovering related content

---

## 🎚️ Boolean Search Operators

Boolean mode gives you powerful control over search behavior.

### Core Operators

```
┌──────────┬─────────────────────────────────────┐
│ Operator │ Effect                              │
├──────────┼─────────────────────────────────────┤
│ +word    │ Must have (REQUIRED)               │
│ -word    │ Must NOT have (EXCLUDED)           │
│ >word    │ Increase relevance (BOOST)         │
│ <word    │ Decrease relevance (DEMOTE)        │
│ "phrase" │ Exact phrase match                 │
│ ()       │ Group terms                        │
└──────────┴─────────────────────────────────────┘
```

⚠️ **Note:** Wildcard `*` is NOT supported in MySQL Boolean FTS

---

### `+` Required Term

```sql
-- Must contain "wordpress"
'+wordpress'

Example:
+wordpress → Finds: "WordPress Tutorial"
          → Skips: "Drupal Tutorial"
```

---

### `-` Excluded Term

```sql
-- Must NOT contain "spam"
'+email -spam'

Example:
+email -spam → Finds: "Email Marketing Tips"
             → Skips: "Spam Email Filter"
```

---

### `>` Increase Relevance (BOOST)

**Meaning:** Term is optional, but if present, rank higher

```sql
-- Prefer products with "4K"
'+camera >4K'

Results ranking:
1. "4K Camera Ultra HD" (has both) ⭐⭐⭐
2. "Camera DSLR Professional" (camera only) ⭐⭐
```

**Important:** `>word` does NOT exclude results without the word!

---

### `<` Decrease Relevance (DEMOTE)

**Meaning:** Term is optional, but if present, rank lower

```sql
-- Prefer non-bluetooth speakers
'+speaker <bluetooth'

Results ranking:
1. "Wired Speaker Pro" (no bluetooth) ⭐⭐⭐
2. "Bluetooth Speaker Mini" (has bluetooth) ⭐
```

---

### Combined Example

```sql
-- Complex ranking preference
'+camera >professional <amateur -broken'

Means:
✅ Must have "camera"
⭐ Prefer "professional" (ranks higher)
⬇️ De-prioritize "amateur" (ranks lower)
❌ Exclude "broken"

Results:
1. "Professional Camera DSLR" (best)
2. "Camera Point and Shoot" (middle)
3. "Amateur Camera Starter" (worst, but included)
```

---

### Phrase Search

```sql
-- Exact phrase match
'"full text search"'

Finds: "MySQL full text search tutorial"
Skips: "full search of text files"
```

---

### Operator Summary

```
         OPERATOR EFFECTS ON RESULTS
┌──────────┬──────────┬─────────────────────┐
│ Operator │ Required │ Effect              │
├──────────┼──────────┼─────────────────────┤
│ +word    │ YES      │ Filter (must have)  │
│ -word    │ NO       │ Filter (exclude)    │
│ >word    │ NO       │ Ranking (boost)     │
│ <word    │ NO       │ Ranking (demote)    │
│ word     │ NO       │ Optional match      │
│ "phrase" │ NO*      │ Exact phrase        │
└──────────┴──────────┴─────────────────────┘

* Phrase can be combined with + for required phrase
```

---

## 🔄 TF-IDF vs BM25 Comparison

```
                TF-IDF vs BM25
┌──────────────────────────────────────────────┐
│ TF-IDF:                                      │
│   • Linear term frequency                   │
│   • No length normalization                 │
│   • Simpler implementation                  │
│   • Older algorithm                         │
│   • Less realistic                          │
│                                              │
│ BM25:                                        │
│   • Saturating TF (diminishing returns)     │
│   • Length normalization built-in           │
│   • Tunable parameters (k₁, b)              │
│   • Modern standard (Elasticsearch, etc.)   │
│   • Better ranking quality                  │
└──────────────────────────────────────────────┘
```

**When to use each:**

**TF-IDF:**
- Simple prototypes
- Educational purposes
- Very small datasets
- When speed > accuracy

**BM25:**
- Production systems
- Large document collections
- When ranking quality matters
- Modern search engines (recommended)

---

## 💡 Practical Applications

### WordPress Integration

WordPress doesn't use true inverted indexes by default. The native search does:

```sql
SELECT * FROM wp_posts 
WHERE post_content LIKE '%search term%'
```

**Problems:**
- Scans every post (slow)
- No relevance ranking
- No phrase matching

**Better Solutions:**

1. **MySQL FULLTEXT Indexes**

```sql
ALTER TABLE wp_posts 
ADD FULLTEXT INDEX ft_search (post_title, post_content);

-- Then search:
SELECT * FROM wp_posts
WHERE MATCH(post_title, post_content) 
AGAINST ('search query' IN BOOLEAN MODE);
```

2. **Search Plugins:**
- **SearchWP:** Builds inverted index in MySQL
- **ElasticPress:** Uses Elasticsearch (BM25)
- **Relevanssi:** Custom inverted index in WordPress

---

# Usage
index = InvertedIndex()
index.add_document(1, "Python is a great programming language")
index.add_document(2, "Java is also a programming language")
index.add_document(3, "Cooking recipes and tips")

results = index.search("programming language")
print(f"Documents matching 'programming language': {results}")
# Output: [1, 2]

idf = index.calculate_idf("python")
print(f"IDF for 'python': {idf:.2f}")
# Output: 0.41 (positive - rare term)
```

---

## 🎓 Key Takeaways

### The Big Picture

1. **Inverted indexes** trade space for speed (store more, search faster)
2. **TF** measures term importance within a document
3. **IDF** measures term importance across all documents
4. **BM25** combines TF and IDF with smart saturation and normalization
5. **Negative scores are normal** - only relative ranking matters

### Remember This

> **BM25 doesn't care whether scores are positive or negative.**  
> **It only cares about which document is the best match.**

### The Mental Model

```
Search Relevance = How often term appears (TF)
                   ×
                   How rare the term is (IDF)
                   ×
                   Smart adjustments (BM25 magic)
```

### When to Use What

```
┌────────────────────┬──────────────────────────┐
│ Use Case           │ Best Choice              │
├────────────────────┼──────────────────────────┤
│ Simple search      │ Natural Language Mode    │
│ Precise control    │ Boolean Mode             │
│ Vague queries      │ Query Expansion          │
│ Production system  │ BM25 scoring             │
│ Learning/prototype │ TF-IDF                   │
└────────────────────┴──────────────────────────┘
```

---

## 🚀 Next Steps

1. **Experiment:** Try the Python code example above
2. **Explore:** Add FULLTEXT indexes to a MySQL database
3. **Compare:** Test Natural vs Boolean vs Query Expansion modes
4. **Optimize:** Tune BM25 parameters (k₁, b) for your use case
5. **Scale:** Consider Elasticsearch for large-scale deployments

---
