-- ============================================================================
-- WordPress FTS Demo Data - Sample Posts for Full-Text Search Examples
-- ============================================================================
-- This script creates sample blog posts to demonstrate the FTS examples at:
-- https://advanced-wordpress-search.netlify.app/fts/wp-fts-sql-examples/
--
-- Prerequisites:
-- These posts use sequential IDs starting from 2000 to avoid conflicts
-- ============================================================================

-- Clear any existing demo data (optional)
DELETE FROM wp_posts WHERE ID >= 999 AND ID < 2200;

-- ============================================================================
-- Create FULLTEXT Indexes
-- ============================================================================
-- Combined index for most queries
CREATE FULLTEXT INDEX idx_posts_fulltext ON wp_posts(post_title, post_content);

-- Separate indexes needed for Example B (weighted title ranking)
CREATE FULLTEXT INDEX idx_posts_title ON wp_posts(post_title);
CREATE FULLTEXT INDEX idx_posts_content ON wp_posts(post_content);

-- ============================================================================
-- NATURAL LANGUAGE MODE Examples
-- Posts about WordPress performance, caching, and optimization
-- ============================================================================

-- Post 1: Heavy focus on caching (will rank high for "wordpress performance caching")
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2001, 
    1, 
    NOW(), 
    UTC_TIMESTAMP(), 
    'WordPress performance is critical for user experience and SEO. Caching is the single most important factor in WordPress performance optimization. When you implement WordPress caching, you can dramatically improve page load times. There are several types of caching to consider: object cache, page cache, browser cache, and CDN caching. WordPress performance tuning requires understanding how caching works at each level. Object cache using Redis or Memcached stores database query results. Page caching saves fully rendered HTML. Browser caching tells browsers to store static assets locally. Together, these caching strategies can make WordPress performance exceptional.',
    'Ultimate Guide to WordPress Performance and Caching',
    'Learn how caching improves WordPress performance',
    'publish',
    'open',
    'open',
    '',
    'wordpress-performance-caching-guide',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 2: Focus on performance tuning (good for title ranking example)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2002,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Optimizing database queries is essential for site speed. Enable gzip compression on your server. Minify CSS and JavaScript files. Use a content delivery network. Lazy load images below the fold. Reduce HTTP requests by combining files. Choose a fast hosting provider with SSD storage.',
    'Performance Tuning for WordPress Sites',
    'Advanced techniques for WordPress optimization',
    'publish',
    'open',
    'open',
    '',
    'performance-tuning-wordpress',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 3: Long-form content about object cache and Redis
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2103,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Understanding object cache in WordPress is crucial for high-traffic sites. Object cache stores the results of complex database queries in memory, eliminating the need to run them repeatedly. Redis is a powerful in-memory data structure store perfect for persistent object caching. When you configure Redis as your object cache backend, WordPress can retrieve cached objects in microseconds instead of milliseconds. Redis persistent storage ensures your cache survives server restarts. The object cache drop-in file connects WordPress to Redis. Popular plugins like Redis Object Cache make setup straightforward. For enterprise WordPress installations, Redis object cache is essential. Persistent object caching with Redis can handle millions of requests per day. The key advantage of Redis over other solutions is its persistence and advanced data structures.',
    'Deep Dive into Object Cache with Redis',
    'Complete guide to persistent object caching',
    'publish',
    'open',
    'open',
    '',
    'object-cache-redis-guide',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 4: Contains stopwords - demonstrates they're ignored
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2104,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'There are many ways to speed up a WordPress site. First, choose quality hosting. Second, implement caching at multiple levels. Third, optimize your images using compression. Fourth, minimize plugins and only keep essential ones active. Fifth, use a lightweight theme. These strategies work together to make your WordPress site load faster.',
    'How to Speed Up a WordPress Site',
    'Simple strategies for faster page loads',
    'publish',
    'open',
    'open',
    '',
    'how-to-speed-up-wordpress',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- ============================================================================
-- BOOLEAN MODE Examples
-- Posts for testing required, excluded, and phrase matching
-- ============================================================================

