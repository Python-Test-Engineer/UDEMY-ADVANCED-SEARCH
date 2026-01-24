# 14.9.5 Full-Text Restrictions

Full-text searches are supported for InnoDB and MyISAM tables only.

Full-text searches are not supported for partitioned tables. See Section 26.6, “Restrictions and Limitations on Partitioning”.

Full-text searches can be used with most multibyte character sets. The exception is that for Unicode, the utf8mb3 or utf8mb4 character set can be used, but not the ucs2 character set. Although FULLTEXT indexes on ucs2 columns cannot be used, you can perform IN BOOLEAN MODE searches on a ucs2 column that has no such index.

The remarks for utf8mb3 also apply to utf8mb4, and the remarks for ucs2 also apply to utf16, utf16le, and utf32.

Ideographic languages such as Chinese and Japanese do not have word delimiters. Therefore, the built-in full-text parser cannot determine where words begin and end in these and other such languages.

A character-based ngram full-text parser that supports Chinese, Japanese, and Korean (CJK), and a word-based MeCab parser plugin that supports Japanese are provided for use with InnoDB and MyISAM tables.

Although the use of multiple character sets within a single table is supported, all columns in a FULLTEXT index must use the same character set and collation.

The MATCH() column list must match exactly the column list in some FULLTEXT index definition for the table, unless this MATCH() is IN BOOLEAN MODE on a MyISAM table. For MyISAM tables, boolean-mode searches can be done on nonindexed columns, although they are likely to be slow.

The argument to AGAINST() must be a string value that is constant during query evaluation. This rules out, for example, a table column because that can differ for each row.

The argument to MATCH() cannot use a rollup column.

Index hints are more limited for FULLTEXT searches than for non-FULLTEXT searches. See Section 10.9.4, “Index Hints”.

For InnoDB, all DML operations (INSERT, UPDATE, DELETE) involving columns with full-text indexes are processed at transaction commit time. For example, for an INSERT operation, an inserted string is tokenized and decomposed into individual words. The individual words are then added to full-text index tables when the transaction is committed. As a result, full-text searches only return committed data.

The '%' character is not a supported wildcard character for full-text searches.

