<?php
/**
 * Plugin Name: ✅ 05 WP CREATE QA TABLE
 * Description: Creates a MySQL table for storing Q&A pairs with the following columns: id (AUTO_INCREMENT), guid (CHAR 36), question (varchar 500), answer (varchar 500), verified (enum: no/correct/incorrect), embedding (long text), created_on (DATETIME), updated_on (DATETIME)
 * Version: 1.0.0
 * Author: Craig West
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * QA Table Creator Class
 */
class QA_Table_Creator {

    /**
     * Table name for Q&A pairs
     */
    private $qa_table_name;

    /**
     * Constructor
     */
    public function __construct() {
        global $wpdb;
        $this->qa_table_name = $wpdb->prefix . 'qa_pairs';
    }

    /**
     * Create the Q&A pairs table
     */
    public function create_qa_table() {
        global $wpdb;

        $charset_collate = $wpdb->get_charset_collate();

        $sql = "CREATE TABLE IF NOT EXISTS {$this->qa_table_name} (
            id INT(11) NOT NULL AUTO_INCREMENT,
            guid CHAR(36) NOT NULL,
            question VARCHAR(500) NOT NULL,
            answer VARCHAR(500) NOT NULL,
            verified ENUM('no', 'correct', 'incorrect') DEFAULT 'no',
            embedding LONGTEXT,
            created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_on DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY (guid)
        ) $charset_collate;";

        require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
        dbDelta($sql);

        // Create FULLTEXT index if table exists but index doesn't
        $this->create_fulltext_index();

        // Log success
        if (defined('WP_DEBUG') && WP_DEBUG) {
            error_log('[QA Table Creator] Q&A pairs table created or updated successfully');
        }
    }

    /**
     * Create FULLTEXT index on question column if it doesn't exist
     */
    public function create_fulltext_index() {
        global $wpdb;

        // Check if table exists
        if (!$this->table_exists()) {
            return;
        }

        // Check if FULLTEXT index already exists
        $indexes = $wpdb->get_results("SHOW INDEX FROM {$this->qa_table_name} WHERE Key_name = 'question'");
        $fulltext_exists = false;

        foreach ($indexes as $index) {
            if ($index->Index_type === 'FULLTEXT') {
                $fulltext_exists = true;
                break;
            }
        }

        // Create FULLTEXT index if it doesn't exist
        if (!$fulltext_exists) {
            $sql = "ALTER TABLE {$this->qa_table_name} ADD FULLTEXT(question)";
            $result = $wpdb->query($sql);

            if ($result !== false) {
                if (defined('WP_DEBUG') && WP_DEBUG) {
                    error_log('[QA Table Creator] FULLTEXT index created successfully on question column');
                }
            } else {
                if (defined('WP_DEBUG') && WP_DEBUG) {
                    error_log('[QA Table Creator] Failed to create FULLTEXT index: ' . $wpdb->last_error);
                }
            }
        } else {
            if (defined('WP_DEBUG') && WP_DEBUG) {
                error_log('[QA Table Creator] FULLTEXT index already exists on question column');
            }
        }
    }

    /**
     * Check if table exists
     */
    public function table_exists() {
        global $wpdb;
        $result = $wpdb->get_results("SHOW TABLES LIKE '$this->qa_table_name'");
        return !empty($result);
    }

    /**
     * Get table structure
     */
    public function get_table_structure() {
        global $wpdb;
        return $wpdb->get_results("DESCRIBE $this->qa_table_name");
    }
}

// Initialize the plugin
$qa_table_creator = new QA_Table_Creator();

// Activation hook
register_activation_hook(__FILE__, array($qa_table_creator, 'create_qa_table'));

// Create table on plugin load (for immediate activation)
add_action('plugins_loaded', array($qa_table_creator, 'create_qa_table'));
?>