-- Post 5: About WordPress cache WITHOUT plugins (for exclusion example)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2105,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress cache configuration can be done at the server level without relying on additional software. Apache mod_cache and nginx fastcgi_cache provide powerful WordPress cache solutions. Server-side WordPress cache delivers better performance than most alternatives. You can configure cache headers, set expiration rules, and implement cache purging strategies directly in your web server configuration. This approach to WordPress cache gives you complete control.',
    'Server-Level WordPress Cache Configuration',
    'Implementing cache without third-party tools',
    'publish',
    'open',
    'open',
    '',
    'server-level-wordpress-cache',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 6: WordPress caching PLUGIN (will be excluded by -plugin search)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2106,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'The best WordPress caching plugin options include WP Rocket, W3 Total Cache, and WP Super Cache. Each plugin offers different features for WordPress cache management. WP Rocket is a premium plugin with automatic cache configuration. W3 Total Cache is a free plugin with extensive options. Installing a caching plugin is the easiest way to improve WordPress performance.',
    'Top WordPress Caching Plugins Compared',
    'Review of popular caching plugin solutions',
    'publish',
    'open',
    'open',
    '',
    'wordpress-caching-plugins',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 7: Multiple variations of "optimize" (for prefix matching)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2107,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'When you optimize your database, you improve query performance. An optimizer tool can analyze slow queries. Database optimization is an ongoing process. The query optimizer chooses the most efficient execution plan. Regular optimization maintenance prevents bloat. Optimized tables use less disk space and respond faster. Image optimization reduces bandwidth usage. Code optimization eliminates redundant operations.',
    'Database Optimization Techniques',
    'How to optimize WordPress databases effectively',
    'publish',
    'open',
    'open',
    '',
    'database-optimization-techniques',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 8: Contains exact phrase "object cache" (for phrase matching)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2108,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'The object cache in WordPress stores database query results in memory. When WordPress needs data, it first checks the object cache. If the data exists in the object cache, WordPress skips the database query entirely. The object cache is particularly effective for repeated queries. Enabling persistent object cache requires a drop-in file and a backend like Redis or Memcached. The object cache API provides functions like wp_cache_get() and wp_cache_set().',
    'Understanding WordPress Object Cache',
    'Technical overview of the object cache system',
    'publish',
    'open',
    'open',
    '',
    'understanding-object-cache',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 9: Object cache with Redis, NOT Memcached (for combined boolean example)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    2009,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Redis has become the preferred backend for object cache in modern WordPress deployments. Unlike other solutions, Redis offers persistence, replication, and advanced data structures. Setting up object cache with Redis involves installing Redis server, adding the object cache drop-in, and configuring the connection. Redis handles object cache operations with exceptional speed. The combination of object cache and Redis provides enterprise-grade performance.',
    'Why Redis is Perfect for Object Cache',
    'Advantages of Redis over alternatives',
    'publish',
    'open',
    'open',
    '',
    'redis-object-cache-advantages',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 10: About cache and Redis (for tilde relevance boosting)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1010,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Modern cache strategies rely on in-memory storage solutions. Redis excels at cache operations with its lightning-fast read/write capabilities. Implementing cache with Redis reduces database load significantly. Redis cache can store various data types including strings, hashes, lists, and sets. Cache invalidation becomes manageable with Redis TTL features. The Redis cache implementation supports clustering for high availability.',
    'Advanced Cache Strategies with Redis',
    'Leveraging Redis for optimal cache performance',
    'publish',
    'open',
    'open',
    '',
    'advanced-cache-redis-strategies',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 11: Just about cache (for tilde example - Redis optional)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1011,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Cache fundamentals apply across all WordPress installations. Browser cache stores static assets locally. Page cache saves rendered HTML output. Database query cache reduces repetitive queries. Fragment cache stores specific page components. Cache warming prepopulates cache before traffic arrives. Cache headers control client-side caching behavior. Effective cache strategy combines multiple cache layers.',
    'Cache Fundamentals for WordPress',
    'Understanding different types of cache',
    'publish',
    'open',
    'open',
    '',
    'cache-fundamentals-wordpress',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- ============================================================================
-- QUERY EXPANSION MODE Examples
-- Posts with related terms and synonyms
-- ============================================================================

