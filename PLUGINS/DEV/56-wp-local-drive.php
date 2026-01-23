<?php
/**
 * WordPress Local Files Import Plugin
 * 
 * Plugin Name:  ✅ 56 UDEMY LOCAL FILES
 * Description: Browse files from C:/MY_FILES and insert content into WordPress posts
 * Version: 1.0
 * Author: Your Name
 */

class WP_LocalFiles_Integration {
    
    private $base_folder = 'C:/MY_FILES/';
    
    public function __construct() {
        add_action('admin_menu', array($this, 'add_admin_menu'));
        add_action('admin_post_create_post_from_file', array($this, 'create_post_from_file'));
        add_action('admin_enqueue_scripts', array($this, 'enqueue_scripts'));
        add_action('wp_ajax_get_file_content', array($this, 'ajax_get_file_content'));
    }
    
    /**
     * Get list of files from MY_FILES folder
     */
    public function get_files_list($subfolder = '') {
        $folder_path = $this->base_folder . $subfolder;
        
        if (!is_dir($folder_path)) {
            return array('error' => 'Folder does not exist: ' . $folder_path);
        }
        
        $files = array();
        $folders = array();
        
        $items = scandir($folder_path);
        
        foreach ($items as $item) {
            if ($item === '.' || $item === '..') {
                continue;
            }
            
            $full_path = $folder_path . $item;
            $relative_path = $subfolder . $item;
            
            if (is_dir($full_path)) {
                $folders[] = array(
                    'name' => $item,
                    'path' => $relative_path . '/',
                    'type' => 'folder'
                );
            } else {
                $extension = strtolower(pathinfo($item, PATHINFO_EXTENSION));
                $files[] = array(
                    'name' => $item,
                    'path' => $relative_path,
                    'size' => filesize($full_path),
                    'modified' => filemtime($full_path),
                    'extension' => $extension,
                    'type' => 'file'
                );
            }
        }
        
        return array(
            'folders' => $folders,
            'files' => $files,
            'current_path' => $subfolder
        );
    }
    
    /**
     * Get file content
     */
    public function get_file_content($relative_path) {
        $file_path = $this->base_folder . $relative_path;
        
        if (!file_exists($file_path)) {
            return array('error' => 'File not found');
        }
        
        $extension = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
        $content = file_get_contents($file_path);
        
        // Handle different file types
        if (in_array($extension, array('txt', 'md', 'html', 'htm'))) {
            $content = $content;
        } elseif (in_array($extension, array('doc', 'docx'))) {
            $content = "Document file detected. Content extraction for .doc/.docx requires additional libraries.";
        } elseif (in_array($extension, array('pdf'))) {
            $content = "PDF file detected. Content extraction requires additional libraries.";
        }
        
        return array(
            'success' => true,
            'content' => $content,
            'filename' => basename($file_path),
            'extension' => $extension
        );
    }
    
    /**
     * AJAX handler to get file content
     */
    public function ajax_get_file_content() {
        check_ajax_referer('local_files_nonce', 'nonce');
        
        if (!current_user_can('edit_posts')) {
            wp_send_json_error('Unauthorized');
        }
        
        $file_path = sanitize_text_field($_POST['file_path']);
        $result = $this->get_file_content($file_path);
        
        if (isset($result['error'])) {
            wp_send_json_error($result['error']);
        } else {
            wp_send_json_success($result);
        }
    }
    
