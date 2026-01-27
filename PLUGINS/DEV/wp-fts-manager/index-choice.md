Here’s what I found in `PLUGINS/DEV/wp-fts-manager/wp-fts-manager.php` about index selection and whether SQL can target a specific FTS index:

## ✅ How the search uses the selected index
The plugin **does not explicitly choose an index name in SQL**. Instead, it:
1. Takes the selected index name from the UI (`index_name`).
2. Runs `SHOW INDEX ... WHERE Key_name = %s` to fetch that index’s **column list**.
3. Builds the query using `MATCH(column1, column2, ...) AGAINST(...)`.

So the selected index is used **indirectly**—by matching on the same **columns** that belong to the chosen index. The query is built in `ajax_run_query()`:

```php
$index_info = $wpdb->get_results($wpdb->prepare(
    "SHOW INDEX FROM {$this->table_name} WHERE Key_name = %s",
    $index_name
));
...
$columns_str = implode(', ', $columns);

$sql = $wpdb->prepare(
    "SELECT ...
     MATCH({$columns_str}) AGAINST (...)
     WHERE MATCH({$columns_str}) AGAINST (...)",
    $search_query, $search_query, $limit
);
```

## ✅ Can SQL FTS select a specific index?
**No—MySQL doesn’t allow you to directly specify the FULLTEXT index name in a `MATCH ... AGAINST` query.**

Instead, MySQL chooses the appropriate FULLTEXT index **based on the columns listed inside `MATCH()`**. That’s exactly what this plugin does: the selected index determines the **column list**, and the column list implicitly selects the index.

### ✅ Summary
- **Index is selected by columns, not by name.**
- **MySQL does not support `USE INDEX` for FULLTEXT indexes** in the same way as B-Tree indexes (and you can’t force a FULLTEXT index by name).
- To choose a specific FULLTEXT index, you must build `MATCH()` with the same column set used by that index.

### ✅ Practical note for this plugin
Because the UI asks you to select an index, the plugin simply looks up that index’s **columns** and builds `MATCH(col1, col2, ...)`. That column list is what MySQL uses to pick the FULLTEXT index. If two FULLTEXT indexes share the exact same column set, MySQL may treat them as equivalent, so choosing between those two by name is not possible in SQL.

If you want, I can suggest a small UI/SQL change to make the selected index more explicit or add guardrails if multiple indexes share the same column set.