-- Post 12: SEO content with related terms (for query expansion)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1012,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Search engine optimization requires understanding how search engines rank content. Improving your search ranking depends on multiple factors including content quality, backlinks, and technical SEO. Organic traffic comes from unpaid search results. To increase organic traffic, focus on keyword research, on-page optimization, and link building. Search engine algorithms evaluate relevance and authority. Higher search ranking leads to more organic traffic and better visibility.',
    'Complete Guide to Search Engine Optimization',
    'Boost your search ranking and organic traffic',
    'publish',
    'open',
    'open',
    '',
    'search-engine-optimization-guide',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 13: More SEO-related content using synonym terms
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1013,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Content optimization for search engines involves strategic keyword placement and natural language. Meta descriptions influence click-through rates from search results. Title tags are critical ranking factors. Internal linking helps search engines understand site structure. Mobile optimization affects search ranking. Page speed impacts both ranking and organic traffic. Schema markup provides search engines with structured data.',
    'On-Page Optimization Checklist',
    'Essential elements for better search performance',
    'publish',
    'open',
    'open',
    '',
    'on-page-optimization-checklist',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 14: WordPress security with related terms (for query expansion)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1014,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress security requires multiple layers of protection. Install a web application firewall to block malicious requests. Scan regularly for malware using security plugins. Prevent brute force attacks by limiting login attempts. Security hardening includes disabling file editing, changing the database prefix, and hiding WordPress version. A firewall provides the first line of defense against attacks. Regular malware scans detect infections early.',
    'WordPress Security Best Practices',
    'Protect your site from malware and attacks',
    'publish',
    'open',
    'open',
    '',
    'wordpress-security-practices',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 15: More security content with related vocabulary
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1015,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Implementing security hardening protects against common vulnerabilities. Two-factor authentication adds login protection beyond passwords. Regular backups provide recovery options after security incidents. SSL certificates encrypt data transmission. Login protection includes CAPTCHA, IP whitelisting, and account lockouts after failed attempts. Security hardening checklist items include file permissions, database security, and removing unused themes.',
    'Advanced WordPress Security Hardening',
    'Comprehensive login protection and hardening techniques',
    'publish',
    'open',
    'open',
    '',
    'advanced-security-hardening',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 16: Speed-related content with synonyms (for query expansion)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1016,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Site performance affects user experience and search rankings. Caching reduces server load and improves response times. Content delivery networks distribute assets globally for faster delivery. Image optimization reduces file sizes without quality loss. TTFB (Time To First Byte) measures server responsiveness. Performance optimization techniques include minification, compression, and lazy loading. Fast TTFB indicates efficient server processing.',
    'Mastering Website Performance',
    'Optimization techniques for maximum speed',
    'publish',
    'open',
    'open',
    '',
    'mastering-website-performance',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 17: Hosting with related terms (for query expansion)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1017,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress hosting quality impacts site performance and reliability. Uptime guarantees ensure your site remains accessible. Bandwidth limits determine traffic capacity. Shared hosting is economical but resources are shared among multiple sites. VPS (Virtual Private Server) hosting provides dedicated resources and better performance. CDN (Content Delivery Network) integration improves global load times. Monitor uptime to ensure hosting reliability.',
    'Choosing the Right WordPress Hosting',
    'Understanding uptime, bandwidth, and hosting types',
    'publish',
    'open',
    'open',
    '',
    'choosing-wordpress-hosting',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 18: More hosting content with related terms
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1018,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Managed WordPress hosting includes automatic updates and security monitoring. Shared hosting suits small sites with limited traffic. VPS hosting scales better for growing sites. Cloud hosting offers flexibility and redundancy. CDN integration is essential for international audiences. Evaluate hosting based on uptime history, bandwidth allocation, and support quality. Premium hosting typically includes CDN, backups, and performance optimization.',
    'Managed vs Shared vs VPS Hosting',
    'Comparing hosting options for WordPress',
    'publish',
    'open',
    'open',
    '',
    'comparing-hosting-options',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- ============================================================================
-- Additional supporting posts for variety
-- ============================================================================

-- Post 19: General WordPress post (lower relevance for most searches)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1019,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress is a versatile content management system powering millions of websites worldwide. It offers thousands of themes and plugins for customization. The WordPress community provides extensive documentation and support. Regular updates ensure security and add new features. WordPress can be used for blogs, business sites, portfolios, and e-commerce stores.',
    'Introduction to WordPress',
    'Getting started with the WordPress platform',
    'publish',
    'open',
    'open',
    '',
    'introduction-to-wordpress',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 20: About themes (different topic - provides variety)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1020,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Choosing the right WordPress theme affects both aesthetics and performance. Lightweight themes load faster and use fewer resources. Responsive themes adapt to different screen sizes. Premium themes often include advanced features and dedicated support. Theme customization options range from basic color changes to complete layout control. Consider page builders for complex designs.',
    'Guide to WordPress Themes',
    'Finding and customizing the perfect theme',
    'publish',
    'open',
    'open',
    '',
    'guide-to-wordpress-themes',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- ============================================================================
