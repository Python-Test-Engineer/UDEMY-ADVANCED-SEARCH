# Inverted Index - Detailed Explanation

Let me expand on how inverted indexes actually work under the hood.

## The Core Concept

An inverted index is called "inverted" because it reverses the natural document structure:

**Forward index** (natural): Document → Words it contains
**Inverted index**: Word → Documents that contain it

This inversion is what makes searching fast.

## Building an Inverted Index

Let's walk through creating an inverted index with real examples:

### Step 1: Start with Documents

```
Doc 1: "The quick brown fox jumps over the lazy dog"
Doc 2: "The lazy cat sleeps all day"
Doc 3: "Quick brown dogs run fast"
```

### Step 2: Tokenization

Break each document into individual words (tokens):

```
Doc 1: [the, quick, brown, fox, jumps, over, the, lazy, dog]
Doc 2: [the, lazy, cat, sleeps, all, day]
Doc 3: [quick, brown, dogs, run, fast]
```

### Step 3: Normalization

Clean up the tokens (lowercase, remove punctuation, handle plurals):

```
Doc 1: [the, quick, brown, fox, jump, over, the, lazy, dog]
Doc 2: [the, lazy, cat, sleep, all, day]
Doc 3: [quick, brown, dog, run, fast]
```

### Step 4: Build the Inverted Index

Create the mapping from each word to the documents containing it:

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

## Enhanced Inverted Index

Real-world inverted indexes store much more than just document IDs:

### Positions (for phrase searches)

```
"brown" → [
    Doc 1: positions [2],
    Doc 3: positions [1]
]
```

This lets you search for exact phrases like "quick brown" by checking if "quick" and "brown" appear next to each other.

### Frequency (for relevance scoring)

```
"the" → [
    Doc 1: frequency 2, positions [0, 6],
    Doc 2: frequency 1, positions [0]
]
```

Documents where a word appears more often might be more relevant.

### Complete Entry Example

```
"lazy" → {
    Doc 1: {
        frequency: 1,
        positions: [7],
        field: "content"
    },
    Doc 2: {
        frequency: 1,
        positions: [1],
        field: "content"
    }
}
```

## Searching with an Inverted Index

### Simple Single-Word Search

Query: "cat"

1. Look up "cat" in the index
2. Return: [Doc 2]
3. Done! (Lightning fast - just one lookup)

### Multi-Word Search (AND)

Query: "brown dog"

1. Look up "brown" → [Doc 1, Doc 3]
2. Look up "dog" → [Doc 1, Doc 3]
3. Find intersection → [Doc 1, Doc 3]
4. Return both documents

### Multi-Word Search (OR)

Query: "cat OR fox"

1. Look up "cat" → [Doc 2]
2. Look up "fox" → [Doc 1]
3. Find union → [Doc 1, Doc 2]
4. Return both documents

### Phrase Search

Query: "quick brown"

1. Look up "quick" → [Doc 1: pos [1], Doc 3: pos [0]]
2. Look up "brown" → [Doc 1: pos [2], Doc 3: pos [1]]
3. Check if positions are adjacent:
   - Doc 1: positions 1 and 2 ✓ (adjacent)
   - Doc 3: positions 0 and 1 ✓ (adjacent)
4. Return both documents

## Why It's So Fast

### Time Complexity Comparison

**Without inverted index (linear search):**
- Search 1,000 documents for "cat"
- Must read all 1,000 documents
- Time: O(n) where n = number of documents

**With inverted index:**
- Look up "cat" in hash table/tree
- Get list of matching documents
- Time: O(1) for lookup + O(k) where k = matching documents

For 1 million documents where only 10 contain "cat":
- Linear search: Check 1,000,000 documents
- Inverted index: Check 1 hash lookup + return 10 documents

That's a **100,000x speedup**!

## Real-World Optimizations

### Compression

Common words like "the" appear in millions of documents. The inverted index compresses these posting lists to save space:

```
Instead of: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
Store gaps: [1, +1, +1, +1, +1, +1, +1, +1, +1, +1]
Then compress the gaps efficiently
```

### Skip Lists

For very long posting lists, add "skip pointers" to jump ahead:

```
"the" → [Doc 1] → [Doc 50] → [Doc 200] → [Doc 500]
           ↓          ↓           ↓           ↓
        skip to     skip to     skip to     skip to
```

This speeds up intersection operations when combining multiple search terms.

### Tiered Indexes

Keep frequently accessed terms in memory, less common terms on disk:

```
Memory: Common words (the, and, or, etc.)
SSD: Medium frequency words
HDD: Rare words
```

## Inverted Index in WordPress

WordPress doesn't use a true inverted index by default. The native search does:

```sql
SELECT * FROM wp_posts 
WHERE post_content LIKE '%search term%'
```

This is slow because it scans every post.

**Better options:**

**SearchWP**: Builds an inverted index in MySQL tables
**ElasticPress**: Uses Elasticsearch (sophisticated inverted index)
**Relevanssi**: Creates custom inverted index tables in WordPress database

These plugins build structures like:

```
wp_searchindex:
term_id | term      | doc_id | frequency | positions
1       | wordpress | 42     | 3         | 5,12,89
1       | wordpress | 105    | 1         | 34
2       | plugin    | 42     | 2         | 15,92
```

## PHP Example

Here's how you might build a simple inverted index in PHP:

