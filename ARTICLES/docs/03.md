# 14.9.2 Boolean Full-Text Searches

MySQL can perform boolean full-text searches using the IN BOOLEAN MODE modifier. With this modifier, certain characters have special meaning at the beginning or end of words in the search string. In the following query, the + and - operators indicate that a word must be present or absent, respectively, for a match to occur. Thus, the query retrieves all the rows that contain the word “MySQL” but that do not contain the word “YourSQL”:

SELECT * FROM articles WHERE MATCH (title,body)
 AGAINST ('+MySQL -YourSQL' IN BOOLEAN MODE);

+----+-----------------------+-------------------------------------+
| id | title                 | body                                |
+----+-----------------------+-------------------------------------+
|  1 | MySQL Tutorial        | DBMS stands for DataBase ...        |
|  2 | How To Use MySQL Well | After you went through a ...        |
|  3 | Optimizing MySQL      | In this tutorial, we show ...       |
|  4 | 1001 MySQL Tricks     | 1. Never run mysqld as root. 2. ... |
|  6 | MySQL Security        | When configured properly, MySQL ... |
+----+-----------------------+-------------------------------------+
Note
In implementing this feature, MySQL uses what is sometimes referred to as implied Boolean logic, in which

+ stands for AND

- stands for NOT

[no operator] implies OR

Boolean full-text searches have these characteristics:

They do not automatically sort rows in order of decreasing relevance.

InnoDB tables require a FULLTEXT index on all columns of the MATCH() expression to perform boolean queries. Boolean queries against a MyISAM search index can work even without a FULLTEXT index, although a search executed in this fashion would be quite slow.

The minimum and maximum word length full-text parameters apply to FULLTEXT indexes created using the built-in FULLTEXT parser and MeCab parser plugin. innodb_ft_min_token_size and innodb_ft_max_token_size are used for InnoDB search indexes. ft_min_word_len and ft_max_word_len are used for MyISAM search indexes.

Minimum and maximum word length full-text parameters do not apply to FULLTEXT indexes created using the ngram parser. ngram token size is defined by the ngram_token_size option.

The stopword list applies, controlled by innodb_ft_enable_stopword, innodb_ft_server_stopword_table, and innodb_ft_user_stopword_table for InnoDB search indexes, and ft_stopword_file for MyISAM ones.

InnoDB full-text search does not support the use of multiple operators on a single search word, as in this example: '++apple'. Use of multiple operators on a single search word returns a syntax error to standard out. MyISAM full-text search successfully processes the same search, ignoring all operators except for the operator immediately adjacent to the search word.

InnoDB full-text search only supports leading plus or minus signs. For example, InnoDB supports '+apple' but does not support 'apple+'. Specifying a trailing plus or minus sign causes InnoDB to report a syntax error.

InnoDB full-text search does not support the use of a leading plus sign with wildcard ('+*'), a plus and minus sign combination ('+-'), or leading a plus and minus sign combination ('+-apple'). These invalid queries return a syntax error.

InnoDB full-text search does not support the use of the @ symbol in boolean full-text searches. The @ symbol is reserved for use by the @distance proximity search operator.

They do not use the 50% threshold that applies to MyISAM search indexes.

The boolean full-text search capability supports the following operators:

+

A leading or trailing plus sign indicates that this word must be present in each row that is returned. InnoDB only supports leading plus signs.

-

A leading or trailing minus sign indicates that this word must not be present in any of the rows that are returned. InnoDB only supports leading minus signs.

Note: The - operator acts only to exclude rows that are otherwise matched by other search terms. Thus, a boolean-mode search that contains only terms preceded by - returns an empty result. It does not return “all rows except those containing any of the excluded terms.”

(no operator)

By default (when neither + nor - is specified), the word is optional, but the rows that contain it are rated higher. This mimics the behavior of MATCH() AGAINST() without the IN BOOLEAN MODE modifier.

@distance

This operator works on InnoDB tables only. It tests whether two or more words all start within a specified distance from each other, measured in words. Specify the search words within a double-quoted string immediately before the @distance operator, for example, MATCH(col1) AGAINST('"word1 word2 word3" @8' IN BOOLEAN MODE)

> <

These two operators are used to change a word's contribution to the relevance value that is assigned to a row. The > operator increases the contribution and the < operator decreases it. See the example following this list.

( )

Parentheses group words into subexpressions. Parenthesized groups can be nested.

~

A leading tilde acts as a negation operator, causing the word's contribution to the row's relevance to be negative. This is useful for marking “noise” words. A row containing such a word is rated lower than others, but is not excluded altogether, as it would be with the - operator.

*

The asterisk serves as the truncation (or wildcard) operator. Unlike the other operators, it is appended to the word to be affected. Words match if they begin with the word preceding the * operator.

