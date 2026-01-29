<?php
/**
 * Plugin Name:✅ 03 BM25 CALC
 * Plugin URI: https://example.com/bm25-calculation
 * Description: Educational demonstration of the BM25 search ranking algorithm with interactive parameter controls
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: bm25-calc
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * BM25 Algorithm Class
 */
class BM25_Algorithm {
    private $k1;
    private $b;
    private $documents;
    private $avgdl;
    private $N;
    
    public function __construct($documents, $k1 = 1.5, $b = 0.75) {
        $this->documents = $documents;
        $this->k1 = $k1;
        $this->b = $b;
        $this->N = count($documents);
        $this->avgdl = $this->calculateAverageDocumentLength();
    }
    
    private function calculateAverageDocumentLength() {
        $totalLength = 0;
        foreach ($this->documents as $doc) {
            $totalLength += str_word_count($doc);
        }
        return $this->N > 0 ? $totalLength / $this->N : 0;
    }
    
    private function tokenize($text) {
        return array_map('strtolower', str_word_count($text, 1));
    }
    
    private function termFrequency($term, $document) {
        $tokens = $this->tokenize($document);
        return count(array_filter($tokens, function($word) use ($term) {
            return $word === strtolower($term);
        }));
    }
    
    private function documentFrequency($term) {
        $count = 0;
        foreach ($this->documents as $doc) {
            if ($this->termFrequency($term, $doc) > 0) {
                $count++;
            }
        }
        return $count;
    }
    
    private function calculateIDF($term) {
        $n = $this->documentFrequency($term);
        return log(($this->N - $n + 0.5) / ($n + 0.5));
    }
    
    public function score($query, $document, $docIndex = 0) {
        $queryTerms = array_unique($this->tokenize($query));
        $docLength = str_word_count($document);
        $score = 0.0;
        $details = [];
        
        foreach ($queryTerms as $term) {
            $tf = $this->termFrequency($term, $document);
            $idf = $this->calculateIDF($term);
            $df = $this->documentFrequency($term);
            
            $numerator = $tf * ($this->k1 + 1);
            $denominator = $tf + $this->k1 * (1 - $this->b + $this->b * ($docLength / $this->avgdl));
            $termScore = $idf * ($numerator / $denominator);
            $score += $termScore;
            
            $details[] = [
                'term' => $term,
                'tf' => $tf,
                'df' => $df,
                'idf' => $idf,
                'numerator' => $numerator,
                'denominator' => $denominator,
                'term_score' => $termScore,
                'doc_length' => $docLength
            ];
        }
        
        return [
            'score' => $score,
            'details' => $details
        ];
    }
    
    public function search($query) {
        $results = [];

        foreach ($this->documents as $index => $doc) {
            $scoreData = $this->score($query, $doc, $index + 1);
            if ($scoreData['score'] > 0) {
                $results[] = [
                    'index' => $index + 1,
                    'document' => $doc,
                    'score' => $scoreData['score'],
                    'details' => $scoreData['details']
                ];
            }
        }

        usort($results, function($a, $b) {
            return $b['score'] <=> $a['score'];
        });

        return $results;
    }
    
    public function getAvgdl() {
        return $this->avgdl;
    }
    
    public function getN() {
        return $this->N;
    }
}

/**
 * Main Plugin Class
 */
class BM25_Calculation_Plugin {
    
    private static $instance = null;
    
    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    private function __construct() {
        add_action('admin_menu', [$this, 'add_admin_menu']);
        add_action('admin_enqueue_scripts', [$this, 'enqueue_admin_assets']);
        add_action('wp_ajax_bm25_calculate', [$this, 'ajax_calculate']);
    }
    
    public function add_admin_menu() {
        add_menu_page(
            'BM25 Calculation',           // Page title
            '03 BM25 CALC',           // Menu title
            'manage_options',             // Capability
            'bm25-calculation',           // Menu slug
            [$this, 'render_admin_page'], // Callback
            'dashicons-search',           // Icon
            3.3                           // Position
        );
    }
    
