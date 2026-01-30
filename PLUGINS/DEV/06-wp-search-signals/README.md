# WP Search Signals Plugin

A proof-of-concept WordPress plugin for capturing user interaction signals to enhance AI-powered search through machine learning.

## Overview

WP Search Signals records user behavior patterns during search interactions, creating a feedback loop that helps train and improve search relevance. By tracking what users click, hover over, and engage with, this plugin builds a dataset that reveals which search results are truly valuable to users—not just algorithmically relevant.

## What Problem Does This Solve?

Traditional search algorithms rank results based on keyword matching, content analysis, and link structures. However, they often miss the mark on what users actually find useful. This plugin bridges that gap by:

- **Capturing implicit feedback**: Recording what users actually click versus what they skip
- **Building training data**: Creating labeled datasets for machine learning models
- **Enabling personalization**: Tracking session-based patterns to understand user intent
- **Measuring search quality**: Providing metrics on result effectiveness

## Architecture

### Database Schema

The plugin creates a `wp_signals` table with the following structure:

```sql
CREATE TABLE wp_signals (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(128) NOT NULL,
    guid VARCHAR(36) NOT NULL,
    user_id BIGINT UNSIGNED DEFAULT 0,
    event_name VARCHAR(120) NOT NULL,
    query VARCHAR(255) NULL,
    results LONGTEXT NULL,
    event_meta_details LONGTEXT NULL,
    created_at DATETIME NOT NULL,
    KEY event_name (event_name),
    KEY user_id (user_id),
    KEY session_id (session_id)
);
```

**Key Fields:**
- `session_id`: Groups events by user session for behavioral analysis
- `guid`: Unique identifier for each event
- `event_name`: Type of interaction (search, click, hover)
- `query`: The search query that generated results
- `results`: JSON array of result IDs shown to the user
- `event_meta_details`: Additional context (position, timestamp, metadata)

### Component Structure

```
06-wp-search-signals/
├── 06-wp-search-signals.php    # Main plugin file
└── assets/
    ├── admin.js                 # Frontend event tracking
    └── styles.css               # UI styling
```

### Data Flow

```
User Action → JavaScript Event → AJAX Request → PHP Handler → Database
     ↓
Search Query → Hybrid Search API → Results Display → User Interaction
```

## How It Works

### 1. Search Event (`event_search`)

When a user performs a search:
```javascript
sendEvent('event_search', {
    results: [postId1, postId2, postId3],
    resultCount: 3
}, {
    query: "FOAM products",
    results: [123, 456, 789]
});
```

This records:
- The search query
- Which results were returned
- The order they appeared in
- Timestamp of the search

### 2. Hover Event (`event_hover`)

When a user hovers over a result (fired once per result):
```javascript
sendEvent('event_hover', {
    postId: 123,
    label: "Product Title"
});
```

This indicates the user is **considering** this result, providing a weak positive signal.

### 3. Click Event (`event_click`)

When a user clicks "Record Click" (or in production, clicks through to a result):
```javascript
sendEvent('event_click', {
    postId: 123,
    label: "Product Title"
});
```

This is a **strong positive signal** that the result was relevant to the user's query.

### Event Processing

All events flow through the `handle_log_event()` method:

```php
public function handle_log_event() {
    // Verify nonce and authentication
    check_ajax_referer(self::NONCE_ACTION, 'nonce');
    
    // Extract and sanitize data
    $event_name = sanitize_text_field($_POST['event_name']);
    $query = sanitize_text_field($_POST['query']);
    $results = wp_json_encode($_POST['results']);
    
    // Insert into database
    $wpdb->insert($table_name, [
        'session_id' => wp_get_session_token(),
        'guid' => wp_generate_uuid4(),
        'user_id' => get_current_user_id(),
        'event_name' => $event_name,
        'query' => $query,
        'results' => $results,
        'event_meta_details' => $event_meta_details,
        'created_at' => current_time('mysql')
    ]);
}
```

## User Signals in AI-Powered Search

### The Signal Types

**Explicit Signals:**
- Clicks (strong positive)
- Bookmarks/saves (very strong positive)
- Shares (strong positive)
- Time on page (moderate positive)

**Implicit Signals:**
- Hover duration (weak positive)
- Scroll depth (weak positive)
- Skips/ignores (negative)
- Immediate back navigation (strong negative)

### From Signals to Intelligence

#### 1. **Learning to Rank (LTR)**

Signals create training data for machine learning models:

```python
# Example training data structure
{
    "query": "FOAM products",
    "results": [
        {"post_id": 123, "position": 1, "clicked": true, "hovered": true},
        {"post_id": 456, "position": 2, "clicked": false, "hovered": true},
        {"post_id": 789, "position": 3, "clicked": false, "hovered": false}
    ]
}
```

The model learns that for this query, post 123 is most relevant because it was both hovered and clicked, while post 789 was ignored entirely.

#### 2. **Click-Through Rate (CTR) Optimization**

Track which results get clicked at which positions:

```
Query: "FOAM products"
Position 1: CTR 45% → Highly relevant
Position 2: CTR 12% → Moderately relevant
Position 3: CTR 3%  → Low relevance
```

Results with high CTR at lower positions should be promoted.

#### 3. **Session-Based Learning**

Analyze patterns within user sessions:

```
Session ABC123:
- Search "foam roller"
- Hover posts [1, 2, 5]
- Click post 5
- Search "foam roller exercises" (refinement)
- Click post 12

Insight: Post 5 is relevant for product searches,
         Post 12 is relevant for usage instructions
```

#### 4. **Personalization Vectors**

Build user preference profiles:

