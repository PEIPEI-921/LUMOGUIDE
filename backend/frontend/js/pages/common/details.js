/* ============================================
   Guide Detail Page — 導遊詳情
   Reference: PPCC guides/[id]/page.tsx
   ============================================ */

const GuideDetailPage = {
  template: `
    <div class="page-content">
      <div v-if="loading" class="loading-container" style="padding:80px 0"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty" style="padding:80px 0">
        <p style="margin-bottom:16px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else class="ds-container-760" style="padding-top:0;padding-bottom:40px">
        <!-- Guide Profile Card -->
        <div class="ds-profile-card" style="margin-top:16px">
          <div class="ds-profile-top">
            <div class="ds-avatar">
              <img v-if="guide.photo" :src="guide.photo" :alt="guide.name">
              <span v-else>{{ (guide.name || '?')[0] }}</span>
            </div>
            <div class="ds-profile-info">
              <div class="ds-name-row">
                <span class="ds-name">{{ guide.name }}</span>
                <span v-if="guide.identity_type_name" class="ds-badge guide">{{ guide.identity_type_name }}</span>
              </div>
              <div class="ds-meta">
                <a v-if="guide.city_name && guide.city_id" :href="'#/city/detail?id=' + guide.city_id"
                  style="color:var(--color-primary);text-decoration:none;font-weight:500">📍 {{ guide.city_name }}</a>
                <span v-else-if="guide.city_name">📍 {{ guide.city_name }}</span>
                <span v-if="guide.have_vehicle">{{ guide.have_vehicle === 1 ? '🚗 有車' : '' }}</span>
              </div>
            </div>
          </div>

          <!-- Languages -->
          <div v-if="guide.language && guide.language.length" style="display:flex;gap:6px;margin-top:16px;flex-wrap:wrap">
            <span v-for="lang in guide.language" :key="lang"
              style="font-size:11px;padding:4px 12px;border-radius:20px;background:var(--color-accent-soft);color:var(--color-primary);font-weight:500">{{ lang }}</span>
          </div>
        </div>

        <!-- Introduction -->
        <div v-if="guide.introduction" class="card" style="padding:16px;margin-top:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('自我介紹') }}</h3>
          <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ guide.introduction }}</p>
        </div>

        <!-- Contact Info -->
        <div class="card" style="padding:16px;margin-top:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('聯繫方式') }}</h3>
          <div style="display:flex;flex-direction:column;gap:8px;font-size:14px">
            <div v-if="guide.phone">📱 {{ guide.phone }}</div>
            <div v-if="guide.email">📧 {{ guide.email }}</div>
            <div v-if="guide.wechat">💬 WeChat: {{ guide.wechat }}</div>
            <div v-if="guide.whats_app">💬 WhatsApp: {{ guide.whats_app }}</div>
            <div v-if="guide.line">💬 Line: {{ guide.line }}</div>
            <div v-if="guide.other_contact">📞 {{ guide.other_contact }}</div>
          </div>
        </div>

        <!-- Vehicle Rent -->
        <div v-if="guide.vehicle_rent === 1" class="card" style="padding:16px;margin-top:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('車輛服務') }}</h3>
          <p style="font-size:14px;color:var(--color-secondary-text)">{{ $t('此導遊提供車輛租賃服務') }}</p>
          <div v-if="carPictures.length > 0" style="display:flex;gap:8px;margin-top:10px;flex-wrap:wrap">
            <img v-for="(pic, i) in carPictures" :key="i" :src="pic"
              style="width:100px;height:100px;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer"
              @click="previewImage(pic)">
          </div>
        </div>

        <!-- Action Buttons -->
        <div style="display:flex;gap:12px;margin-top:20px">
          <button v-if="guide.can_follow" @click="toggleFollow"
            class="ds-btn" :class="guide.is_follow ? 'ds-btn-outline' : 'ds-btn-primary'"
            style="flex:1">
            {{ guide.is_follow ? $t('已關注') : $t('關注') }}
          </button>
          <button v-if="guide.is_reserve !== undefined" @click="$router.push('/booking-guide/' + guide.id)"
            class="ds-btn ds-btn-primary" style="flex:1">
            {{ $t('預約導遊') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return { guideId: 0, guide: {}, loading: true, error: null };
  },

  computed: {
    carPictures() {
      return Array.isArray(this.guide.car_pictures) ? this.guide.car_pictures : [];
    }
  },

  methods: {
    async load() {
      const id = this.$route.params.id;
      if (!id) { this.error = '缺少導遊 ID'; this.loading = false; return; }
      this.guideId = parseInt(id, 10);
      this.loading = true;
      this.error = null;

      const res = await ApiProvider.get(ApiUrl.guideInfo, { guide_id: this.guideId });
      if (res.success) {
        this.guide = res.data || {};
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },

    async toggleFollow() {
      const ep = this.guide.is_follow ? ApiUrl.unfollowGuide : ApiUrl.followGuide;
      const res = await ApiProvider.post(ep, { guide_id: this.guideId });
      if (res.success) {
        this.guide.is_follow = this.guide.is_follow ? 0 : 1;
      }
    },

    previewImage(url) { this.$router.push('/photo?url=' + encodeURIComponent(url)); }
  },

  mounted() { this.load(); },

  watch: { '$route.params.id': function() { this.load(); } }
};


/* ============================================
   Common Detail Page — 通用內容詳情
   For attraction/restaurant/shopping/accommodation/transportation/facility/activity/ticket
   ============================================ */

const CommonDetailPage = {
  template: `
    <div class="page-content">
      <div v-if="loading" class="loading-container" style="padding:80px 0"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty" style="padding:80px 0">
        <p style="margin-bottom:16px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else class="ds-container-760" style="padding-top:0;padding-bottom:40px">
        <!-- Banner -->
        <div v-if="banner" style="border-radius:var(--radius-lg);overflow:hidden;margin-top:16px;height:240px">
          <img :src="banner" style="width:100%;height:100%;object-fit:cover">
        </div>

        <!-- Title -->
        <div class="ds-page-head">
          <h1>{{ item.name }}</h1>
        </div>

        <!-- Info Card -->
        <div class="card" style="padding:16px;margin-bottom:14px">
          <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:12px;font-size:14px">
            <div v-if="item.city_name"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('城市') }}</span><p style="font-weight:500;margin-top:2px"><a :href="'#/city/detail?id=' + (item.city_id || $route.query.city_id)" style="color:var(--color-primary);text-decoration:none">📍 {{ item.city_name }}</a></p></div>
            <div v-if="item.address"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('地址') }}</span><p style="font-weight:500;margin-top:2px">{{ item.address }}</p></div>
            <div v-if="item.phone"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('電話') }}</span><p style="font-weight:500;margin-top:2px">{{ item.phone }}</p></div>
            <div v-if="item.email"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('郵箱') }}</span><p style="font-weight:500;margin-top:2px">{{ item.email }}</p></div>
            <div v-if="item.website"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('網站') }}</span><p style="font-weight:500;margin-top:2px">{{ item.website }}</p></div>
            <div v-if="item.price"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('價格') }}</span><p style="font-weight:600;margin-top:2px;color:var(--color-primary)">{{ item.price }}</p></div>
            <div v-if="item.start_time"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('營業時間') }}</span><p style="font-weight:500;margin-top:2px">{{ item.start_time }} - {{ item.end_time }}</p></div>
            <div v-if="item.tickets_free !== undefined"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('門票') }}</span><p style="font-weight:500;margin-top:2px">{{ item.tickets_free === 0 ? $t('免費') : $t('收費') }}</p></div>
            <div v-if="item.capacity"><span style="font-size:12px;color:var(--color-assistant-text)">{{ $t('容量') }}</span><p style="font-weight:500;margin-top:2px">{{ item.capacity }}</p></div>
          </div>
        </div>

        <!-- Introduction -->
        <div v-if="item.introduce" class="card" style="padding:16px;margin-bottom:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('介紹') }}</h3>
          <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ item.introduce }}</p>
        </div>

        <!-- How to arrive -->
        <div v-if="item.how_arrive" class="card" style="padding:16px;margin-bottom:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('如何抵達') }}</h3>
          <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ item.how_arrive }}</p>
        </div>

        <!-- Gallery -->
        <div v-if="gallery.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(120px,1fr));gap:8px;margin-top:14px">
          <img v-for="(pic, i) in gallery" :key="i" :src="pic"
            style="width:100%;aspect-ratio:1;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer"
            @click="previewImage(pic)">
        </div>

        <!-- Action Buttons -->
        <div v-if="item.is_reserve !== undefined || item.is_follow !== undefined" style="display:flex;gap:12px;margin-top:20px">
          <button v-if="item.can_follow" @click="toggleFollow"
            class="ds-btn" :class="item.is_follow ? 'ds-btn-outline' : 'ds-btn-primary'" style="flex:1">
            {{ item.is_follow ? $t('已關注') : $t('關注') }}
          </button>
          <button v-if="item.is_reserve !== undefined" @click="goReserve"
            class="ds-btn ds-btn-primary" style="flex:1">
            {{ $t('預約') }}
          </button>
        </div>
        <!-- Write Evaluation -->
        <div v-if="UserStore.isLogin" style="margin-top:12px">
          <button class="ds-btn ds-btn-sm ds-btn-outline" style="width:100%;justify-content:center"
            @click="$router.push('/evaluation/submit?type=content&id=' + itemId + '&title=' + encodeURIComponent(item.name || ''))">
            ✏️ {{ $t('寫評價') }}
          </button>
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return { type: '', itemId: 0, item: {}, loading: true, error: null };
  },

  computed: {
    banner() {
      const pics = Array.isArray(this.item.pictures) ? this.item.pictures : [];
      return pics.length > 0 ? pics[0] : (this.item.first_picture || '');
    },
    gallery() {
      const pics = Array.isArray(this.item.pictures) ? this.item.pictures : [];
      if (this.item.first_picture) return pics.filter(p => p !== this.item.first_picture);
      return pics;
    }
  },

  methods: {
    async load() {
      const id = this.$route.query.id;
      this.type = this.$route.params.type || '';
      if (!id) { this.error = '缺少內容 ID'; this.loading = false; return; }
      this.itemId = parseInt(id, 10);
      this.loading = true;
      this.error = null;

      const cityId = this.$route.query.city_id;
      const res = await ApiProvider.get(ApiUrl.cityContent, {
        id: this.itemId,
        type: this.type,
        city_id: cityId || ''
      });

      if (res.success) {
        this.item = res.data || {};
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },

    async toggleFollow() {
      const ep = this.item.is_follow ? ApiUrl.followShop : ApiUrl.followShop;
      const res = await ApiProvider.post(ep, { shop_id: this.itemId });
      if (res.success) this.item.is_follow = this.item.is_follow ? 0 : 1;
    },

    goReserve() {
      // Navigate to booking page
      this.$router.push('/booking-merchant/' + this.itemId);
    },

    previewImage(url) { this.$router.push('/photo?url=' + encodeURIComponent(url)); }
  },

  mounted() { this.load(); },

  watch: {
    '$route.query.id': function() { this.load(); }
  }
};


