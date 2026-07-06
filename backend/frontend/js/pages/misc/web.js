/* ============================================
   Web View — 内嵌网页
   Route: /web?url=xxx&title=xxx
   ============================================ */

const WebViewPage = {
  template: `
    <div class="webview-page">
      <!-- Header -->
      <header class="webview-header safe-top">
        <button class="webview-back" @click="goBack">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 18 9 12 15 6"></polyline>
          </svg>
        </button>
        <h1 class="webview-title font-display">{{ title }}</h1>
        <button class="webview-close" @click="goBack" title="关闭">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </header>

      <!-- Invalid URL -->
      <div v-if="!url" class="page-content">
        <div class="ds-empty">
          <div style="font-size:48px;margin-bottom:12px">🌐</div>
          <p style="color:var(--color-secondary-text);margin-bottom:16px">{{ $t('無效的網頁地址') }}</p>
          <button @click="goBack" class="ds-btn ds-btn-primary">{{ $t('返回') }}</button>
        </div>
      </div>

      <!-- Loading -->
      <div v-else-if="loading" class="webview-loading">
        <div class="spinner"></div>
        <p style="color:var(--color-secondary-text);margin-top:12px">{{ $t('加載中...') }}</p>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="page-content">
        <div class="ds-empty">
          <div style="font-size:48px;margin-bottom:12px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <div style="display:flex;gap:8px;justify-content:center">
            <button @click="retry" class="ds-btn ds-btn-primary">{{ $t('重試') }}</button>
            <button @click="openExternal" class="ds-btn ds-btn-outline">在浏览器中打开</button>
          </div>
        </div>
      </div>

      <!-- iframe -->
      <iframe
        v-show="url && !loading && !error"
        :src="url"
        class="webview-iframe"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox"
        referrerpolicy="no-referrer"
        @load="onLoad"
        @error="onError"
      ></iframe>
    </div>
  `,

  data() {
    const url = this.$route?.query?.url || '';
    return {
      url: decodeURIComponent(url),
      title: this.$route?.query?.title || this.$t('網頁'),
      loading: true,
      error: ''
    };
  },

  methods: {
    goBack() {
      if (window.history.length > 1) {
        this.$router.back();
      } else {
        this.$router.push('/home');
      }
    },

    onLoad() {
      this.loading = false;
    },

    onError() {
      this.loading = false;
      this.error = '网页加载失败，请检查链接是否有效';
    },

    retry() {
      this.loading = true;
      this.error = '';
      // Force iframe reload by toggling URL
      const u = this.url;
      this.url = '';
      this.$nextTick(() => { this.url = u; });
    },

    openExternal() {
      window.open(this.url, '_blank');
    }
  },

  mounted() {
    if (this.url) {
      // Set a safety timeout — if iframe doesn't fire onLoad after 15s, show content anyway
      this._safetyTimer = setTimeout(() => {
        if (this.loading) {
          this.loading = false;
        }
      }, 15000);
    }
  },

  beforeUnmount() {
    if (this._safetyTimer) clearTimeout(this._safetyTimer);
  }
};
