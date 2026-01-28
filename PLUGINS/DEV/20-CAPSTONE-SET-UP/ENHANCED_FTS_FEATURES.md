# Enhanced Full-Text Search Index Features

## Overview
The enhanced plugin now provides complete control over FTS (Full-Text Search) index configuration with the ability to:
1. Select which fields to include in the index
2. View the current index name and indexed fields
3. Delete and recreate indexes with different configurations

## New Features

### 1. **Field Selection**
When creating a new FTS index, you can now choose which fields to include:

- ✅ **post_title** - Post titles (Recommended)
- ✅ **post_content** - Post content/body (Recommended)
- ☐ **categories** - Post categories
- ☐ **tags** - Post tags
- ☐ **custom_meta_data** - Custom fields and ACF data

**Default Selection**: post_title and post_content are pre-checked as they provide the best search results.

### 2. **Index Information Display**
When an index exists, the interface now shows:
- **Status**: ✅ Created or ❌ Not Created
- **Index Name**: The actual MySQL index name (e.g., `fulltext_idx_post_post`)
- **Indexed Fields**: List of all fields included in the index (e.g., `post_title, post_content`)

### 3. **Delete and Recreate**
You can now:
- Delete an existing index with the "Delete Index" button
- Create a new index with different field selections
- Experiment with different index configurations

### 4. **Dynamic Index Naming**
The index name is automatically generated based on selected fields:
- Format: `fulltext_idx_[abbreviated_field_names]`
- Example: Selecting post_title and post_content creates `fulltext_idx_post_post`
- This helps identify which fields are indexed

## Usage Instructions

### Creating a New Index
1. Navigate to **RAG Manager** in WordPress admin
2. Scroll to the **Full-Text Search Index** section
3. Select the fields you want to include in the index
4. Click **Create Full-Text Index**
5. The page will refresh showing the new index details

### Deleting an Index
1. Navigate to **RAG Manager** in WordPress admin
2. Scroll to the **Full-Text Search Index** section
3. Click **Delete Index** button
4. Confirm the deletion
5. The page will refresh, allowing you to create a new index

### Best Practices

#### Recommended Configuration
- **For general search**: Select `post_title` and `post_content`
- **For comprehensive search**: Add `categories` and `tags`
- **For custom field search**: Add `custom_meta_data`

#### Performance Considerations
- More fields = larger index = potentially slower indexing
- But: More fields = more comprehensive search results
- Balance based on your needs

#### When to Include Additional Fields
- **Include categories/tags** if users search by topic/classification
- **Include custom_meta_data** if you have important ACF or custom fields

## Technical Changes

### New AJAX Actions
```php
// Get current index information
add_action('wp_ajax_get_fulltext_index_info', array($this, 'ajax_get_fulltext_index_info'));

// Delete existing index
add_action('wp_ajax_delete_fulltext_index', array($this, 'ajax_delete_fulltext_index'));

// Enhanced create index (now accepts field selection)
add_action('wp_ajax_create_fulltext_index', array($this, 'ajax_create_fulltext_index'));
```

### New Methods
- `get_fulltext_index_info()` - Returns detailed index information
- `delete_fulltext_index()` - Removes the current FTS index
- Enhanced `create_fulltext_index($fields)` - Accepts array of fields to index

### Database Changes
No schema changes required - the enhancement works with your existing table structure.

## Migration from Old Version

If you're upgrading from the previous version:

1. **Existing index remains**: Your current index will continue working
2. **Index information displayed**: You'll now see the index name and fields
3. **Delete and recreate**: You can delete and create a new optimized index

**Note**: The old version created an index named `fulltext_search_idx` on all fields. The new version creates custom-named indexes based on selected fields.

## Troubleshooting

### "A full-text index already exists"
- Delete the existing index first using the "Delete Index" button
- Then create a new one with your desired configuration

### No fields available to select
- Ensure your posts_rag table exists and has the correct columns
- Check that the plugin is properly activated

### Index creation fails
- Check MySQL error logs
- Ensure your MySQL version supports FULLTEXT indexes (MySQL 5.6+)
- Verify table engine is InnoDB or MyISAM

## Example Configurations

### Configuration 1: Basic Search
**Fields**: post_title, post_content
**Best for**: General blog/content search
**Index name**: fulltext_idx_post_post

### Configuration 2: Comprehensive Search
**Fields**: post_title, post_content, categories, tags
**Best for**: Sites with well-organized taxonomy
**Index name**: fulltext_idx_post_post_categ_tags_

### Configuration 3: Advanced Search
**Fields**: All fields including custom_meta_data
**Best for**: Sites with extensive custom fields
**Index name**: fulltext_idx_post_post_categ_tags_custo

## API Compatibility

The REST API endpoints remain unchanged:
```
GET /wp-json/posts-rag/v1/search?query=FOAM&limit=3
```

The search will automatically use whichever index exists, regardless of which fields it contains.