```json
{
    "user_id": 42,
    "preferences": {
        "product_focus": 0.8,
        "tutorial_focus": 0.3,
        "price_sensitivity": 0.6
    },
    "click_history": [
        {"category": "products", "weight": 0.7},
        {"category": "reviews", "weight": 0.2}
    ]
}
```

### Real-World Applications

**1. Query Understanding**
```
Query: "apple"
Clicked results: iPhone, MacBook, iPad
Signal: User means Apple Inc., not the fruit
```

**2. Result Diversity**
```
Query: "python"
Clicks distributed across:
- Programming tutorials (40%)
- Snake information (30%)
- Monty Python content (30%)
Signal: Need diverse results for ambiguous queries
```

**3. Temporal Relevance**
```
Query: "covid vaccine"
Clicks over time:
- 2020: Research articles
- 2021: Availability locations
- 2022: Booster information
Signal: Search intent shifts over time
```

### Machine Learning Pipeline

```
Raw Signals → Feature Engineering → Model Training → Deployment
     ↓               ↓                    ↓              ↓
  Database    Click patterns      Ranking model    Live search
              Position bias       Relevance scores  Re-ranking
              Time features       A/B testing       Monitoring
```

## Integration with Hybrid Search

This plugin is designed to work with a hybrid search endpoint (`/search/v1/hybrid-search`) that combines:

- **Semantic search**: Vector embeddings for meaning
- **Keyword search**: Traditional BM25/TF-IDF
- **Signal boosting**: User interaction weights

```javascript
// Results are fetched and displayed
const response = await fetch(`${hybridSearchUrl}?query=${query}&limit=3`);
const results = await response.json();

// User interactions are recorded
results.forEach(result => {
    // Track hover, click, dwell time, etc.
});
```

## Installation

1. Upload the plugin folder to `/wp-content/plugins/`
2. Activate the plugin through the WordPress admin
3. Navigate to "06 WP SIGNALS" in the admin menu
4. The database table is created automatically on activation

## Configuration

The plugin expects a REST API endpoint at:
```
/wp-json/search/v1/hybrid-search
```

You can modify the endpoint in the PHP file:
```php
'hybridSearchUrl' => rest_url('search/v1/hybrid-search')
```

## Usage for Developers

### Tracking Custom Events

```javascript
// Access the global sendEvent function
sendEvent('custom_event_name', {
    customField: 'value',
    anotherField: 123
}, {
    query: 'optional search query',
    results: [1, 2, 3] // optional result IDs
});
```

### Querying Signal Data

```php
global $wpdb;
$table_name = $wpdb->prefix . 'signals';

// Get all clicks for a specific query
$clicks = $wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$table_name} 
     WHERE event_name = 'event_click' 
     AND query = %s 
     ORDER BY created_at DESC",
    'foam products'
));

// Get CTR by position
$ctr_data = $wpdb->get_results(
    "SELECT 
        query,
        JSON_EXTRACT(event_meta_details, '$.postId') as post_id,
        COUNT(*) as impressions,
        SUM(CASE WHEN event_name = 'event_click' THEN 1 ELSE 0 END) as clicks
     FROM {$table_name}
     WHERE event_name IN ('event_search', 'event_click')
     GROUP BY query, post_id"
);
```

### Exporting Training Data

```php
// Export signals as training data for ML models
function export_training_data($query = null) {
    global $wpdb;
    $table_name = $wpdb->prefix . 'signals';
    
    $where = $query ? $wpdb->prepare("WHERE query = %s", $query) : "";
    
    $sessions = $wpdb->get_results(
        "SELECT 
            session_id,
            query,
            results,
            GROUP_CONCAT(event_name) as events,
            created_at
         FROM {$table_name}
         {$where}
         GROUP BY session_id, query
         ORDER BY created_at DESC"
    );
    
    return $sessions;
}
```

## Privacy Considerations

This plugin records user behavior, so ensure compliance with:

- **GDPR**: Obtain consent for tracking, allow data deletion
- **CCPA**: Provide opt-out mechanisms
- **User transparency**: Inform users about data collection

Consider implementing:
```php
// Add user consent check
if (!user_has_consented_to_tracking()) {
    return; // Don't record signal
}

// Anonymize after retention period
$wpdb->query("UPDATE {$table_name} 
              SET user_id = 0, session_id = 'anonymized' 
              WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY)");
```

## Future Enhancements

### Potential Features:
- **A/B Testing Framework**: Test different ranking algorithms
- **Real-time Feedback**: Adjust search results within the same session
- **Multi-armed Bandit**: Balance exploration vs. exploitation
- **Negative Signals**: Track skipped results and quick backs
- **Dwell Time**: Measure how long users stay on clicked results
- **Export API**: Provide data to external ML platforms
- **Dashboard Analytics**: Visualize signal patterns and trends

### Advanced Signals:
```javascript
// Track scroll depth
window.addEventListener('scroll', debounce(() => {
    sendEvent('event_scroll', {
        depth: getScrollPercentage(),
        postId: getCurrentPostId()
    });
}, 500));

// Track copy/paste (high engagement)
document.addEventListener('copy', (e) => {
    sendEvent('event_copy', {
        text: window.getSelection().toString().substring(0, 100)
    });
});

// Track exit intent
document.addEventListener('mouseleave', (e) => {
    if (e.clientY < 0) {
        sendEvent('event_exit_intent', {
            timeOnPage: Date.now() - pageLoadTime
        });
    }
});
```

## Contributing

This is a proof-of-concept. Contributions welcome:

1. Add more signal types
2. Improve privacy controls
3. Add analytics dashboard
4. Create ML training pipeline integration
5. Add A/B testing framework

## License

[Your chosen license]

## Author

Craig West

---

**Remember**: User signals are only as valuable as the actions you take with them. Collect data, analyze patterns, train models, and continuously improve your search experience based on real user behavior.