```php
<?php
class InvertedIndex {
    private $index = [];
    
    public function __construct() {
        $this->index = [];
    }
    
    /**
     * Add a document to the inverted index
     */
    public function addDocument($doc_id, $text) {
        // Tokenize and normalize
        $text = strtolower($text);
        preg_match_all('/\w+/', $text, $matches);
        $words = $matches[0];
        
        // Build index
        foreach ($words as $position => $word) {
            if (!isset($this->index[$word])) {
                $this->index[$word] = [];
            }
            
            $this->index[$word][] = [
                'doc_id' => $doc_id,
                'position' => $position
            ];
        }
    }
    
    /**
     * Search for a single word
     */
    public function search($query) {
        $query = strtolower($query);
        return isset($this->index[$query]) ? $this->index[$query] : [];
    }
    
    /**
     * Search for an exact phrase
     */
    public function searchPhrase($phrase) {
        $words = explode(' ', strtolower($phrase));
        
        if (empty($words)) {
            return [];
        }
        
        // Get postings for first word
        $results = $this->search($words[0]);
        
        if (empty($results)) {
            return [];
        }
        
        // Check if subsequent words appear in order
        $matches = [];
        
        foreach ($results as $posting) {
            $doc_id = $posting['doc_id'];
            $start_pos = $posting['position'];
            
            // Check if all words appear consecutively
            $valid = true;
            
            for ($i = 1; $i < count($words); $i++) {
                $word = $words[$i];
                $expected_pos = $start_pos + $i;
                
                // Look for word at expected position
                $found = false;
                
                if (isset($this->index[$word])) {
                    foreach ($this->index[$word] as $word_posting) {
                        if ($word_posting['doc_id'] === $doc_id && 
                            $word_posting['position'] === $expected_pos) {
                            $found = true;
                            break;
                        }
                    }
                }
                
                if (!$found) {
                    $valid = false;
                    break;
                }
            }
            
            if ($valid) {
                $matches[] = $doc_id;
            }
        }
        
        return array_unique($matches);
    }
    
    /**
     * Search with AND logic (all words must be present)
     */
    public function searchAnd($query) {
        $words = explode(' ', strtolower($query));
        
        if (empty($words)) {
            return [];
        }
        
        // Get document IDs for each word
        $doc_sets = [];
        foreach ($words as $word) {
            $postings = $this->search($word);
            $doc_ids = array_map(function($posting) {
                return $posting['doc_id'];
            }, $postings);
            $doc_sets[] = array_unique($doc_ids);
        }
        
        // Find intersection
        if (empty($doc_sets)) {
            return [];
        }
        
        $result = $doc_sets[0];
        for ($i = 1; $i < count($doc_sets); $i++) {
            $result = array_intersect($result, $doc_sets[$i]);
        }
        
        return array_values($result);
    }
    
    /**
     * Search with OR logic (any word can be present)
     */
    public function searchOr($query) {
        $words = explode(' ', strtolower($query));
        
        $all_doc_ids = [];
        foreach ($words as $word) {
            $postings = $this->search($word);
            foreach ($postings as $posting) {
                $all_doc_ids[] = $posting['doc_id'];
            }
        }
        
        return array_unique($all_doc_ids);
    }
    
    /**
     * Get the entire index (for debugging)
     */
    public function getIndex() {
        return $this->index;
    }
}

// Usage Example
$index = new InvertedIndex();

// Add documents
$index->addDocument(1, "The quick brown fox jumps over the lazy dog");
$index->addDocument(2, "The lazy cat sleeps all day");
$index->addDocument(3, "Quick brown dogs run fast");

// Single word search
echo "Search for 'brown':\n";
$results = $index->search("brown");
foreach ($results as $result) {
    echo "Doc {$result['doc_id']} at position {$result['position']}\n";
}

// Phrase search
echo "\nPhrase search for 'quick brown':\n";
$phrase_results = $index->searchPhrase("quick brown");
print_r($phrase_results);

// AND search
echo "\nAND search for 'brown dog':\n";
$and_results = $index->searchAnd("brown dog");
print_r($and_results);

// OR search
echo "\nOR search for 'cat fox':\n";
$or_results = $index->searchOr("cat fox");
print_r($or_results);
?>
```

### WordPress Integration Example

Here's how you might integrate this into WordPress:

```php
<?php
// In your WordPress plugin or theme functions.php

class WP_Inverted_Index {
    private $index;
    private $table_name;
    
    public function __construct() {
        global $wpdb;
        $this->table_name = $wpdb->prefix . 'inverted_index';
        $this->index = new InvertedIndex();
    }
    
    /**
     * Index all published posts
     */
    public function indexAllPosts() {
        $posts = get_posts([
            'post_type' => 'post',
            'post_status' => 'publish',
            'posts_per_page' => -1
        ]);
        
        foreach ($posts as $post) {
            $content = $post->post_title . ' ' . $post->post_content;
            $this->index->addDocument($post->ID, $content);
        }
    }
    
    /**
     * Search posts using inverted index
     */
    public function searchPosts($query) {
        $doc_ids = $this->index->searchAnd($query);
        
        if (empty($doc_ids)) {
            return [];
        }
        
        return get_posts([
            'post__in' => $doc_ids,
            'post_type' => 'post',
            'post_status' => 'publish'
        ]);
    }
}

// Hook into WordPress
add_action('init', function() {
    $wp_index = new WP_Inverted_Index();
    // Index posts on init (in production, do this on save_post hook)
    // $wp_index->indexAllPosts();
});
?>
```

## Key Takeaways

1. **Inverted indexes trade space for speed** - use more storage to get faster searches
2. **They're the foundation of all modern search engines** - Google, Elasticsearch, Solr all use them
3. **The "inversion" is the key insight** - instead of document→words, use word→documents
4. **They enable complex queries efficiently** - AND, OR, phrase searches, proximity searches
5. **Real implementations are highly optimized** - compression, caching, distributed storage

This is why searching billions of web pages on Google takes milliseconds instead of hours!