    /**
     * Create post from file content
     */
    public function create_post_from_file() {
        if (!isset($_POST['local_files_nonce']) || !wp_verify_nonce($_POST['local_files_nonce'], 'local_files_import')) {
            wp_die('Security check failed');
        }
        
        if (!current_user_can('edit_posts')) {
            wp_die('Unauthorized');
        }
        
        $file_path = sanitize_text_field($_POST['file_path']);
        $post_title = sanitize_text_field($_POST['post_title']);
        $post_status = sanitize_text_field($_POST['post_status']);
        
        $result = $this->get_file_content($file_path);
        
        if (isset($result['error'])) {
            wp_redirect(add_query_arg(array(
                'page' => 'local-files-import',
                'error' => urlencode($result['error'])
            ), admin_url('admin.php')));
            exit;
        }
        
        $title = !empty($post_title) ? $post_title : $result['filename'];
        
        $post_data = array(
            'post_title'    => wp_strip_all_tags($title),
            'post_content'  => $result['content'],
            'post_status'   => $post_status,
            'post_author'   => get_current_user_id(),
            'post_type'     => 'post'
        );
        
        $post_id = wp_insert_post($post_data);
        
        if (is_wp_error($post_id)) {
            wp_redirect(add_query_arg(array(
                'page' => 'local-files-import',
                'error' => urlencode($post_id->get_error_message())
            ), admin_url('admin.php')));
        } else {
            wp_redirect(get_edit_post_link($post_id, 'raw'));
        }
        exit;
    }
    
