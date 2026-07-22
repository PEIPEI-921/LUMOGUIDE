/* ============================================
   Helper Utilities — mirrors mobile helpers
   ============================================ */

/**
 * Chinese time-ago formatting (matches mobile timeAgo pattern)
 * @param {string|Date} time - ISO date string or Date object
 * @returns {string} Relative time string in Chinese
 */
function timeAgo(time) {
  if (!time) return '';
  const now = Date.now();
  const date = typeof time === 'string' ? new Date(time.replace(/-/g, '/')) : new Date(time);
  if (isNaN(date.getTime())) return '';
  const diff = Math.floor((now - date.getTime()) / 1000);

  if (diff < 60) return '剛剛';
  if (diff < 3600) return Math.floor(diff / 60) + '分鐘前';
  if (diff < 86400) return Math.floor(diff / 3600) + '小時前';
  if (diff < 2592000) return Math.floor(diff / 86400) + '天前';
  if (diff < 31536000) return Math.floor(diff / 2592000) + '個月前';
  return Math.floor(diff / 31536000) + '年前';
}

/**
 * Format date to yyyy-MM-dd
 */
function formatDate(date) {
  if (!date) return '';
  const d = typeof date === 'string' ? new Date(date.replace(/-/g, '/')) : new Date(date);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

/**
 * Build full image URL (backend may return relative paths)
 */
function imageUrl(path) {
  if (!path) return '';
  if (path.startsWith('http')) return path;
  return window.location.origin + '/' + path.replace(/^\//, '');
}

/**
 * Safe integer from JSON value (mirrors safeInt extension)
 */
function safeInt(obj, key, defaultVal = null) {
  const v = obj[key];
  if (v === null || v === undefined || v === '') return defaultVal;
  const n = parseInt(v, 10);
  return isNaN(n) ? defaultVal : n;
}

/**
 * Safe string from JSON value (mirrors safeString extension)
 */
function safeString(obj, key, defaultVal = null) {
  const v = obj[key];
  if (v === null || v === undefined) return defaultVal;
  return String(v);
}

/**
 * Safe list from JSON value (mirrors safeList extension)
 */
function safeList(obj, key, defaultVal = []) {
  const v = obj[key];
  if (Array.isArray(v)) return v;
  return defaultVal;
}

/**
 * Show a simple toast message
 */
function showToast(msg, duration = 2000) {
  const existing = document.querySelector('.toast');
  if (existing) existing.remove();
  const el = document.createElement('div');
  el.className = 'toast';
  el.textContent = msg;
  document.body.appendChild(el);
  setTimeout(() => {
    el.remove();
  }, duration);
}

/**
 * Debounce function
 */
function debounce(fn, delay = 300) {
  let timer;
  return function (...args) {
    clearTimeout(timer);
    timer = setTimeout(() => fn.apply(this, args), delay);
  };
}

/**
 * Throttle function
 */
function throttle(fn, delay = 300) {
  let last = 0;
  return function (...args) {
    const now = Date.now();
    if (now - last >= delay) {
      last = now;
      fn.apply(this, args);
    }
  };
}

/**
 * Parse API response — extracts code, message, data from the envelope
 */
function parseResponse(data) {
  return {
    code: data?.code ?? -1,
    message: data?.message || data?.msg || '',
    data: data?.data ?? null
  };
}

/**
 * Truncate text with ellipsis
 */
function truncate(text, maxLen = 50) {
  if (!text || text.length <= maxLen) return text || '';
  return text.slice(0, maxLen) + '...';
}

/* ============================================
   ListPageHelper — reusable pagination logic
   Usage:
     data() {
       return { ...ListPageHelper.state() };
     },
     methods: {
       async fetchData(reset) {
         await ListPageHelper.fetch(this, ApiUrl.someList, { per_page: 10 }, reset);
       }
     }
   ============================================ */

const ListPageHelper = {
  /**
   * Create reactive state for a list page
   */
  state() {
    return {
      list: [],
      page: 1,
      hasMore: true,
      loading: false,
      loaded: false,
      refreshing: false
    };
  },

  /**
   * Fetch list data with pagination support
   *
   * @param {Object} vm        - Vue component instance (this)
   * @param {string} apiUrl    - API endpoint URL
   * @param {Object} params    - Query params (excluding page)
   * @param {boolean} reset    - Whether to reset the list (true = refresh from page 1)
   * @param {string} listKey   - Optional: key to extract list from response data (default: 'data')
   * @returns {Promise<boolean>} - true if data was loaded
   */
  async fetch(vm, apiUrl, params = {}, reset = false, listKey = 'data') {
    if (vm.loading || vm.refreshing) return false;

    if (reset) {
      vm.page = 1;
      vm.hasMore = true;
      vm.refreshing = true;
    }

    if (!vm.hasMore && !reset) return false;

    vm.loading = true;
    const res = await ApiProvider.get(apiUrl, { ...params, page: vm.page });
    vm.loading = false;
    vm.refreshing = false;
    vm.loaded = true;

    if (res.success && res.data) {
      const list = Array.isArray(res.data)
        ? res.data
        : (res.data[listKey] || res.data.data || []);
      vm.list = reset ? list : [...vm.list, ...list];
      vm.hasMore = list.length >= (params.per_page || 10);
      if (list.length > 0) vm.page++;
      return true;
    }

    return false;
  }
};

/* ============================================
   setupInfiniteScroll — IntersectionObserver helper
   Usage:
     mounted() {
       this._scrollObserver = setupInfiniteScroll(
         this.$el.querySelector('.list-container'),
         this.$el.querySelector('.scroll-sentinel'),
         () => { if (this.hasMore) this.fetchData(false); }
       );
     },
     beforeUnmount() {
       if (this._scrollObserver) this._scrollObserver.disconnect();
     }
   ============================================ */

/**
 * Set up infinite scroll using IntersectionObserver
 *
 * @param {HTMLElement} containerEl - The scrollable container (null = viewport)
 * @param {HTMLElement} sentinelEl  - The sentinel element at bottom of list
 * @param {Function}    callback    - Called when sentinel becomes visible
 * @returns {IntersectionObserver}
 */
function setupInfiniteScroll(containerEl, sentinelEl, callback) {
  if (!sentinelEl) return null;

  const observer = new IntersectionObserver(
    (entries) => {
      if (entries[0].isIntersecting) {
        callback();
      }
    },
    {
      root: containerEl || null,
      threshold: 0.1
    }
  );

  observer.observe(sentinelEl);
  return observer;
}
