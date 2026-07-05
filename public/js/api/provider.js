/* ============================================
   API Provider — fetch wrapper matching ApiProvider
   NEVER throws, always returns { success, data, message }
   ============================================ */

const ApiProvider = {
  baseUrl: API_URL,

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
  async request(method, path, { params, data, headers } = {}) {
    try {
      const url = this._buildUrl(path, params);
      const opts = {
        method,
        headers: this._buildHeaders(headers),
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
      const code = json.code !== undefined ? parseInt(json.code, 10) : response.status;
      const message = json.message || json.msg || '';
      const resData = json.data !== undefined ? json.data : json;

      // Handle 401 — redirect to login
      if (code === 401 || response.status === 401) {
        Storage.logout();
        // Use Vue router if available
        const app = document.querySelector('#app').__vue_app__;
        if (app) {
          const router = app.config.globalProperties.$router;
          if (router) router.push('/login');
        }
      }

      return {
        success: code === 200,
        code: code,
        message: message,
        data: resData,
        raw: json
      };
    } catch (err) {
      console.error('API Error:', method, path, err);
      return {
        success: false,
        code: -1,
        message: err.message || 'Network error',
        data: null,
        raw: null
      };
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
