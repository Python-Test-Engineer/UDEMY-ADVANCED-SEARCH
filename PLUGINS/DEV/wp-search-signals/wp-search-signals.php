<?php
/**
 * Plugin Name:  ✅ 100 WP SEARCH SIGNALS
 * Description: Record user actions as signals for machine learning.
 * Version: 1.0.0
 * Author: Craig West
 */

if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

class WP_Signals_Plugin {
    const TABLE_SLUG = 'signals';
    const NONCE_ACTION = 'wp_signals_log_event';
    const AJAX_ACTION = 'wp_signals_log_event';

    public function __construct() {
        add_action( 'admin_menu', array( $this, 'register_admin_menu' ) );
        add_action( 'admin_enqueue_scripts', array( $this, 'enqueue_admin_assets' ) );
        add_action( 'wp_ajax_' . self::AJAX_ACTION, array( $this, 'handle_log_event' ) );
    }

    public static function activate() {
        global $wpdb;

        $table_name = $wpdb->prefix . self::TABLE_SLUG;
        $charset_collate = $wpdb->get_charset_collate();

        $sql = "CREATE TABLE IF NOT EXISTS {$table_name} (
            id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            guid VARCHAR(36) NOT NULL,
            user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
            event_name VARCHAR(120) NOT NULL,
            event_meta_details LONGTEXT NULL,
            created_at DATETIME NOT NULL,
            PRIMARY KEY  (id),
            KEY event_name (event_name),
            KEY user_id (user_id)
        ) {$charset_collate};";

        require_once ABSPATH . 'wp-admin/includes/upgrade.php';
        dbDelta( $sql );
    }

    public function register_admin_menu() {
        add_menu_page(
            'WP Signals',
            '100 WP SIGNALS',
            'manage_options',
            'wp-signals',
            array( $this, 'render_admin_page' ),
            'dashicons-rss',
            38
        );
    }

    public function enqueue_admin_assets( $hook ) {
        if ( 'toplevel_page_wp-signals' !== $hook ) {
            return;
        }

        wp_enqueue_script(
            'wp-signals-admin',
            plugin_dir_url( __FILE__ ) . 'assets/admin.js',
            array(),
            '1.0.0',
            true
        );

        wp_localize_script(
            'wp-signals-admin',
            'wpSignalsData',
            array(
                'ajaxUrl' => admin_url( 'admin-ajax.php' ),
                'nonce'   => wp_create_nonce( self::NONCE_ACTION ),
            )
        );
    }

    public function render_admin_page() {
        if ( ! current_user_can( 'manage_options' ) ) {
            return;
        }

        ?>
        <div class="wrap">
            <h1>WP Signals</h1>
            <table class="form-table">
                <tr>
                    <th scope="row"><label for="ws_query">Search Query</label></th>
                    <td>
                        <input
                            name="ws_query"
                            id="ws_query"
                            type="text"
                            class="regular-text"
                            value="FOAM products"
                           
                        />
                        <button type="button" class="button button-primary" id="ws_query_run">
                            Run Query
                        </button>
                        <p class="description">
                            Results are pulled from the hybrid search endpoint and limited to 3 entries.
                        </p>
                    </td>
                </tr>
            </table>

            <h2>Search Results</h2>
            <div id="wp-signals-results" class="wp-signals-results">
                <p>Enter a query to fetch results.</p>
            </div>

            <h2>Debug Output</h2>
            <p class="description">Latest event payloads that will be saved:</p>
            <ul id="wp-signals-debug" class="wp-signals-debug"></ul>
        </div>
        <?php
    }

    public function handle_log_event() {
        check_ajax_referer( self::NONCE_ACTION, 'nonce' );

        if ( ! is_user_logged_in() ) {
            wp_send_json_error( array( 'message' => 'User not logged in.' ), 403 );
        }

        $event_name = '';
        $event_meta_details = '';

        if ( isset( $_POST['event_name'] ) ) {
            $event_name = sanitize_text_field( wp_unslash( $_POST['event_name'] ) );
        }

        if ( isset( $_POST['event_meta_details'] ) ) {
            $event_meta_details = wp_unslash( $_POST['event_meta_details'] );
        }

        if ( empty( $event_name ) ) {
            wp_send_json_error( array( 'message' => 'Missing event name.' ), 400 );
        }

        global $wpdb;
        $table_name = $wpdb->prefix . self::TABLE_SLUG;

        $inserted = $wpdb->insert(
            $table_name,
            array(
                'guid'              => wp_generate_uuid4(),
                'user_id'           => get_current_user_id(),
                'event_name'        => $event_name,
                'event_meta_details'=> $event_meta_details,
                'created_at'        => current_time( 'mysql' ),
            ),
            array( '%s', '%d', '%s', '%s', '%s' )
        );

        if ( false === $inserted ) {
            wp_send_json_error( array( 'message' => 'Database insert failed.' ), 500 );
        }

        wp_send_json_success( array( 'message' => 'Event logged.' ) );
    }
}

register_activation_hook( __FILE__, array( 'WP_Signals_Plugin', 'activate' ) );
new WP_Signals_Plugin();