    public function enqueue_admin_assets($hook) {
        if ('toplevel_page_bm25-calculation' !== $hook) {
            return;
        }
        
        wp_enqueue_style(
            'bm25-calc-admin',
            plugin_dir_url(__FILE__) . 'assets/admin-style.css',
            [],
            '1.0.0'
        );
        
        wp_enqueue_script(
            'bm25-calc-admin',
            plugin_dir_url(__FILE__) . 'assets/admin-script.js',
            ['jquery'],
            '1.0.0',
            true
        );
        
        wp_localize_script('bm25-calc-admin', 'bm25Ajax', [
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('bm25_calc_nonce')
        ]);
    }
    
    public function ajax_calculate() {
        check_ajax_referer('bm25_calc_nonce', 'nonce');

        $query = sanitize_text_field($_POST['query']);
        $k1 = floatval($_POST['k1']);
        $b = floatval($_POST['b']);
        $limit = intval($_POST['limit']);
        $documents = array_map('sanitize_text_field', $_POST['documents']);

        $bm25 = new BM25_Algorithm($documents, $k1, $b);
        $all_results = $bm25->search($query);

        // Apply limit on server side
        $results = $limit > 0 ? array_slice($all_results, 0, $limit) : $all_results;

        wp_send_json_success([
            'results' => $results,
            'avgdl' => $bm25->getAvgdl(),
            'total_docs' => $bm25->getN()
        ]);
    }
    