/* ============================================
   Company Detail Page — 商家詳情
   ============================================ */

const CompanyDetailPage = {
  template: `
    <div class="page-content">
      <div v-if="loading" class="loading-container" style="padding:80px 0"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty" style="padding:80px 0">
        <p style="margin-bottom:16px;color:var(--color-secondary-text)">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else class="ds-container-760" style="padding-top:0;padding-bottom:40px">
        <!-- Company Profile -->
        <div class="ds-profile-card" style="margin-top:16px">
          <div class="ds-profile-top">
            <div class="ds-avatar">
              <img v-if="company.avatar" :src="company.avatar" :alt="company.name">
              <span v-else>🏪</span>
            </div>
            <div class="ds-profile-info">
              <div class="ds-name-row">
                <span class="ds-name">{{ company.name }}</span>
                <span class="ds-badge company">{{ $t('商家') }}</span>
              </div>
              <div class="ds-meta">
                <a v-if="company.city_name && company.city_id" :href="'#/city/detail?id=' + company.city_id"
                  style="color:var(--color-primary);text-decoration:none;font-weight:500">📍 {{ company.city_name }}</a>
                <span v-else-if="company.city_name">📍 {{ company.city_name }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Introduction -->
        <div v-if="company.introduce" class="card" style="padding:16px;margin-top:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('商家介紹') }}</h3>
          <p style="font-size:14px;color:var(--color-secondary-text);white-space:pre-wrap;line-height:1.8">{{ company.introduce }}</p>
        </div>

        <!-- Contact -->
        <div class="card" style="padding:16px;margin-top:14px">
          <h3 style="font-weight:600;margin-bottom:8px">{{ $t('聯繫方式') }}</h3>
          <div style="display:flex;flex-direction:column;gap:8px;font-size:14px">
            <div v-if="company.phone">📱 {{ company.phone }}</div>
            <div v-if="company.email">📧 {{ company.email }}</div>
            <div v-if="company.address">📍 {{ company.address }}</div>
          </div>
        </div>

        <button v-if="company.is_follow !== undefined" @click="toggleFollow"
          class="ds-btn" :class="company.is_follow ? 'ds-btn-outline' : 'ds-btn-primary'"
          style="width:100%;margin-top:20px">
          {{ company.is_follow ? $t('已關注') : $t('關注商家') }}
        </button>
      </div>
    </div>
    </div>
  `,

  data() {
    return { companyId: 0, company: {}, loading: true, error: null };
  },

  methods: {
    async load() {
      const id = this.$route.params.id;
      if (!id) { this.error = '缺少商家 ID'; this.loading = false; return; }
      this.companyId = parseInt(id, 10);
      this.loading = true;
      this.error = null;

      const res = await ApiProvider.get(ApiUrl.companyInfo, { company_id: this.companyId });
      if (res.success) {
        this.company = res.data || {};
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },

    async toggleFollow() {
      const res = await ApiProvider.post(ApiUrl.followCompany, {
        company_id: this.companyId
      });
      if (res.success) this.company.is_follow = this.company.is_follow ? 0 : 1;
    }
  },

  mounted() { this.load(); },

  watch: { '$route.params.id': function() { this.load(); } }
};


/* ============================================
   Evaluation Pages — 評價詳情 / 評價列表
   ============================================ */

const EvaluationDetailPage = {
  template: `
    <div class="page-content"><div class="ds-container-760" style="padding-top:16px;padding-bottom:16px">
      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty">
        <p style="margin-bottom:12px">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else class="card" style="padding:20px">
        <!-- Evaluator -->
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:12px">
          <div style="width:44px;height:44px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0">
            <img v-if="evaluation.user?.avatar" :src="evaluation.user.avatar" style="width:100%;height:100%;object-fit:cover">
            <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">👤</div>
          </div>
          <div>
            <div style="font-size:14px;font-weight:650">{{ evaluation.user?.nickname || '用戶' }}</div>
            <div style="display:flex;gap:2px;margin-top:2px">
              <span v-for="s in 5" :key="s" style="color:var(--color-amber);font-size:14px">{{ s <= (evaluation.star || 0) ? '★' : '☆' }}</span>
            </div>
          </div>
          <span style="margin-left:auto;font-size:12px;color:var(--color-assistant-text)">{{ formatDate(evaluation.created_at) }}</span>
        </div>
        <p v-if="evaluation.content" style="font-size:14px;line-height:1.8">{{ evaluation.content }}</p>
        <div v-if="evalPics.length > 0" style="display:flex;gap:8px;margin-top:12px;flex-wrap:wrap">
          <img v-for="(pic, i) in evalPics" :key="i" :src="pic"
            style="width:100px;height:100px;object-fit:cover;border-radius:var(--radius-sm);cursor:pointer"
            @click="previewImage(pic)">
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return { evaluation: {}, loading: true, error: null };
  },

  computed: {
    evalPics() {
      return Array.isArray(this.evaluation.pictures) ? this.evaluation.pictures : [];
    }
  },

  methods: {
    async load() {
      const id = this.$route.params.id;
      if (!id) { this.error = '缺少評價 ID'; this.loading = false; return; }
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.contentEvaluate, { id });
      if (res.success) {
        this.evaluation = res.data || {};
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatDate(d) { return d ? (d + '').slice(0, 10) : ''; },
    previewImage(url) { this.$router.push('/photo?url=' + encodeURIComponent(url)); }
  },

  mounted() { this.load(); }
};


const EvaluationListPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:16px">
        <h1>{{ $t('評價列表') }}</h1>
      </div>

      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="error" class="ds-empty">
        <p style="margin-bottom:12px">{{ error }}</p>
        <button @click="load" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
      </div>
      <div v-else-if="evaluations.length === 0" class="ds-empty">{{ $t('暫無評價') }}</div>
      <div v-else>
        <div v-for="ev in evaluations" :key="ev.id"
          style="padding:16px 0;border-bottom:1px solid var(--color-border-light)">
          <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px">
            <div style="width:36px;height:36px;border-radius:50%;background:var(--color-accent-soft);overflow:hidden;flex-shrink:0">
              <img v-if="ev.user?.avatar" :src="ev.user.avatar" style="width:100%;height:100%;object-fit:cover">
              <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:16px">👤</div>
            </div>
            <div style="flex:1">
              <div style="font-size:13px;font-weight:650">{{ ev.user?.nickname || '用戶' }}</div>
              <div style="display:flex;gap:2px">
                <span v-for="s in 5" :key="s" style="color:var(--color-amber);font-size:12px">{{ s <= (ev.star||0) ? '★' : '☆' }}</span>
              </div>
            </div>
            <span style="font-size:11px;color:var(--color-assistant-text)">{{ formatDate(ev.created_at) }}</span>
          </div>
          <p v-if="ev.content" style="font-size:13px;color:var(--color-primary-text);line-height:1.6">{{ ev.content }}</p>
        </div>
      </div>
    </div>
    </div>
  `,

  data() {
    return { evaluations: [], loading: true, error: null };
  },

  methods: {
    async load() {
      const id = this.$route.params.id;
      if (!id) { this.error = '缺少內容 ID'; this.loading = false; return; }
      this.loading = true;
      this.error = null;
      const res = await ApiProvider.get(ApiUrl.contentEvaluate, {
        content_id: id, page: 1, limit: 50
      });
      if (res.success) {
        const list = res.data?.list || res.data || [];
        this.evaluations = Array.isArray(list) ? list : [];
      } else {
        this.error = res.message || '載入失敗';
      }
      this.loading = false;
    },
    formatDate(d) { return d ? (d + '').slice(0, 10) : ''; }
  },

  mounted() { this.load(); }
};