-- ADDITIONAL POSTS FOR ENHANCED FTS DEMONSTRATIONS
-- These posts provide more varied results for key search terms
-- ============================================================================

-- Post 21: Memcached as primary topic (alternative to Redis)
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1021,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Memcached is a distributed memory caching system originally developed for LiveJournal. Memcached stores data in RAM for extremely fast retrieval. Many high-traffic WordPress sites use Memcached for session storage and database query caching. Memcached operates as a key-value store with simple commands for get, set, and delete operations. Unlike some alternatives, Memcached focuses purely on caching without persistence. Installing Memcached requires the PHP memcached extension. Memcached clusters distribute cache across multiple servers. The Memcached protocol is simple and efficient. WordPress can use Memcached through object cache drop-ins.',
    'Getting Started with Memcached',
    'High-performance caching with Memcached',
    'publish',
    'open',
    'open',
    '',
    'getting-started-memcached',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 22: Comparing Memcached vs Redis
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1022,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'When choosing between Memcached and Redis, consider your specific needs. Memcached excels at simple key-value caching with lower memory overhead. Redis offers advanced data structures and persistence options. For WordPress object cache, both Memcached and Redis work well. Memcached is simpler to configure and uses slightly less memory per item. Redis provides backup capabilities that Memcached lacks. Performance-wise, Memcached and Redis are comparable for basic operations. If you need data persistence, choose Redis. For pure caching without persistence, Memcached is sufficient. Both Memcached and Redis integrate seamlessly with WordPress.',
    'Memcached vs Redis: Which is Better?',
    'Detailed comparison of caching solutions',
    'publish',
    'open',
    'open',
    '',
    'memcached-vs-redis-comparison',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 23: Multiple mentions of "object cache" phrase
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1023,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'The WordPress object cache is a critical performance feature. By default, WordPress includes a non-persistent object cache that resets on each page load. Installing a persistent object cache dramatically improves performance. The object cache stores results from expensive database queries. When you call wp_cache_get(), WordPress checks the object cache first. If data exists in the object cache, the database query is skipped. Configuring a persistent object cache requires an object-cache.php drop-in file. Popular backends for the object cache include Redis and Memcached. The object cache API is consistent regardless of backend. Developers interact with the object cache using standard WordPress functions. The object cache reduces database load significantly.',
    'Mastering the WordPress Object Cache',
    'Complete guide to object cache implementation',
    'publish',
    'open',
    'open',
    '',
    'mastering-wordpress-object-cache',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 24: Redis with object and cache mentioned separately
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1024,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Redis provides excellent cache capabilities for WordPress deployments. The Redis server stores object data in memory with optional persistence to disk. When implementing cache solutions, Redis stands out for its versatility. Beyond basic cache operations, Redis supports complex object types like lists, sets, and sorted sets. WordPress cache implementations often choose Redis for its reliability. The cache hit rate with Redis typically exceeds 95 percent on well-configured sites. Redis cache can handle millions of object lookups per second. Persistent storage in Redis ensures cache survives server restarts.',
    'Redis for WordPress Caching Solutions',
    'Why Redis excels at cache management',
    'publish',
    'open',
    'open',
    '',
    'redis-wordpress-caching',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 25: Heavy use of "cache" without object or Redis
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1025,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Understanding cache layers improves WordPress performance significantly. Browser cache stores static files on the client side. Page cache saves entire HTML output for quick delivery. Opcode cache stores compiled PHP bytecode. Fragment cache stores specific page sections. Database query cache reduces repetitive database calls. CDN cache distributes content globally. Cache warming populates cache before traffic arrives. Cache invalidation removes outdated entries. Cache headers control browser caching behavior. Cache plugins automate cache management. Effective cache strategy combines multiple cache types. Cache monitoring helps identify cache hits and misses. Cache configuration varies by hosting environment.',
    'Understanding WordPress Cache Layers',
    'Comprehensive overview of cache types',
    'publish',
    'open',
    'open',
    '',
    'understanding-cache-layers',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 26: Plugin-focused caching article
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1026,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress cache plugin selection impacts site performance. WP Rocket is a premium cache plugin with automatic configuration. W3 Total Cache is a comprehensive free plugin supporting multiple cache backends. WP Super Cache is a simpler plugin ideal for shared hosting. Cache Enabler is a lightweight plugin focused on page caching. Each plugin offers different cache features and configuration options. Installing a cache plugin typically activates page caching immediately. Advanced plugin settings control cache expiration and exclusions. Some plugin solutions include CDN integration. Cache plugin compatibility varies with hosting environments. Popular plugin choices support both file-based and memory-based caching.',
    'Best WordPress Cache Plugins Reviewed',
    'Comparing top plugin options for caching',
    'publish',
    'open',
    'open',
    '',
    'best-cache-plugins-reviewed',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 27: All key terms together - "object cache redis persistent"
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1027,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Implementing persistent object cache with Redis transforms WordPress performance. The object cache system with Redis persistence ensures data survives server reboots. Unlike non-persistent solutions, Redis maintains the object cache across restarts. Persistent object cache reduces database load by storing frequently accessed data. Redis object cache handles millions of requests daily on enterprise sites. The persistent nature of Redis object cache provides reliability. Configure persistent object cache using the Redis Object Cache plugin or custom drop-in. Redis persistence modes include RDB snapshots and AOF logging. The object cache with Redis persistent storage is ideal for high-traffic WordPress installations. Persistent object cache using Redis outperforms memory-only solutions.',
    'Persistent Object Cache with Redis',
    'Enterprise-grade object cache using Redis persistence',
    'publish',
    'open',
    'open',
    '',
    'persistent-object-cache-redis',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 28: WordPress and performance without much caching
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1028,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress performance optimization extends beyond caching. Database indexing improves query performance significantly. Optimizing WordPress images reduces bandwidth and load times. Choosing efficient WordPress themes impacts performance. Minimizing WordPress plugins decreases overhead. WordPress core updates often include performance improvements. Database cleanup removes WordPress post revisions and spam. Lazy loading WordPress images defers loading until needed. WordPress performance monitoring identifies bottlenecks. Upgrading PHP versions improves WordPress execution speed. WordPress hosting quality affects baseline performance.',
    'WordPress Performance Beyond Caching',
    'Alternative optimization strategies',
    'publish',
    'open',
    'open',
    '',
    'wordpress-performance-beyond-caching',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 29: Performance and caching together heavily
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1029,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Performance caching is the foundation of fast WordPress sites. Implementing performance-focused caching reduces server load and improves response times. WordPress caching directly impacts performance metrics. Performance improvements from caching are measurable and significant. Multi-layer caching delivers optimal performance. Performance gains from browser caching complement server-side caching. Monitoring caching performance helps tune configurations. Performance testing reveals caching effectiveness. Caching strategies for performance include page caching, object caching, and opcode caching. Performance benchmarks show caching reduces load times by 70-90 percent. WordPress performance caching is not optional for high-traffic sites.',
    'Performance Caching Strategies',
    'Maximizing WordPress speed through caching',
    'publish',
    'open',
    'open',
    '',
    'performance-caching-strategies',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 30: WordPress mentioned heavily with various topics
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1030,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress powers over 40 percent of all websites globally. The WordPress ecosystem includes thousands of themes and plugins. WordPress multisite enables managing multiple WordPress installations. WordPress REST API allows headless WordPress architectures. WordPress security requires regular WordPress core updates. WordPress SEO plugins improve search visibility. WordPress page builders simplify WordPress design. WordPress hosting options range from shared to enterprise. WordPress community provides extensive WordPress documentation. WordPress Gutenberg changed WordPress content editing. WordPress developers extend WordPress functionality through custom code.',
    'WordPress Ecosystem Overview',
    'Understanding the WordPress platform',
    'publish',
    'open',
    'open',
    '',
    'wordpress-ecosystem-overview',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 31: Plugin development article
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1031,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress plugin development requires understanding the plugin API. A plugin extends WordPress functionality through hooks and filters. Plugin developers register custom post types and taxonomies. Plugin architecture should follow WordPress coding standards. Creating a plugin starts with a plugin header comment. Plugin activation hooks initialize plugin data. Plugin settings pages use the WordPress Settings API. Plugin security prevents SQL injection and XSS attacks. Plugin performance impacts site speed. Plugin updates should maintain backward compatibility. Popular plugin repositories include WordPress.org and premium marketplaces.',
    'WordPress Plugin Development Guide',
    'Building custom plugins for WordPress',
    'publish',
    'open',
    'open',
    '',
    'wordpress-plugin-development',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 32: Redis persistence technical details
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1032,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Redis persistence mechanisms ensure data durability. RDB persistence creates point-in-time snapshots. AOF persistence logs every write operation. Combining RDB and AOF provides maximum persistence guarantees. Redis persistence configuration balances performance and durability. Persistence intervals affect Redis write performance. Redis persistence protects against data loss during crashes. Monitoring Redis persistence helps ensure backups succeed. Redis persistence files can be replicated for disaster recovery. Tuning Redis persistence parameters optimizes for your workload.',
    'Redis Persistence Explained',
    'Understanding RDB and AOF persistence',
    'publish',
    'open',
    'open',
    '',
    'redis-persistence-explained',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 33: Caching without Redis or Memcached mentioned
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1033,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'File-based caching stores cached content in the filesystem. Transient caching uses the WordPress database for temporary data. Varnish caching operates as a reverse proxy. CDN caching distributes content across global edge servers. Browser caching leverages HTTP cache headers. Application-level caching stores computed results. Full-page caching saves complete HTML output. Fragment caching stores reusable page components. Caching strategies should match traffic patterns.',
    'Alternative Caching Approaches',
    'Exploring different caching methods',
    'publish',
    'open',
    'open',
    '',
    'alternative-caching-approaches',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 34: Object-oriented programming (contains "object" but not "object cache")
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1034,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'Object-oriented programming in WordPress follows modern PHP standards. Creating custom objects encapsulates related functionality. Object properties store state while object methods define behavior. WordPress core extensively uses object-oriented design patterns. The WP_Query object handles database queries. The WP_User object represents users. Object inheritance enables code reuse through parent classes. Understanding object scope prevents memory leaks. Object instantiation creates new instances. Object serialization stores complex data structures.',
    'Object-Oriented WordPress Development',
    'Using OOP principles in WordPress',
    'publish',
    'open',
    'open',
    '',
    'object-oriented-wordpress',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- Post 35: All key terms used but in different contexts
INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, comment_status, ping_status, post_password, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, post_parent, guid, menu_order, post_type, post_mime_type, comment_count)
VALUES (
    1035,
    1,
    NOW(),
    UTC_TIMESTAMP(),
    'WordPress performance optimization requires multiple strategies. The object cache improves database performance when properly configured with Redis or Memcached. Performance caching at the page level complements object-level caching. Installing a cache plugin simplifies cache management. Redis provides persistent object cache capabilities. Memcached offers high-performance key-value caching. WordPress cache strategies should match site requirements. Performance monitoring reveals cache effectiveness. Plugin selection impacts both performance and caching efficiency.',
    'Complete WordPress Performance Guide',
    'Comprehensive optimization strategies',
    'publish',
    'open',
    'open',
    '',
    'complete-wordpress-performance',
    '',
    '',
    NOW(),
    UTC_TIMESTAMP(),
    '',
    0,
    '',
    0,
    'post',
    '',
    0
);

-- ============================================================================
-- Verification queries to test the data
-- ============================================================================

-- Show all inserted posts
-- SELECT ID, post_title FROM wp_posts WHERE ID >= 2000 AND ID < 2000 ORDER BY ID;

-- Example A: Natural Language search
-- SELECT ID, post_title, 
--        MATCH(post_title, post_content) AGAINST ('wordpress performance caching' IN NATURAL LANGUAGE MODE) AS score
-- FROM wp_posts 
-- WHERE MATCH(post_title, post_content) AGAINST ('wordpress performance caching' IN NATURAL LANGUAGE MODE)
-- ORDER BY score DESC;



-- Boolean Mode: Test exclusion
-- SELECT ID, post_title
-- FROM wp_posts
-- WHERE MATCH(post_title, post_content) AGAINST ('+wordpress +cache -plugin' IN BOOLEAN MODE);

-- Boolean Mode: Test prefix matching
-- SELECT ID, post_title
-- FROM wp_posts
-- WHERE MATCH(post_title, post_content) AGAINST ('optimiz*' IN BOOLEAN MODE);

-- Boolean Mode: Test exact phrase
-- SELECT ID, post_title
-- FROM wp_posts
-- WHERE MATCH(post_title, post_content) AGAINST ('"object cache"' IN BOOLEAN MODE);

-- Query Expansion: Test with 'seo'
-- SELECT ID, post_title,
--        MATCH(post_title, post_content) AGAINST ('seo' WITH QUERY EXPANSION) AS score
-- FROM wp_posts
-- ORDER BY score DESC
-- LIMIT 10;

COMMIT;
