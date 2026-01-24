# 14.9 Full-Text Search Functions

MATCH (col1,col2,...) AGAINST (expr [search_modifier])

search_modifier:
  {
       IN NATURAL LANGUAGE MODE
     | IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION
     | IN BOOLEAN MODE
     | WITH QUERY EXPANSION
  }
MySQL has support for full-text indexing and searching:

A full-text index in MySQL is an index of type FULLTEXT.

Full-text indexes can be used only with InnoDB or MyISAM tables, and can be created only for CHAR, VARCHAR, or TEXT columns.

MySQL provides a built-in full-text ngram parser that supports Chinese, Japanese, and Korean (CJK), and an installable MeCab full-text parser plugin for Japanese. Parsing differences are outlined in Section 14.9.8, “ngram Full-Text Parser”, and Section 14.9.9, “MeCab Full-Text Parser Plugin”.

A FULLTEXT index definition can be given in the CREATE TABLE statement when a table is created, or added later using ALTER TABLE or CREATE INDEX.

For large data sets, it is much faster to load your data into a table that has no FULLTEXT index and then create the index after that, than to load data into a table that has an existing FULLTEXT index.

Full-text searching is performed using MATCH() AGAINST() syntax. MATCH() takes a comma-separated list that names the columns to be searched. AGAINST takes a string to search for, and an optional modifier that indicates what type of search to perform. The search string must be a string value that is constant during query evaluation. This rules out, for example, a table column because that can differ for each row.

MySQL does not permit the use of a rollup column with MATCH(); more specifically, any query matching all of the criteria listed here is rejected with ER_FULLTEXT_WITH_ROLLUP:

MATCH() appears in the SELECT list, GROUP BY clause, HAVING clause, or ORDER BY clause of a query block.

The query block contains a GROUP BY ... WITH ROLLUP clause.

The argument of the call to the MATCH() function is one of the grouping columns.

Some examples of such queries are shown here:

# MATCH() in SELECT list...
SELECT MATCH (a) AGAINST ('abc') FROM t GROUP BY a WITH ROLLUP;
SELECT 1 FROM t GROUP BY a, MATCH (a) AGAINST ('abc') WITH ROLLUP;

# ...in HAVING clause...
SELECT 1 FROM t GROUP BY a WITH ROLLUP HAVING MATCH (a) AGAINST ('abc');

# ...and in ORDER BY clause
SELECT 1 FROM t GROUP BY a WITH ROLLUP ORDER BY MATCH (a) AGAINST ('abc');
The use of MATCH() with a rollup column in the WHERE clause is permitted.

There are three types of full-text searches:

A natural language search interprets the search string as a phrase in natural human language (a phrase in free text). There are no special operators, with the exception of double quote (") characters. The stopword list applies. For more information about stopword lists, see Section 14.9.4, “Full-Text Stopwords”.

Full-text searches are natural language searches if the IN NATURAL LANGUAGE MODE modifier is given or if no modifier is given. For more information, see Section 14.9.1, “Natural Language Full-Text Searches”.

A boolean search interprets the search string using the rules of a special query language. The string contains the words to search for. It can also contain operators that specify requirements such that a word must be present or absent in matching rows, or that it should be weighted higher or lower than usual. Certain common words (stopwords) are omitted from the search index and do not match if present in the search string. The IN BOOLEAN MODE modifier specifies a boolean search. For more information, see Section 14.9.2, “Boolean Full-Text Searches”.

A query expansion search is a modification of a natural language search. The search string is used to perform a natural language search. Then words from the most relevant rows returned by the search are added to the search string and the search is done again. The query returns the rows from the second search. The IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION or WITH QUERY EXPANSION modifier specifies a query expansion search. For more information, see Section 14.9.3, “Full-Text Searches with Query Expansion”.

For information about FULLTEXT query performance, see Section 10.3.5, “Column Indexes”.

For more information about InnoDB FULLTEXT indexes, see Section 17.6.2.4, “InnoDB Full-Text Indexes”.

Constraints on full-text searching are listed in Section 14.9.5, “Full-Text Restrictions”.

The myisam_ftdump utility dumps the contents of a MyISAM full-text index. This may be helpful for debugging full-text queries. See Section 6.6.3, “myisam_ftdump — Display Full-Text Index information”.