    public function render_admin_page() {
        global $wpdb;

        // Handle FTS index management
        $table_name = 'wp_products'; // Exact table name as specified
        $message = '';
        if (isset($_POST['delete_all_fts']) && check_admin_referer('bm25_fts_action')) {
            // Check which indexes exist and drop them
            $existing_indexes = $wpdb->get_results("SHOW INDEX FROM {$table_name} WHERE Index_type = 'FULLTEXT' AND Key_name IN ('fts_product_name', 'fts_product_short_description')");
            $deleted_count = 0;
            foreach ($existing_indexes as $index) {
                $result = $wpdb->query("ALTER TABLE {$table_name} DROP INDEX {$index->Key_name}");
                if ($result !== false) {
                    $deleted_count++;
                }
            }
            if ($deleted_count > 0) {
                $message = '<div class="notice notice-success"><p>' . $deleted_count . ' FTS index(es) deleted successfully.</p></div>';
            } else {
                $message = '<div class="notice notice-info"><p>No FTS indexes found to delete.</p></div>';
            }
        }

        if (isset($_POST['add_fts_product_name']) && check_admin_referer('bm25_fts_action')) {
            $result = $wpdb->query("ALTER TABLE {$table_name} ADD FULLTEXT INDEX fts_product_name (product_name)");
            if ($result !== false) {
                $message = '<div class="notice notice-success"><p>FTS index on product_name added successfully.</p></div>';
                // Load product names into documents
                $products = $wpdb->get_results("SELECT product_name FROM {$table_name} WHERE product_name IS NOT NULL AND product_name != ''");
                $docs = '';
                foreach ($products as $product) {
                    $docs .= $product->product_name . "\n";
                }
                update_option('bm25_calc_documents', trim($docs));
            } else {
                $message = '<div class="notice notice-error"><p>Failed to add FTS index on product_name. ' . $wpdb->last_error . '</p></div>';
            }
        }

        if (isset($_POST['add_fts_product_short_description']) && check_admin_referer('bm25_fts_action')) {
            $result = $wpdb->query("ALTER TABLE {$table_name} ADD FULLTEXT INDEX fts_product_short_description (product_short_description)");
            if ($result !== false) {
                $message = '<div class="notice notice-success"><p>FTS index on product_short_description added successfully.</p></div>';
                // Load short descriptions into documents
                $products = $wpdb->get_results("SELECT product_short_description FROM {$table_name} WHERE product_short_description IS NOT NULL AND product_short_description != ''");
                $docs = '';
                foreach ($products as $product) {
                    $docs .= $product->product_short_description . "\n";
                }
                update_option('bm25_calc_documents', trim($docs));
            } else {
                $message = '<div class="notice notice-error"><p>Failed to add FTS index on product_short_description. ' . $wpdb->last_error . '</p></div>';
            }
        }

        // Get current FTS indexes
        $indexes = $wpdb->get_results("SHOW INDEX FROM {$table_name} WHERE Index_type = 'FULLTEXT'");
        $current_docs = get_option('bm25_calc_documents', '');

        ?>
        <div class="wrap bm25-calc-wrap">
            <h1>🔍 BM25 Search Ranking Calculator</h1>
            <p class="description">Educational demonstration of the BM25 algorithm with interactive controls</p>

            <?php echo $message; ?>

            <!-- FTS Index Management Section -->
            <div class="bm25-card">
                <h2>🗄️ FTS Index Management for wp_products Table</h2>

                <h3>Current Full-Text Search Indexes</h3>
                <?php if (!empty($indexes)): ?>
                    <ul>
                        <?php foreach ($indexes as $index): ?>
                            <li><?php echo esc_html($index->Key_name); ?> on <?php echo esc_html($index->Column_name); ?></li>
                        <?php endforeach; ?>
                    </ul>
                <?php else: ?>
                    <p>No FTS indexes found.</p>
                <?php endif; ?>

                <h3>Manage Indexes</h3>
                <form method="post">
                    <?php wp_nonce_field('bm25_fts_action'); ?>
                    <p>
                        <input type="submit" name="delete_all_fts" class="button button-secondary" value="DELETE ALL FTS INDEXES">
                        <input type="submit" name="add_fts_product_name" class="button button-primary" value="ADD FTS index on product_name">
                        <input type="submit" name="add_fts_product_short_description" class="button button-primary" value="ADD FTS index on product_short_description">
                    </p>
                </form>
            </div>
            
            <div class="bm25-container">
                <!-- Left Panel: Input Controls -->
                <div class="bm25-panel bm25-input-panel">
                    <div class="bm25-card">
                        <h2>📝 Documents</h2>
                        <p class="description">Documents loaded from database (one per line)</p>
                        <textarea id="bm25-documents" rows="8" class="large-text"><?php echo esc_textarea($current_docs ?: "Python is a programming language\nI love programming in Python and Python is easy\nJava and C++ are programming languages"); ?></textarea>
                    </div>
                    
                    <div class="bm25-card">
                        <h2>🎯 Search Query</h2>
                        <input type="text" id="bm25-query" class="regular-text" value="electric space" placeholder="Enter search terms...">
                    </div>
                    
                    <div class="bm25-card">
                        <h2>⚙️ Parameters</h2>
                        
                        <div class="param-group">
                            <label for="bm25-k1">
                                <strong>k1</strong> - Term Frequency Saturation
                                <span class="description">Controls how quickly additional term occurrences stop mattering</span>
                            </label>
                            <input type="number" id="bm25-k1" step="0.1" min="0" max="3" value="1.5">
                            <span class="param-value">1.5</span>
                        </div>
                        
                        <div class="param-group">
                            <label for="bm25-b">
                                <strong>b</strong> - Length Normalization
                                <span class="description">Controls document length penalty (0 = ignore length, 1 = full penalty)</span>
                            </label>
                            <input type="number" id="bm25-b" step="0.05" min="0" max="1" value="0.75">
                            <span class="param-value">0.75</span>
                        </div>

                        <div class="param-group">
                            <label for="bm25-limit">
                                <strong>Results Limit</strong> - Maximum non-zero documents to return
                                <span class="description">Limit the number of ranked results shown</span>
                            </label>
                            <select id="bm25-limit">
                                <option value="5">5 results</option>
                                <option value="10" selected>10 results</option>
                                <option value="20">20 results</option>
                                <option value="50">50 results</option>
                                <option value="100">100 results</option>
                                <option value="0">All results</option>
                            </select>
                        </div>
                    </div>
                    
                    <button type="button" id="bm25-calculate" class="button button-primary button-large">
                        Calculate BM25 Scores
                    </button>
                </div>
                
                <!-- Right Panel: Results -->
                <div class="bm25-panel bm25-results-panel">
                    <div class="bm25-card">
                        <h2>📊 Statistics</h2>
                        <div id="bm25-stats"></div>
                    </div>
                    
                    <div class="bm25-card">
                        <h2>🏆 Ranked Results</h2>
                        <div id="bm25-results"></div>
                    </div>
                    
                    <div class="bm25-card">
                        <h2>🔬 Detailed Calculations</h2>
                        <div id="bm25-details"></div>
                    </div>
                </div>
            </div>
            
            <!-- Info Section -->
            <div class="bm25-info">
                <h2>ℹ️ About BM25</h2>
                <p>BM25 (Best Matching 25) is a ranking function used by search engines to estimate the relevance of documents to a search query. The algorithm considers:</p>
                <ul>
                    <li><strong>Term Frequency (TF)</strong>: How often query terms appear in a document</li>
                    <li><strong>Inverse Document Frequency (IDF)</strong>: How rare a term is across all documents</li>
                    <li><strong>Document Length</strong>: Normalizes scores based on document length</li>
                </ul>
                <p style="font-size: 1.50rem;"><strong>Formula:</strong> BM25(D, Q) = Σ IDF(qi) × (f(qi, D) × (k1 + 1)) / (f(qi, D) + k1 × (1 - b + b × |D| / avgdl))</p>
            </div>
        </div>
        
        <style>
        .bm25-calc-wrap {
            max-width: 1400px;
            font-size: 1.5rem;
            line-height: 1.6;
        }
        
        .bm25-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin: 20px 0;
        }
        
