(function () {
    if (typeof wpSignalsData === 'undefined') {
        console.log('[wp-signals] wpSignalsData not found.');
        return;
    }

    console.log('[wp-signals] Admin script loaded.', wpSignalsData);

    const queryInput = document.querySelector('#ws_query');
    const queryButton = document.querySelector('#ws_query_run');
    const resultsContainer = document.querySelector('#wp-signals-results');
    const debugContainer = document.querySelector('#wp-signals-debug');

    if (!queryInput || !queryButton || !resultsContainer || !debugContainer) {
        console.log('[wp-signals] Missing DOM elements.', {
            queryInput,
            queryButton,
            resultsContainer,
            debugContainer,
        });
        return;
    }

    console.log('[wp-signals] DOM ready.', {
        queryInput,
        queryButton,
        resultsContainer,
        debugContainer,
    });

    const clearResults = () => {
        console.log('[wp-signals] Clearing results.');
        resultsContainer.innerHTML = '';
    };

    const renderEmptyState = (message) => {
        console.log('[wp-signals] Render empty state:', message);
        resultsContainer.innerHTML = `<p>${message}</p>`;
    };

    const addDebugEntry = (eventName, payload) => {
        console.log('[wp-signals] Debug entry:', eventName, payload);
        const entry = document.createElement('li');
        entry.innerHTML = `<strong>${eventName}</strong><pre>${JSON.stringify(payload, null, 2)}</pre>`;
        debugContainer.prepend(entry);
    };

    const sendEvent = (eventName, payload, options = {}) => {
        console.log('[wp-signals] Sending event:', eventName, payload);
        addDebugEntry(eventName, payload);

        const data = new FormData();
        data.append('action', 'wp_signals_log_event');
        data.append('nonce', wpSignalsData.nonce);
        data.append('event_name', eventName);
        data.append('event_meta_details', JSON.stringify(payload));
        if (options.query) {
            data.append('query', options.query);
        }
        if (options.results) {
            data.append('results', JSON.stringify(options.results));
        }

        fetch(wpSignalsData.ajaxUrl, {
            method: 'POST',
            credentials: 'same-origin',
            body: data,
        })
            .then((response) => {
                console.log('[wp-signals] Event response:', response);
            })
            .catch((error) => {
                console.log('[wp-signals] Event error:', error);
            });
    };

    const createResultCard = (item) => {
        console.log('[wp-signals] Creating card for item:', item);
        const card = document.createElement('div');
        card.className = 'wp-signals-card';

        const title = item.title || item.post_title || item.heading || 'Untitled';
        const content = item.content || item.excerpt || item.summary || '';
        const permalink = item.permalink || item.link || item.url || '#';
        const postId = item.post_id || item.id || '';

        const body = document.createElement('div');
        body.className = 'wp-signals-body';

        const titleEl = document.createElement('div');
        titleEl.className = 'wp-signals-title';
        titleEl.textContent = title;

        const idEl = document.createElement('div');
        idEl.className = 'wp-signals-post-id';
        idEl.textContent = `Post ID: ${postId || 'N/A'}`;

        const contentEl = document.createElement('div');
        contentEl.className = 'wp-signals-content';
        contentEl.textContent = content || 'No content preview.';

        body.append(titleEl, idEl, contentEl);
        let hoverLogged = false;
        body.addEventListener('mouseenter', () => {
            if (hoverLogged) {
                return;
            }
            hoverLogged = true;
            console.log('[wp-signals] Hover on result textbox:', item);
            sendEvent(
                'event_hover',
                {
                    postId,
                    label: title,
                }
            );
        });

        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'button button-secondary wp-signals-record';
        button.textContent = 'Record Click';
        button.addEventListener('click', () => {
            console.log('[wp-signals] Record Click button pressed for item:', item);
            sendEvent(
                'event_click',
                {
                    postId,
                    label: title,
                }
            );
        });

        card.append(body, button);
        return card;
    };

    const fetchResults = async (query) => {
        console.log('[wp-signals] Fetching results for query:', query);
        clearResults();
        renderEmptyState('Loading results...');

        try {
            const limit = Number(wpSignalsData.limit) || 3;
            const url = new URL(wpSignalsData.hybridSearchUrl, window.location.origin);
            url.searchParams.set('query', query);
            url.searchParams.set('limit', String(limit));

            const response = await fetch(url.toString());

            console.log('[wp-signals] Raw response:', response);

            if (!response.ok) {
                throw new Error('Failed to fetch results.');
            }

            const payload = await response.json();
            console.log('[wp-signals] Parsed payload:', payload);
            const items = Array.isArray(payload)
                ? payload
                : payload?.results || payload?.data || [];

            console.log('[wp-signals] Normalized items:', items);

            const trimmedItems = items.slice(0, 3);
            console.log('[wp-signals] Trimmed items (take first 3):', trimmedItems);

            clearResults();

            if (!trimmedItems.length) {
                renderEmptyState('No results found.');
                return;
            }

            trimmedItems.forEach((item) => {
                resultsContainer.appendChild(createResultCard(item));
            });

            const resultIds = trimmedItems
                .map((item) => item.post_id || item.id)
                .filter(Boolean);

            sendEvent(
                'event_search',
                {
                    results: trimmedItems,
                    resultCount: trimmedItems.length,
                },
                {
                    query,
                    results: resultIds,
                }
            );
        } catch (error) {
            console.log('[wp-signals] Fetch error:', error);
            clearResults();
            renderEmptyState('Unable to load results.');
        }
    };

    queryButton.addEventListener('click', () => {
        console.log('[wp-signals] Run query clicked.');
        const query = queryInput.value.trim();
        if (!query) {
            renderEmptyState('Please enter a query.');
            return;
        }
        fetchResults(query);
    });

    queryInput.addEventListener('keydown', (event) => {
        if (event.key === 'Enter') {
            console.log('[wp-signals] Enter pressed in query input.');
            event.preventDefault();
            queryButton.click();
        }
    });
})();