If a word is specified with the truncation operator, it is not stripped from a boolean query, even if it is too short or a stopword. Whether a word is too short is determined from the innodb_ft_min_token_size setting for InnoDB tables, or ft_min_word_len for MyISAM tables. These options are not applicable to FULLTEXT indexes that use the ngram parser.

The wildcarded word is considered as a prefix that must be present at the start of one or more words. If the minimum word length is 4, a search for '+word +the*' could return fewer rows than a search for '+word +the', because the second query ignores the too-short search term the.

"

A phrase that is enclosed within double quote (") characters matches only rows that contain the phrase literally, as it was typed. The full-text engine splits the phrase into words and performs a search in the FULLTEXT index for the words. Nonword characters need not be matched exactly: Phrase searching requires only that matches contain exactly the same words as the phrase and in the same order. For example, "test phrase" matches "test, phrase".

If the phrase contains no words that are in the index, the result is empty. The words might not be in the index because of a combination of factors: if they do not exist in the text, are stopwords, or are shorter than the minimum length of indexed words.

The following examples demonstrate some search strings that use boolean full-text operators:

'apple banana'

Find rows that contain at least one of the two words.

'+apple +juice'

Find rows that contain both words.

'+apple macintosh'

Find rows that contain the word “apple”, but rank rows higher if they also contain “macintosh”.

'+apple -macintosh'

Find rows that contain the word “apple” but not “macintosh”.

'+apple ~macintosh'

Find rows that contain the word “apple”, but if the row also contains the word “macintosh”, rate it lower than if row does not. This is “softer” than a search for '+apple -macintosh', for which the presence of “macintosh” causes the row not to be returned at all.

'+apple +(>turnover <strudel)'

Find rows that contain the words “apple” and “turnover”, or “apple” and “strudel” (in any order), but rank “apple turnover” higher than “apple strudel”.

'apple*'

Find rows that contain words such as “apple”, “apples”, “applesauce”, or “applet”.

'"some words"'

Find rows that contain the exact phrase “some words” (for example, rows that contain “some words of wisdom” but not “some noise words”). Note that the " characters that enclose the phrase are operator characters that delimit the phrase. They are not the quotation marks that enclose the search string itself.

Relevancy Rankings for InnoDB Boolean Mode Search
InnoDB full-text search is modeled on the Sphinx full-text search engine, and the algorithms used are based on BM25 and TF-IDF ranking algorithms. For these reasons, relevancy rankings for InnoDB boolean full-text search may differ from MyISAM relevancy rankings.

InnoDB uses a variation of the “term frequency-inverse document frequency” (TF-IDF) weighting system to rank a document's relevance for a given full-text search query. The TF-IDF weighting is based on how frequently a word appears in a document, offset by how frequently the word appears in all documents in the collection. In other words, the more frequently a word appears in a document, and the less frequently the word appears in the document collection, the higher the document is ranked.

How Relevancy Ranking is Calculated
The term frequency (TF) value is the number of times that a word appears in a document. The inverse document frequency (IDF) value of a word is calculated using the following formula, where total_records is the number of records in the collection, and matching_records is the number of records that the search term appears in.

${IDF} = log10( ${total_records} / ${matching_records} )
When a document contains a word multiple times, the IDF value is multiplied by the TF value:

${TF} * ${IDF}
Using the TF and IDF values, the relevancy ranking for a document is calculated using this formula:

${rank} = ${TF} * ${IDF} * ${IDF}
The formula is demonstrated in the following examples.

Relevancy Ranking for a Single Word Search
This example demonstrates the relevancy ranking calculation for a single-word search.

CREATE TABLE articles (
  id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
  title VARCHAR(200),
  body TEXT,
  FULLTEXT (title,body)
 )  ENGINE=InnoDB;
Query OK, 0 rows affected (1.04 sec)

INSERT INTO articles (title,body) VALUES
('MySQL Tutorial','This database tutorial ...'),
("How To Use MySQL",'After you went through a ...'),
('Optimizing Your Database','In this database tutorial ...'),
('MySQL vs. YourSQL','When comparing databases ...'),
('MySQL Security','When configured properly, MySQL ...'),
('Database, Database, Database','database database database'),
('1001 MySQL Tricks','1. Never run mysqld as root. 2. ...'),
('MySQL Full-Text Indexes', 'MySQL fulltext indexes use a ..');

Query OK, 8 rows affected (0.06 sec)
Records: 8  Duplicates: 0  Warnings: 0

SELECT id, title, body, 
MATCH (title,body) AGAINST ('database' IN BOOLEAN MODE) AS score
FROM articles ORDER BY score DESC;

+----+------------------------------+-------------------------------------+---------------------+
| id | title                        | body                                | score               |
+----+------------------------------+-------------------------------------+---------------------+
|  6 | Database, Database, Database | database database database          |  1.0886961221694946 |
|  3 | Optimizing Your Database     | In this database tutorial ...       | 0.36289870738983154 |
|  1 | MySQL Tutorial               | This database tutorial ...          | 0.18144935369491577 |
|  2 | How To Use MySQL             | After you went through a ...        |                   0 |
|  4 | MySQL vs. YourSQL            | When comparing databases ...        |                   0 |
|  5 | MySQL Security               | When configured properly, MySQL ... |                   0 |
|  7 | 1001 MySQL Tricks            | 1. Never run mysqld as root. 2. ... |                   0 |
|  8 | MySQL Full-Text Indexes      | MySQL fulltext indexes use a ..     |                   0 |
+----+------------------------------+-------------------------------------+---------------------+
8 rows in set (0.00 sec)

There are 8 records in total, with 3 that match the “database” search term. The first record (id 6) contains the search term 6 times and has a relevancy ranking of 1.0886961221694946. This ranking value is calculated using a TF value of 6 (the “database” search term appears 6 times in record id 6) and an IDF value of 0.42596873216370745, which is calculated as follows (where 8 is the total number of records and 3 is the number of records that the search term appears in):

${IDF} = LOG10( 8 / 3 ) = 0.42596873216370745
The TF and IDF values are then entered into the ranking formula:

${rank} = ${TF} * ${IDF} * ${IDF}
Performing the calculation in the MySQL command-line client returns a ranking value of 1.088696164686938.

SELECT 6*LOG10(8/3)*LOG10(8/3);

+-------------------------+
| 6*LOG10(8/3)*LOG10(8/3) |
+-------------------------+
|       1.088696164686938 |
+-------------------------+
1 row in set (0.00 sec)
Note
You may notice a slight difference in the ranking values returned by the SELECT ... MATCH ... AGAINST statement and the MySQL command-line client (1.0886961221694946 versus 1.088696164686938). The difference is due to how the casts between integers and floats/doubles are performed internally by InnoDB (along with related precision and rounding decisions), and how they are performed elsewhere, such as in the MySQL command-line client or other types of calculators.

Relevancy Ranking for a Multiple Word Search
This example demonstrates the relevancy ranking calculation for a multiple-word full-text search based on the articles table and data used in the previous example.

If you search on more than one word, the relevancy ranking value is a sum of the relevancy ranking value for each word, as shown in this formula:

${rank} = ${TF} * ${IDF} * ${IDF} + ${TF} * ${IDF} * ${IDF}
Performing a search on two terms ('mysql tutorial') returns the following results:

SELECT id, title, body, MATCH (title,body)  
AGAINST ('mysql tutorial' IN BOOLEAN MODE) AS score
FROM articles ORDER BY score DESC;

+----+------------------------------+-------------------------------------+----------------------+
| id | title                        | body                                | score                |
+----+------------------------------+-------------------------------------+----------------------+
|  1 | MySQL Tutorial               | This database tutorial ...          |   0.7405621409416199 |
|  3 | Optimizing Your Database     | In this database tutorial ...       |   0.3624762296676636 |
|  5 | MySQL Security               | When configured properly, MySQL ... | 0.031219376251101494 |
|  8 | MySQL Full-Text Indexes      | MySQL fulltext indexes use a ..     | 0.031219376251101494 |
|  2 | How To Use MySQL             | After you went through a ...        | 0.015609688125550747 |
|  4 | MySQL vs. YourSQL            | When comparing databases ...        | 0.015609688125550747 |
|  7 | 1001 MySQL Tricks            | 1. Never run mysqld as root. 2. ... | 0.015609688125550747 |
|  6 | Database, Database, Database | database database database          |                    0 |
+----+------------------------------+-------------------------------------+----------------------+
8 rows in set (0.00 sec)

In the first record (id 8), 'mysql' appears once and 'tutorial' appears twice. There are six matching records for 'mysql' and two matching records for 'tutorial'. The MySQL command-line client returns the expected ranking value when inserting these values into the ranking formula for a multiple word search:

SELECT (1*log10(8/6)*log10(8/6)) + (2*log10(8/2)*log10(8/2));

+-------------------------------------------------------+
| (1*log10(8/6)*log10(8/6)) + (2*log10(8/2)*log10(8/2)) |
+-------------------------------------------------------+
|                                    0.7405621541938003 |
+-------------------------------------------------------+
1 row in set (0.00 sec)

Note
The slight difference in the ranking values returned by the SELECT ... MATCH ... AGAINST statement and the MySQL command-line client is explained in the preceding example.