        .bm25-panel {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        
        .bm25-card {
            background: #fff;
            border: 1px solid #ccd0d4;
            border-radius: 4px;
            padding: 20px;
            box-shadow: 0 1px 1px rgba(0,0,0,.04);
        }
        
        .bm25-card h2 {
            margin: 0 0 15px 0;
            font-size: 18px;
            border-bottom: 2px solid #2271b1;
            padding-bottom: 8px;
        }
        
        .param-group {
            margin-bottom: 20px;
        }
        
        .param-group label {
            display: block;
            margin-bottom: 8px;
        }
        
        .param-group .description {
            display: block;
            font-size: 12px;
            color: #646970;
            margin-top: 4px;
        }
        
        .param-group input {
            width: 100px;
            margin-right: 10px;
        }
        
        .param-value {
            font-weight: bold;
            color: #2271b1;
        }
        
        #bm25-calculate {
            width: 100%;
            height: 50px;
            font-size: 16px;
        }
        
        .result-item {
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 15px;
            margin-bottom: 15px;
            background: #f9f9f9;
        }
        
        .result-item.rank-1 {
            border-left: 4px solid #ffd700;
            background: #fffef0;
        }
        
        .result-item.rank-2 {
            border-left: 4px solid #c0c0c0;
            background: #f8f8f8;
        }
        
        .result-item.rank-3 {
            border-left: 4px solid #cd7f32;
            background: #fef9f5;
        }
        
        .result-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .result-rank {
            font-size: 24px;
            font-weight: bold;
        }
        
        .result-score {
            font-size: 18px;
            font-weight: bold;
            color: #2271b1;
        }
        
        .result-document {
            font-style: italic;
            color: #1d2327;
            margin: 10px 0;
        }
        
        .calculation-details {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 10px;
            margin-top: 10px;
            font-family: monospace;
            font-size: 12px;
        }
        
        .term-calc {
            margin: 10px 0;
            padding: 10px;
            background: #f0f0f1;
            border-left: 3px solid #2271b1;
        }
        
        .term-calc strong {
            color: #2271b1;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .stat-item {
            padding: 10px;
            background: #f0f0f1;
            border-radius: 4px;
        }
        
        .stat-label {
            font-size: 12px;
            color: #646970;
            margin-bottom: 5px;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #2271b1;
        }
        
        .bm25-info {
            background: #e7f5fe;
            border: 1px solid #2271b1;
            border-radius: 4px;
            padding: 20px;
            margin-top: 30px;
        }
        
        .bm25-info h2 {
            margin-top: 0;
            color: #2271b1;
        }
        
        .bm25-info ul {
            margin: 10px 0;
        }
        
        .bm25-info code {
            background: #fff;
            padding: 2px 6px;
            border-radius: 3px;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #646970;
        }
        
        @media (max-width: 1200px) {
            .bm25-container {
                grid-template-columns: 1fr;
            }
        }
        </style>
        
