## `>` and `<` Operators in Boolean Full-Text Search

### `>` (Greater Than) - INCREASE RELEVANCE

**Meaning:** Boosts the importance of a word in relevance scoring

**Usage:** `>word`

**Effect:**
- Word is OPTIONAL (not required)
- If the word appears, it contributes MORE to the relevance score
- Results with this word rank HIGHER

**Example:**
```
camera >4K
```
- Finds products with "camera" (optional)
- If product also has "4K", it gets a HIGHER relevance score
- Results sorted: products with both rank first, then just "camera"

---

### `<` (Less Than) - DECREASE RELEVANCE

**Meaning:** Reduces the importance of a word in relevance scoring

**Usage:** `<word`

**Effect:**
- Word is OPTIONAL (not required)
- If the word appears, it contributes LESS to the relevance score
- Results with this word rank LOWER (but still included)

**Example:**
```
speaker <bluetooth
```
- Finds products with "speaker" (optional)
- If product has "bluetooth", it gets a LOWER relevance score
- Results sorted: speakers without bluetooth rank higher

---

## Combined Example

```
>premium <budget
```

**Means:**
- Look for products with "premium" and/or "budget"
- Products with "premium" get HIGHER scores (ranked first)
- Products with "budget" get LOWER scores (ranked last)
- Products with both get a mixed score

**Results ranking:**
1. Premium products (highest)
2. Products with both premium and budget (middle)
3. Budget products (lowest)

---

## Practical Examples

### Prefer wireless over wired:
```
+speaker >wireless <wired
```
- Must have "speaker"
- Prefer wireless (ranks higher)
- Wired is ok but ranks lower

### Prefer professional features:
```
+camera >professional <amateur
```
- Must have "camera"
- Professional cameras rank higher
- Amateur cameras rank lower

### Complex ranking:
```
>premium >quality <cheap <budget
```
- Prefer "premium" and "quality" (high rank)
- De-prioritize "cheap" and "budget" (low rank)

---

## Important Notes

⚠️ **These operators affect RANKING, not filtering:**
- `>word` doesn't exclude results without the word
- `<word` doesn't exclude results with the word
- They only change the ORDER of results

**If you want to exclude:** Use `-word` instead

**If you want to require:** Use `+word` instead

---

## Summary Table

| Operator | Effect | Required? | Ranking |
|----------|--------|-----------|---------|
| `+word` | Must have | YES | Normal |  
| `-word` | Must NOT have | NO (excluded) | N/A |
| `>word` | Boost importance | NO (optional) | Higher if present |
| `<word` | Reduce importance | NO (optional) | Lower if present |
| `word` | Normal | NO (optional) | Normal if present |

- '*' wildcard not supported in MySQL

- '+' required as you must have something in BOOLEAN