    /**
     * Enqueue admin scripts
     */
    public function enqueue_scripts($hook) {
        if ($hook !== 'toplevel_page_local-files-import') {
            return;
        }
        
        wp_enqueue_style('local-files-admin', false);
        wp_add_inline_style('local-files-admin', '
            .files-browser { border: 1px solid #ccc; padding: 15px; background: #fff; margin: 20px 0; }
            .file-item, .folder-item { padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; display: flex; align-items: center; }
            .file-item:hover, .folder-item:hover { background: #f5f5f5; }
            .file-icon, .folder-icon { margin-right: 10px; font-size: 18px; }
            .file-content-preview { border: 1px solid #ccc; padding: 15px; background: #f9f9f9; margin: 20px 0; max-height: 400px; overflow-y: auto; }
            .breadcrumb { margin-bottom: 15px; }
            .breadcrumb a { color: #0073aa; text-decoration: none; }
            .breadcrumb a:hover { text-decoration: underline; }
            .file-meta { color: #666; font-size: 12px; margin-left: auto; }
            .loading { display: none; padding: 20px; text-align: center; }
        ');
        
        wp_enqueue_script('local-files-admin', false, array('jquery'), '1.0', true);
        wp_add_inline_script('local-files-admin', '
            jQuery(document).ready(function($) {
                $(".file-item").click(function() {
                    var filePath = $(this).data("path");
                    var fileName = $(this).data("name");
                    
                    $("#selected_file_path").val(filePath);
                    $("#post_title").val(fileName);
                    
                    $(".loading").show();
                    $("#file-preview").hide();
                    
                    $.post(ajaxurl, {
                        action: "get_file_content",
                        file_path: filePath,
                        nonce: "' . wp_create_nonce('local_files_nonce') . '"
                    }, function(response) {
                        $(".loading").hide();
                        if (response.success) {
                            $("#file-preview").html("<h3>Preview: " + response.data.filename + "</h3><pre>" + $("<div>").text(response.data.content).html() + "</pre>").show();
                        } else {
                            $("#file-preview").html("<p style=\"color: red;\">Error: " + response.data + "</p>").show();
                        }
                    });
                });
                
                $(".folder-item").click(function() {
                    var folderPath = $(this).data("path");
                    window.location.href = "?page=local-files-import&folder=" + encodeURIComponent(folderPath);
                });
            });
        ');
    }
    
    /**
     * Add admin menu
     */
    public function add_admin_menu() {
        add_menu_page(
            'Local Files Import',
            '56 LOCAL FILES',
            'manage_options',
            'local-files-import',
            array($this, 'admin_page'),
            'dashicons-media-document',
            4.8
        );
    }
    
    /**
     * Admin page HTML
     */
    public function admin_page() {
        $current_folder = isset($_GET['folder']) ? sanitize_text_field($_GET['folder']) : '';
        $files_data = $this->get_files_list($current_folder);
        
        if (isset($files_data['error'])) {
            echo '<div class="notice notice-error"><p>' . esc_html($files_data['error']) . '</p></div>';
            echo '<p>Please create the folder: <code>C:/MY_FILES/</code></p>';
            return;
        }
        
        ?>
        <div class="wrap">
            <h1>Import from Local Files</h1>
            <p>Browse files from: <code><?php echo esc_html($this->base_folder); ?></code></p>
            
            <?php if (isset($_GET['error'])): ?>
                <div class="notice notice-error">
                    <p><?php echo esc_html($_GET['error']); ?></p>
                </div>
            <?php endif; ?>
            
            <div class="files-browser">
                <?php if (!empty($current_folder)): ?>
                    <div class="breadcrumb">
                        <a href="?page=local-files-import">Home</a>
                        <?php
                        $parts = explode('/', trim($current_folder, '/'));
                        $path = '';
                        foreach ($parts as $part) {
                            if (empty($part)) continue;
                            $path .= $part . '/';
                            echo ' / <a href="?page=local-files-import&folder=' . urlencode($path) . '">' . esc_html($part) . '</a>';
                        }
                        ?>
                    </div>
                    <div class="folder-item" data-path="<?php echo esc_attr(dirname($current_folder) . '/'); ?>">
                        <span class="folder-icon">📁</span>
                        <strong>.. (Parent Directory)</strong>
                    </div>
                <?php endif; ?>
                
                <h3>Folders</h3>
                <?php if (empty($files_data['folders'])): ?>
                    <p><em>No folders</em></p>
                <?php else: ?>
                    <?php foreach ($files_data['folders'] as $folder): ?>
                        <div class="folder-item" data-path="<?php echo esc_attr($folder['path']); ?>">
                            <span class="folder-icon">📁</span>
                            <strong><?php echo esc_html($folder['name']); ?></strong>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
                
                <h3>Files</h3>
                <?php if (empty($files_data['files'])): ?>
                    <p><em>No files in this folder</em></p>
                <?php else: ?>
                    <?php foreach ($files_data['files'] as $file): ?>
                        <div class="file-item" data-path="<?php echo esc_attr($file['path']); ?>" data-name="<?php echo esc_attr(pathinfo($file['name'], PATHINFO_FILENAME)); ?>">
                            <span class="file-icon">📄</span>
                            <strong><?php echo esc_html($file['name']); ?></strong>
                            <span class="file-meta">
                                <?php echo esc_html(size_format($file['size'])); ?> | 
                                <?php echo esc_html(date('Y-m-d H:i', $file['modified'])); ?>
                            </span>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
            
            <div class="loading">Loading file content...</div>
            
            <div id="file-preview" class="file-content-preview" style="display: none;"></div>
            
            <form method="post" action="<?php echo admin_url('admin-post.php'); ?>" id="import-form">
                <input type="hidden" name="action" value="create_post_from_file">
                <input type="hidden" name="file_path" id="selected_file_path" value="">
                <?php wp_nonce_field('local_files_import', 'local_files_nonce'); ?>
                
                <h2>Create Post from Selected File</h2>
                
                <table class="form-table">
                    <tr>
                        <th scope="row">
                            <label for="post_title">Post Title</label>
                        </th>
                        <td>
                            <input type="text" name="post_title" id="post_title" class="regular-text" required>
                            <p class="description">Auto-filled when you select a file</p>
                        </td>
                    </tr>
                    <tr>
                        <th scope="row">
                            <label for="post_status">Post Status</label>
                        </th>
                        <td>
                            <select name="post_status" id="post_status">
                                <option value="draft">Draft</option>
                                <option value="publish">Publish</option>
                                <option value="pending">Pending Review</option>
                            </select>
                        </td>
                    </tr>
                </table>
                
                <?php submit_button('Create Post from File'); ?>
            </form>
        </div>
        <?php
    }
}

// Initialize the plugin
new WP_LocalFiles_Integration();
?>