        <script>
        jQuery(document).ready(function($) {
            // Update parameter display values
            $('#bm25-k1, #bm25-b').on('input', function() {
                $(this).next('.param-value').text($(this).val());
            });
            
            // Calculate button click
            $('#bm25-calculate').on('click', function() {
                const query = $('#bm25-query').val();
                const k1 = $('#bm25-k1').val();
                const b = $('#bm25-b').val();
                const limit = parseInt($('#bm25-limit').val());
                const documentsText = $('#bm25-documents').val();
                const documents = documentsText.split('\n').filter(d => d.trim());
                
                if (!query.trim()) {
                    alert('Please enter a search query');
                    return;
                }
                
                if (documents.length === 0) {
                    alert('Please enter at least one document');
                    return;
                }
                
                // Show loading
                $('#bm25-results').html('<div class="loading">Calculating...</div>');
                $('#bm25-details').html('<div class="loading">Processing...</div>');
                
                $.ajax({
                    url: bm25Ajax.ajax_url,
                    type: 'POST',
                    data: {
                        action: 'bm25_calculate',
                        nonce: bm25Ajax.nonce,
                        query: query,
                        k1: k1,
                        b: b,
                        limit: limit,
                        documents: documents
                    },
                    success: function(response) {
                        if (response.success) {
                            displayResults(response.data, query, k1, b, limit);
                        }
                    }
                });
            });
            
            function displayResults(data, query, k1, b, limit) {
                // Display statistics
                const statsHtml = `
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-label">Total Documents</div>
                            <div class="stat-value">${data.total_docs}</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-label">Average Document Length</div>
                            <div class="stat-value">${data.avgdl.toFixed(2)}</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-label">k1 Parameter</div>
                            <div class="stat-value">${k1}</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-label">b Parameter</div>
                            <div class="stat-value">${b}</div>
                        </div>
                    </div>
                `;
                $('#bm25-stats').html(statsHtml);

                // Apply limit to results
                const limitedResults = limit > 0 ? data.results.slice(0, limit) : data.results;

                // Display ranked results
                let resultsHtml = '';
                limitedResults.forEach((result, idx) => {
                    const rank = idx + 1;
                    const medal = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : `#${rank}`;

                    // Create score explanation
                    let explanation = 'Score breakdown: ';
                    const explanations = [];
                    result.details.forEach(detail => {
                        if (detail.term_score > 0) {
                            explanations.push(`"${detail.term}" (${detail.term_score.toFixed(4)})`);
                        }
                    });
                    explanation += explanations.join(' + ');

                    resultsHtml += `
                        <div class="result-item rank-${rank}">
                            <div class="result-header">
                                <span class="result-rank">${medal}</span>
                                <span class="result-score">Score: ${result.score.toFixed(4)}</span>
                            </div>
                            <div class="result-document">Document ${result.index}: "${result.document}"</div>
                            <div class="score-explanation">${explanation}</div>
                        </div>
                    `;
                });
                $('#bm25-results').html(resultsHtml);
                
                // Display detailed calculations (show details for the limited results only)
                let detailsHtml = '';
                limitedResults.forEach((result, idx) => {
                    detailsHtml += `<h3>Document ${result.index}: "${result.document}"</h3>`;

                    result.details.forEach(detail => {
                        detailsHtml += `
                            <div class="term-calc">
                                <strong>Term: "${detail.term}"</strong><br>
                                • Term Frequency (tf): ${detail.tf}<br>
                                • Document Frequency (df): ${detail.df} documents<br>
                                • IDF: ${detail.idf.toFixed(4)}<br>
                                • Document Length: ${detail.doc_length} words<br>
                                • Numerator: ${detail.numerator.toFixed(4)}<br>
                                • Denominator: ${detail.denominator.toFixed(4)}<br>
                                • <strong>Term Score: ${detail.term_score.toFixed(4)}</strong>
                            </div>
                        `;
                    });

                    detailsHtml += `<p><strong>Total BM25 Score: ${result.score.toFixed(4)}</strong></p><hr>`;
                });
                $('#bm25-details').html(detailsHtml);
            }
            
            // Auto-calculate on page load
            $('#bm25-calculate').click();
        });
        </script>
        <?php
    }
}

// Initialize the plugin
BM25_Calculation_Plugin::get_instance();
