/* ============================================
   Photo Viewer — 全屏图片查看器
   Route: /photo?url=xxx  or  /photo?urls=xxxx&index=0
   Replaces window.open(url, '_blank') for image preview
   ============================================ */

const PhotoViewerPage = {
  template: `
    <div class="photo-viewer" @click.self="close">
      <!-- Close button -->
      <button class="photo-close" @click="close" :title="t('關閉')">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>

      <!-- Image counter (multi-image mode) -->
      <div v-if="urls.length > 1" class="photo-counter">{{ currentIndex + 1 }} / {{ urls.length }}</div>

      <!-- Loading -->
      <div v-if="loading" class="photo-spinner">
        <div class="spinner" style="border-color:rgba(255,255,255,.15);border-top-color:#fff;width:40px;height:40px"></div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="photo-error" @click.stop>
        <div style="font-size:48px;margin-bottom:12px">🖼️</div>
        <p style="color:rgba(255,255,255,.7);margin-bottom:16px">{{ t('圖片加載失敗') }}</p>
        <button @click="retry" class="ds-btn ds-btn-primary">{{ t('重試') }}</button>
      </div>

      <!-- Image -->
      <img
        v-show="!loading && !error"
        :src="currentUrl"
        :alt="t('圖片') + ' ' + (currentIndex + 1)"
        class="photo-img"
        :class="{ loaded: imgLoaded }"
        @load="onImgLoad"
        @error="onImgError"
        @click.stop
      >

      <!-- Prev button -->
      <button v-if="urls.length > 1 && currentIndex > 0"
        class="photo-nav photo-prev" @click.stop="prev">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="15 18 9 12 15 6"></polyline>
        </svg>
      </button>

      <!-- Next button -->
      <button v-if="urls.length > 1 && currentIndex < urls.length - 1"
        class="photo-nav photo-next" @click.stop="next">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="9 18 15 12 9 6"></polyline>
        </svg>
      </button>

      <!-- Hint -->
      <div v-if="imgLoaded && urls.length <= 1" class="photo-hint">{{ t('點擊空白處關閉') }}</div>
    </div>
  `,

  data() {
    const raw = this.$route?.query?.urls;
    let urls = [];
    if (raw) {
      try { urls = JSON.parse(raw); } catch (e) { /* ignore */ }
    }
    const single = this.$route?.query?.url || '';
    if (!urls.length && single) urls = [single];

    const idx = parseInt(this.$route?.query?.index) || 0;

    return {
      urls,
      currentIndex: Math.min(idx, Math.max(0, urls.length - 1)),
      loading: true,
      imgLoaded: false,
      error: false
    };
  },

  computed: {
    currentUrl() {
      return this.urls[this.currentIndex] || '';
    }
  },

  methods: {
    close() {
      if (window.history.length > 1) {
        this.$router.back();
      } else {
        this.$router.push('/home');
      }
    },

    prev() {
      if (this.currentIndex > 0) {
        this.currentIndex--;
        this.resetState();
      }
    },

    next() {
      if (this.currentIndex < this.urls.length - 1) {
        this.currentIndex++;
        this.resetState();
      }
    },

    resetState() {
      this.loading = true;
      this.imgLoaded = false;
      this.error = false;
    },

    onImgLoad() {
      this.loading = false;
      this.imgLoaded = true;
    },

    onImgError() {
      this.loading = false;
      this.error = true;
    },

    retry() {
      this.resetState();
    },

    // Keyboard navigation
    onKeydown(e) {
      if (e.key === 'Escape') this.close();
      if (e.key === 'ArrowLeft') this.prev();
      if (e.key === 'ArrowRight') this.next();
    }
  },

  mounted() {
    document.addEventListener('keydown', this.onKeydown);
    // Prevent body scroll
    document.body.style.overflow = 'hidden';
  },

  beforeUnmount() {
    document.removeEventListener('keydown', this.onKeydown);
    document.body.style.overflow = '';
  }
};
