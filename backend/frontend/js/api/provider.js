/* ============================================
   API Provider — fetch wrapper matching ApiProvider
   NEVER throws, always returns { success, data, message }
   ============================================ */

const ApiProvider = {
  baseUrl: API_URL,

  // ── In-memory response cache ──
  _cache: new Map(),
  _cacheDefaultTTL: 60000, // 1 min default
  _cacheTTL: {
    '/common/config': 1800000,        // 30 min
    '/common/getContinentsList': 600000, // 10 min
    '/city/lists': 300000,            // 5 min
    '/city/list': 300000,
    '/common/homeData': 60000,        // 1 min
  },

  _cacheKey(path, params) {
    const qs = params ? JSON.stringify(params) : '';
    return path + '|' + qs;
  },

  _getTTL(path) {
    for (const [pattern, ttl] of Object.entries(this._cacheTTL)) {
      if (path.includes(pattern)) return ttl;
    }
    return this._cacheDefaultTTL;
  },

  _getCached(key) {
    const entry = this._cache.get(key);
    if (!entry) return null;
    if (Date.now() - entry.time > entry.ttl) {
      this._cache.delete(key);
      return null;
    }
    return entry.data;
  },

  _setCache(key, data, ttl) {
    // Clean up old entries periodically (keep cache under 200 entries)
    if (this._cache.size > 200) {
      const now = Date.now();
      for (const [k, v] of this._cache) {
        if (now - v.time > v.ttl) this._cache.delete(k);
      }
    }
    this._cache.set(key, { data, time: Date.now(), ttl });
  },

  /** Invalidate cache entries matching a path prefix */
  invalidateCache(pathPrefix) {
    for (const key of this._cache.keys()) {
      if (key.startsWith(pathPrefix)) this._cache.delete(key);
    }
  },

  /**
   * Build full URL with query parameters
   */
  _buildUrl(path, params) {
    let url = this.baseUrl + path;
    if (params && Object.keys(params).length > 0) {
      const qs = Object.entries(params)
        .filter(([_, v]) => v !== null && v !== undefined && v !== '')
        .map(([k, v]) => encodeURIComponent(k) + '=' + encodeURIComponent(v))
        .join('&');
      if (qs) url += '?' + qs;
    }
    return url;
  },

  /**
   * Build headers with optional auth token
   */
  _buildHeaders(extraHeaders) {
    const headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...extraHeaders
    };
    // Attach auth token if available
    const token = Storage.token;
    if (token) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    return headers;
  },

  /**
   * Core request method
   */
  async request(method, path, { params, data, headers, cache } = {}) {
    // ── Cache check for GET (skip if cache:false) ──
    const cacheKey = this._cacheKey(path, params);
    if (method === 'GET' && cache !== false) {
      const cached = this._getCached(cacheKey);
      if (cached) return cached;
    }

    // AbortController for 15s timeout
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 15000);

    try {
      const url = this._buildUrl(path, params);
      const opts = {
        method,
        headers: this._buildHeaders(headers),
        signal: controller.signal,
      };

      if (data && method !== 'GET') {
        // For multipart/form-data (file uploads)
        if (data instanceof FormData) {
          delete opts.headers['Content-Type']; // let browser set boundary
          opts.body = data;
        } else {
          opts.body = JSON.stringify(data);
        }
      }

      const response = await fetch(url, opts);
      const json = await response.json();

      // Map snake_case to a consistent code/message/data envelope
      const parsed = parseInt(json.code, 10);
      const code = !isNaN(parsed) ? parsed : response.status;
      const message = json.message || json.msg || '';
      const resData = json.data !== undefined ? json.data : json;

      // Handle 401 — redirect to login (with re-entrancy guard)
      // Use clearAuth() NOT logout() — preserve remember-me credentials
      if ((code === 401 || response.status === 401) && !this._redirecting) {
        this._redirecting = true;
        Storage.clearAuth();
        // Use Vue router if available
        const app = document.querySelector('#app').__vue_app__;
        if (app) {
          const router = app.config.globalProperties.$router;
          if (router) router.push('/login');
        }
      }

      const result = {
        success: code === 200,
        code: code,
        message: message,
        data: resData,
        raw: json
      };

      // ── Cache successful GET responses ──
      if (method === 'GET' && result.success && cache !== false) {
        this._setCache(cacheKey, result, this._getTTL(path));
      }

      // ── Invalidate cache on mutations ──
      if (method !== 'GET' && result.success) {
        this.invalidateCache(path);
      }

      return result;
    } catch (err) {
      if (err.name === 'AbortError') {
        console.error('API Timeout:', method, path);
        return { success: false, code: -1, message: 'Request timeout', data: null, raw: null };
      }
      console.error('API Error:', method, path, err);
      return {
        success: false,
        code: -1,
        message: err.message || 'Network error',
        data: null,
        raw: null
      };
    } finally {
      clearTimeout(timeout);
    }
  },

  async get(path, params) {
    return this.request('GET', path, { params });
  },

  async post(path, data) {
    return this.request('POST', path, { data });
  },

  async put(path, data) {
    return this.request('PUT', path, { data });
  },

  async patch(path, data) {
    return this.request('PATCH', path, { data });
  },

  async delete(path, data) {
    return this.request('DELETE', path, { data });
  },

  /**
   * File upload helper
   */
  async upload(path, file, fieldName = 'file') {
    const formData = new FormData();
    formData.append(fieldName, file);
    return this.request('POST', path, { data: formData });
  }
};
