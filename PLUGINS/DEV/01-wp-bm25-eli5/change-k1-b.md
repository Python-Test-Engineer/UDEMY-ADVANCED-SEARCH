# Change k1 and b

- **k1**: Higher values give more weight to term frequency. Lower k1 means diminishing returns kick in faster for repeated terms. Frequency is DAMPENED.

- **b**: Controls how much document length affects scoring. b=1 means full normalization (shorter documents favored), b=0 means no normalization so length is not a factor.

## k1 - The "Repetition Matters" Knob

- Adjust **k1** if repeated keywords should matter more/less

Think of k1 as controlling how much you care when a word appears multiple times in a document.

- **Higher k1 (like 2.0)**: "If a word appears 10 times vs 2 times, that's a BIG deal! This document is probably way more relevant."
- **Lower k1 (like 0.5)**: "Okay, the word appears more, but after the first few times, I don't care that much anymore."

**Example**: Searching for "pizza"
- Document A mentions "pizza" 20 times
- Document B mentions "pizza" 3 times
- High k1 → Document A ranks WAY higher
- Low k1 → Document A ranks only somewhat higher

## b - The "Length Penalty" Knob

- Adjust **b** if document length should matter more/less

Think of b as controlling whether you penalize long documents.

- **b = 1**: "Long documents should be penalized. A short document with the word once is better than a long document with the word once."
- **b = 0**: "Length doesn't matter at all. Just count the words."
- **b = 0.75 (default)**: "Somewhere in between - slightly penalize long documents."

**Example**: Both documents mention "pizza" twice
- Document A: 50 words total
- Document B: 500 words total
- High b (like 0.9) → Document A ranks higher (shorter = better)
- Low b (like 0.1) → Both rank similarly

## Quick Rule of Thumb:
- Adjust **k1** if repeated keywords should matter more/less
- Adjust **b** if document length should matter more/less
MySQL's full-text search uses BM25 as the ranking algorithm (since MySQL 5.7), and you can adjust these parameters using system variables:

- **`innodb_ft_bm25_k1`** - Controls term frequency saturation (default: 2.0, range: 0.01 to 1000)
- **`innodb_ft_bm25_b`** - Controls document length normalization (default: 0.75, range: 0 to 1)

## How to change them:

**Session-level** (temporary, only for current connection):
```sql
SET SESSION innodb_ft_bm25_k1 = 1.5;
SET SESSION innodb_ft_bm25_b = 0.5;
```

**Global-level** (persists for new connections):
```sql
SET GLOBAL innodb_ft_bm25_k1 = 1.5;
SET GLOBAL innodb_ft_bm25_b = 0.5;
```

**Permanently** (in my.cnf or my.ini):
```ini
[mysqld]
innodb_ft_bm25_k1 = 1.5
innodb_ft_bm25_b = 0.5
```

## What they do:

- **k1**: Higher values give more weight to term frequency. Lower k1 means diminishing returns kick in faster for repeated terms.
- **b**: Controls how much document length affects scoring. b=1 means full normalization (shorter documents favored), b=0 means no normalization.

If you're working with Python and MySQL, you'd typically set these before running your full-text queries using your database connector (like `mysql-connector-python` or `pymysql`).