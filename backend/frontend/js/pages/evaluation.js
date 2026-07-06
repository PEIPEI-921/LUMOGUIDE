/* ============================================
   EvaluationSubmitPage — 提交评价（星级 + 文字 + 图片）
   对齐 Flutter EvaluationPage 功能
   路由: /evaluation?type=news|content&id=xxx&title=xxx
   ============================================ */

const EvaluationSubmitPage = {
  template: `
    <div class="page-content">
      <div class="ds-container-600" style="padding-top:16px">

        <!-- Rating -->
        <div class="eval-section">
          <label class="eval-label">{{ $t('評分') }}</label>
          <div class="eval-stars-row">
            <div class="eval-stars">
              <button v-for="s in 5" :key="s" class="eval-star"
                :class="{ active: s <= rating }"
                @click="rating = s">★</button>
            </div>
            <span class="eval-rating-text">{{ ratingText }}</span>
          </div>
        </div>

        <!-- Content -->
        <div class="eval-section">
          <label class="eval-label">{{ $t('評論內容') }}</label>
          <textarea v-model="content" class="ds-textarea" rows="5"
            :placeholder="tPlaceholder" maxlength="500"></textarea>
          <span class="eval-char-count">{{ content.length }}/500</span>
        </div>

        <!-- Images -->
        <div class="eval-section">
          <label class="eval-label">{{ $t('上傳圖片') }} <span class="eval-hint">({{ $t('可選，最多9張') }})</span></label>
          <div class="eval-images">
            <div v-for="(img, idx) in images" :key="'img-'+idx" class="eval-image-item">
              <img :src="img.preview" class="eval-image-thumb" />
              <button class="eval-image-remove" @click="removeImage(idx)">✕</button>
            </div>
            <button v-if="images.length < 9" class="eval-image-add" @click="addImage">
              <span>+</span>
              <span style="font-size:11px">{{ $t('添加') }}</span>
            </button>
          </div>
        </div>

        <!-- Submit -->
        <div class="bottom-actions" style="padding-top:16px">
          <button class="ds-btn ds-btn-primary" :disabled="submitting || !content.trim()"
            @click="doSubmit" style="width:100%;justify-content:center">
            {{ submitting ? $t('提交中...') : $t('提交評價') }}
          </button>
        </div>

      </div>
    </div>
  `,

  data() {
    return {
      rating: 5,
      content: '',
      images: [],       // { file: File, preview: blob URL }
      submitting: false,
      evalType: '',     // 'news' or 'content'
      evalId: 0
    };
  },

  computed: {
    ratingText() {
      const map = { 1: this.$t('很差'), 2: this.$t('較差'), 3: this.$t('一般'),
                    4: this.$t('較好'), 5: this.$t('極好') };
      return map[this.rating] || '';
    },
    tPlaceholder() {
      return this.$t('說點什麼吧～');
    }
  },

  methods: {
    tPlaceholder: '', // overridden in computed

    addImage() {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = 'image/*';
      input.multiple = false;
      input.onchange = (e) => {
        const file = e.target.files[0];
        if (!file) return;
        const preview = URL.createObjectURL(file);
        this.images.push({ file, preview });
      };
      input.click();
    },

    removeImage(idx) {
      const img = this.images[idx];
      if (img && img.preview) URL.revokeObjectURL(img.preview);
      this.images.splice(idx, 1);
    },

    async doSubmit() {
      if (!this.content.trim()) {
        showToast(this.$t('請輸入評論內容'));
        return;
      }

      this.submitting = true;

      try {
        // Upload images first
        let uploadedUrls = [];
        for (const img of this.images) {
          const formData = new FormData();
          formData.append('file', img.file);
          const res = await ApiProvider.upload(ApiUrl.fileUpload, formData);
          if (res.success && res.data) {
            // The API may return the URL directly or in a data.url field
            uploadedUrls.push(typeof res.data === 'string' ? res.data : (res.data.url || res.data.path || ''));
          }
        }

        // Submit evaluation
        const apiUrl = this.evalType === 'news'
          ? ApiUrl.addInformationEvaluate
          : ApiUrl.addContentEvaluate;

        const payload = {
          content_id: this.evalId,
          content: this.content,
          star: this.rating,
        };
        if (uploadedUrls.length > 0) {
          payload.pictures = uploadedUrls;
        }

        const res = await ApiProvider.post(apiUrl, payload);

        if (res.success) {
          showToast(this.$t('評論成功'));
          setTimeout(() => this.$router.back(), 800);
        } else {
          showToast(res.message || this.$t('評論失敗'));
        }
      } catch (e) {
        showToast(this.$t('評論失敗'));
      }

      this.submitting = false;
    }
  },

  mounted() {
    this.evalType = this.$route.query.type || 'news';
    this.evalId = parseInt(this.$route.query.id) || 0;
  },

  beforeUnmount() {
    // Clean up blob URLs
    this.images.forEach(img => {
      if (img.preview) URL.revokeObjectURL(img.preview);
    });
  }
};
