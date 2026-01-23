<?php
/**
 * Test script to create the Q&A pairs table
 * Run this from the WordPress root directory
 */

// Include WordPress
require_once('wp-load.php');

// Include the plugin file to get the class
require_once('wp-content/plugins/wp-create-qa-table.php');

// Create an instance and call the table creation
$plugin = new QA_Table_Creator();
$plugin->create_qa_table();

echo "Q&A pairs table creation attempted.\n";

// Check if table exists
global $wpdb;
$table_name = $wpdb->prefix . 'qa_pairs';
$result = $wpdb->get_results("SHOW TABLES LIKE '$table_name'");

if (!empty($result)) {
    echo "Table '$table_name' exists.\n";

    // Show table structure
    $columns = $wpdb->get_results("DESCRIBE $table_name");
    echo "Table structure:\n";
    foreach ($columns as $column) {
        echo "- {$column->Field}: {$column->Type} " . ($column->Null == 'NO' ? 'NOT NULL' : 'NULL') . " " . ($column->Key ? "KEY: {$column->Key}" : "") . " " . ($column->Default ? "DEFAULT: {$column->Default}" : "") . "\n";
    }

    // Show indexes
    $indexes = $wpdb->get_results("SHOW INDEX FROM $table_name");
    echo "\nTable indexes:\n";
    foreach ($indexes as $index) {
        echo "- {$index->Key_name}: {$index->Column_name} ({$index->Index_type})" . ($index->Key_name == 'PRIMARY' ? ' [PRIMARY]' : '') . "\n";
    }
} else {
    echo "Table '$table_name' does not exist.\n";
}
?>
