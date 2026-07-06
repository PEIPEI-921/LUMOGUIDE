/* ============================================
   Booking Forms — 预约导游 / 预约商家
   ============================================ */

/*** BookingGuidePage ***/
const BookingGuidePage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">📅</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="success" style="text-align:center;padding:80px 16px">
        <div style="font-size:48px;margin-bottom:12px">✅</div>
        <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ $t('預約成功') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('請等待導遊確認') }}</p>
        <button @click="$router.push('/my-bookings')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('查看我的預約') }}</button>
      </div>

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <h2 class="ds-page-head" style="margin-bottom:20px">{{ $t('預約導遊') }}</h2>

        <!-- Guide info -->
        <div v-if="guide" class="ds-card" style="padding:16px;margin-bottom:16px;display:flex;align-items:center;gap:12px">
          <div style="width:48px;height:48px;border-radius:50%;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
            <img v-if="guide.photo" :src="guide.photo" alt="" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">👤</div>
          </div>
          <div>
            <p style="font-size:14px;font-weight:600;margin:0">{{ guide.name }}</p>
            <p v-if="guide.city_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ guide.city_name }}</p>
          </div>
        </div>

        <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ formError }}</div>

        <div class="ds-card" style="padding:16px">
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('預計到達時間') }} *</label>
            <input v-model="form.arrival_time" type="datetime-local" class="ds-input" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('人數') }} *</label>
            <input v-model="form.number" type="number" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入人數')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫人') }}</label>
            <input v-model="form.contact" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入聯繫人姓名')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫電話') }}</label>
            <input v-model="form.phone" type="tel" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入聯繫電話')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('郵箱') }}</label>
            <input v-model="form.email" type="email" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入郵箱')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('備註') }}</label>
            <textarea v-model="form.remark" class="ds-textarea" rows="3" style="margin-top:4px" :placeholder="$t('請輸入備註（選填）')"></textarea>
          </div>
        </div>

        <button @click="handleSubmit" :disabled="submitting" class="ds-btn ds-btn-primary"
          style="width:100%;justify-content:center;padding:14px 0;font-size:15px;border-radius:100px;margin-top:20px">
          {{ submitting ? $t('提交中...') : $t('提交預約') }}
        </button>
      </div>
    </div>
  `,
  data() {
    return {
      guide: null, loading: true, success: false,
      form: { arrival_time: '', number: '', contact: '', phone: '', email: '', remark: '' },
      submitting: false, formError: ''
    };
  },
  mounted() {
    if (!UserStore.isLogin) { this.loading = false; return; }
    this.loadGuide();
  },
  methods: {
    async loadGuide() {
      const id = this.$route.params.id;
      try {
        const result = await ApiProvider.get(ApiUrl.guideInfo, { id: Number(id) });
        if (result.success && result.data) {
          this.guide = result.data;
        }
      } catch (e) { /* silent */ }
      this.loading = false;
    },
    async handleSubmit() {
      this.formError = '';
      if (!this.form.arrival_time) { this.formError = '請選擇預計到達時間'; return; }
      if (!this.form.number) { this.formError = '請輸入人數'; return; }
      this.submitting = true;
      try {
        const payload = {
          id: Number(this.$route.params.id),
          guide_id: Number(this.$route.params.id),
          ...this.form
        };
        const result = await ApiProvider.post(ApiUrl.reserveGuide, payload);
        if (result.success) {
          this.success = true;
        } else {
          this.formError = result.message || '預約失敗';
        }
      } catch (e) {
        this.formError = e.message || '預約失敗';
      }
      this.submitting = false;
    }
  }
};

/*** BookingMerchantPage ***/
const BookingMerchantPage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🏪</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else-if="success" style="text-align:center;padding:80px 16px">
        <div style="font-size:48px;margin-bottom:12px">✅</div>
        <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ $t('預約成功') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('請等待商家確認') }}</p>
        <button @click="$router.push('/my-bookings')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('查看我的預約') }}</button>
      </div>

      <div v-else class="ds-container-600" style="padding-bottom:32px">
        <h2 class="ds-page-head" style="margin-bottom:20px">{{ $t('預約商家') }}</h2>

        <!-- Shop info -->
        <div v-if="shop" class="ds-card" style="padding:16px;margin-bottom:16px;display:flex;align-items:center;gap:12px">
          <div style="width:48px;height:48px;border-radius:8px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
            <img v-if="shop.first_picture" :src="shop.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">🏪</div>
          </div>
          <div>
            <p style="font-size:14px;font-weight:600;margin:0">{{ shop.name }}</p>
            <p v-if="shop.city_name" style="font-size:12px;color:var(--color-assistant-text);margin-top:2px">{{ shop.city_name }}</p>
          </div>
        </div>

        <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ formError }}</div>

        <div class="ds-card" style="padding:16px">
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('預計到達時間') }} *</label>
            <input v-model="form.arrival_time" type="datetime-local" class="ds-input" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('離開時間') }}</label>
            <input v-model="form.leave_time" type="datetime-local" class="ds-input" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('人數') }} *</label>
            <input v-model="form.number" type="number" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入人數')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫人') }}</label>
            <input v-model="form.contact" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入聯繫人姓名')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫電話') }}</label>
            <input v-model="form.phone" type="tel" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入聯繫電話')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('郵箱') }}</label>
            <input v-model="form.email" type="email" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入郵箱')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('備註') }}</label>
            <textarea v-model="form.remark" class="ds-textarea" rows="3" style="margin-top:4px" :placeholder="$t('請輸入備註（選填）')"></textarea>
          </div>
        </div>

        <button @click="handleSubmit" :disabled="submitting" class="ds-btn ds-btn-primary"
          style="width:100%;justify-content:center;padding:14px 0;font-size:15px;border-radius:100px;margin-top:20px">
          {{ submitting ? $t('提交中...') : $t('提交預約') }}
        </button>
      </div>
    </div>
  `,
  data() {
    return {
      shop: null, loading: true, success: false,
      form: { arrival_time: '', leave_time: '', number: '', contact: '', phone: '', email: '', remark: '' },
      submitting: false, formError: ''
    };
  },
  mounted() {
    if (!UserStore.isLogin) { this.loading = false; return; }
    this.loadShop();
  },
  methods: {
    async loadShop() {
      const id = this.$route.params.id;
      try {
        const result = await ApiProvider.get(ApiUrl.companyInfo, { id: Number(id) });
        if (result.success && result.data) {
          this.shop = result.data;
        }
      } catch (e) { /* silent */ }
      this.loading = false;
    },
    async handleSubmit() {
      this.formError = '';
      if (!this.form.arrival_time) { this.formError = '請選擇預計到達時間'; return; }
      if (!this.form.number) { this.formError = '請輸入人數'; return; }
      this.submitting = true;
      try {
        const payload = {
          id: Number(this.$route.params.id),
          content_id: Number(this.$route.params.id),
          ...this.form
        };
        const result = await ApiProvider.post(ApiUrl.addContentReserve, payload);
        if (result.success) {
          this.success = true;
        } else {
          this.formError = result.message || '預約失敗';
        }
      } catch (e) {
        this.formError = e.message || '預約失敗';
      }
      this.submitting = false;
    }
  }
};
