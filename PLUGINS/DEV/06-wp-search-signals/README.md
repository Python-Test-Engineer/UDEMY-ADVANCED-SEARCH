# WP Signals Plugin - Futuristic Theme Installation

## Files Included

1. **06-wp-search-signals.php** - Main plugin file (updated to use new CSS)
2. **futuristic-styles.css** - Futuristic cyberpunk-themed stylesheet
3. **admin.js** - Admin JavaScript (unchanged)

## Installation Instructions

### Step 1: Update Your Plugin Files

1. Navigate to your WordPress plugin directory:
   ```
   wp-content/plugins/wp-search-signals/
   ```

2. Replace the main plugin file:
   - Backup your existing `06-wp-search-signals.php`
   - Replace with the new `06-wp-search-signals.php`

### Step 2: Add the Assets

1. Create an `assets` folder in your plugin directory if it doesn't exist:
   ```
   wp-content/plugins/wp-search-signals/assets/
   ```

2. Add the CSS file:
   - Copy `futuristic-styles.css` to the `assets` folder
   - The file should be at: `assets/futuristic-styles.css`

3. Add the JavaScript file:
   - Copy `admin.js` to the `assets` folder
   - The file should be at: `assets/admin.js`

### Step 3: Clear Cache

1. Clear your WordPress cache (if using a caching plugin)
2. Do a hard refresh in your browser (Ctrl+Shift+R or Cmd+Shift+R)

## File Structure

Your plugin directory should look like this:

```
wp-search-signals/
├── 06-wp-search-signals.php
└── assets/
    ├── futuristic-styles.css
    └── admin.js
```

## Features of the Futuristic Theme

✨ **Cyberpunk Design**
- Dark background with neon cyan and green accents
- Glowing text effects and shadows
- Animated gradient borders

🎯 **Scoped Styling**
- All CSS is scoped to `.toplevel_page_wp-signals`
- Won't interfere with other WordPress admin pages

🎨 **Interactive Effects**
- Hover animations on result cards
- Button ripple effects
- Smooth transitions
- Loading states

📱 **Responsive**
- Works on all screen sizes
- Mobile-friendly interface

## Troubleshooting

**Styles not showing?**
1. Check that files are in the correct location
2. Clear browser cache (Ctrl+Shift+R)
3. Check browser console for 404 errors
4. Verify file permissions (should be readable)

**Old styles still showing?**
1. Make sure you're using the updated PHP file
2. Clear WordPress object cache
3. Hard refresh your browser

## Support

If you encounter any issues, check:
- File paths are correct
- Files have proper permissions
- No PHP errors in WordPress debug log
