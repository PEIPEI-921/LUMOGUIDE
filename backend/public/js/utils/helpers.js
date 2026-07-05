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
  return 'https://api.lumoguide.com/' + path.replace(/^\//, '');
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
