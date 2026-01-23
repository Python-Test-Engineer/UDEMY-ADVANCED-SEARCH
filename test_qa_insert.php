<?php
/**
 * Test script to verify Q&A insertion functionality
 * Run this from the WordPress root directory
 */

// Include WordPress
require_once('wp-load.php');

// Include the plugins
require_once('wp-content/plugins/wp-create-qa-table.php');
require_once('wp-content/plugins/wp-qa-extractor.php');

// Create table first
$table_creator = new QA_Table_Creator();
$table_creator->create_qa_table();

// Test data - sample Q&A pairs
$test_json = '{
  "qa_pairs": [
    {
      "question": "What is the capital of France?",
      "answer": "Paris"
    },
    {
      "question": "What is 2 + 2?",
      "answer": "4"
    }
  ]
}';

// Create extractor plugin instance
$extractor = new QA_Extractor_Plugin();

// Test the insert functionality directly
echo "Testing Q&A insertion...\n";

// Parse JSON
$data = json_decode($test_json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    echo "JSON parse error: " . json_last_error_msg() . "\n";
    exit(1);
}

echo "JSON parsed successfully. Found " . count($data['qa_pairs']) . " Q&A pairs.\n";

// Test insert_qa_pair method directly
$inserted = 0;
foreach ($data['qa_pairs'] as $pair) {
    // Access private method via reflection for testing
    $reflection = new ReflectionClass($extractor);
    $method = $reflection->getMethod('insert_qa_pair');
    $method->setAccessible(true);

    $result = $method->invoke($extractor, $pair['question'], $pair['answer']);
    if ($result) {
        $inserted++;
        echo "✓ Inserted: {$pair['question']}\n";
    } else {
        echo "✗ Failed to insert: {$pair['question']}\n";
    }
}

echo "\nInserted $inserted out of " . count($data['qa_pairs']) . " pairs.\n";

// Check database
global $wpdb;
$table_name = $wpdb->prefix . 'qa_pairs';
$count = $wpdb->get_var("SELECT COUNT(*) FROM $table_name");
echo "Total records in table: $count\n";

// Show a few records
$records = $wpdb->get_results("SELECT id, question, answer, verified, created_on FROM $table_name LIMIT 5");
echo "\nSample records:\n";
foreach ($records as $record) {
    echo "- ID: {$record->id}\n";
    echo "  Question: {$record->question}\n";
    echo "  Answer: {$record->answer}\n";
    echo "  Verified: {$record->verified}\n";
    echo "  Created: {$record->created_on}\n\n";
}

echo "Test completed.\n";

// Test FULLTEXT search functionality
echo "\n=== Testing FULLTEXT Search ===\n";

// Insert some test data for search testing
$search_test_data = [
    [
        'question' => 'What is the capital of France?',
        'answer' => 'Paris is the capital and most populous city of France.'
    ],
    [
        'question' => 'How does photosynthesis work in plants?',
        'answer' => 'Photosynthesis is the process by which plants convert sunlight into energy.'
    ],
    [
        'question' => 'What are the benefits of regular exercise?',
        'answer' => 'Regular exercise improves cardiovascular health, strengthens muscles, and boosts mental health.'
    ],
    [
        'question' => 'How to bake chocolate chip cookies?',
        'answer' => 'Mix flour, sugar, eggs, butter, and chocolate chips, then bake at 350°F for 10-12 minutes.'
    ]
];

echo "Inserting test data for search demonstration...\n";
foreach ($search_test_data as $test_pair) {
    $reflection = new ReflectionClass($extractor);
    $method = $reflection->getMethod('insert_qa_pair');
    $method->setAccessible(true);
    $method->invoke($extractor, $test_pair['question'], $test_pair['answer']);
    echo "✓ Inserted: {$test_pair['question']}\n";
}

// Test natural language search queries
$search_queries = [
    'france capital',
    'exercise benefits',
    'baking cookies',
    'plant photosynthesis'
];

echo "\nTesting FULLTEXT natural language searches:\n";
foreach ($search_queries as $query) {
    echo "\nSearch query: '$query'\n";
    $search_results = $wpdb->get_results($wpdb->prepare(
        "SELECT question, answer, MATCH(question) AGAINST(%s IN NATURAL LANGUAGE MODE) AS relevance
         FROM $table_name
         WHERE MATCH(question) AGAINST(%s IN NATURAL LANGUAGE MODE)
         ORDER BY relevance DESC
         LIMIT 3",
        $query, $query
    ));

    if (!empty($search_results)) {
        foreach ($search_results as $result) {
            echo "  - Question: {$result->question}\n";
            echo "    Relevance: " . number_format($result->relevance, 4) . "\n";
        }
    } else {
        echo "  No results found\n";
    }
}

echo "\nFULLTEXT search test completed.\n";
?>
