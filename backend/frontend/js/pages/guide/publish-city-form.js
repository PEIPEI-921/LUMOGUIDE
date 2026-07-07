/* ============================================
   Guide Publish City Form — 创建/编辑城市
   Reference: Flutter publish_city/page.dart + controller.dart
   Full city creation form: name, location cascade,
   capital toggle, demographics, overview, history,
   6-image grid uploader, draft save/restore
   ============================================ */

const DRAFT_KEY = 'publish_city_draft';

const GuidePublishCityFormPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🌍</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <!-- Not guide -->
      <div v-else-if="!isGuide" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔒</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('此功能僅限導遊使用') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Not VIP -->
      <div v-else-if="!UserStore.isVip" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">💎</div>
        <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ $t('發布城市功能需要VIP會員') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:20px">{{ $t('請先開通VIP會員後再使用城市發布功能') }}</p>
        <a href="#/vip" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto;text-decoration:none;display:inline-block;padding:10px 24px;border-radius:100px">{{ $t('開通VIP') }}</a>
      </div>

      <!-- Success -->
      <div v-else-if="success" style="text-align:center;padding:80px 16px">
        <div style="font-size:48px;margin-bottom:12px">✅</div>
        <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ isEdit ? $t('城市編輯成功') : $t('城市發布成功') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('請等待管理員審核') }}</p>
        <button @click="$router.push('/guide/publish-city')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回我的城市') }}</button>
      </div>

      <!-- Form -->
      <div v-else class="ds-container-600">
        <h2 class="ds-page-head" style="margin-bottom:20px">{{ isEdit ? $t('編輯城市') : $t('發布城市') }}</h2>

        <!-- Draft restore prompt -->
        <div v-if="showDraftPrompt" class="ds-card" style="padding:16px;margin-bottom:16px;background:var(--color-accent-soft);border:1px solid rgba(102,111,255,.15)">
          <p style="font-size:13px;color:var(--color-primary-text);margin-bottom:10px">{{ $t('檢測到上次未提交的填寫數據，是否使用？') }}</p>
          <div style="display:flex;gap:8px">
            <button @click="restoreDraft" class="ds-btn ds-btn-primary" style="padding:6px 16px;font-size:12px">{{ $t('使用') }}</button>
            <button @click="discardDraft" class="ds-btn ds-btn-outline" style="padding:6px 16px;font-size:12px">{{ $t('不使用') }}</button>
          </div>
        </div>

        <!-- Error -->
        <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ formError }}</div>

        <!-- Section 1: Basic Info -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('基本資訊') }}</h3>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('城市名稱（中文）') }} *</label>
            <input v-model="form.name" class="ds-input" style="margin-top:4px" :disabled="isEdit" :placeholder="$t('請輸入城市中文名')">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('城市名稱（英文）') }} *</label>
            <input v-model="form.name_en" class="ds-input" style="margin-top:4px" :disabled="isEdit" :placeholder="$t('請輸入城市英文名')">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('所在大洲') }} *</label>
            <select v-model="form.continents_id" @change="onContinentChange" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇所在大洲') }}</option>
              <option v-for="c in continents" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('所屬地區') }} *</label>
            <select v-model="form.area_id" @change="onAreaChange" class="ds-input" style="margin-top:4px" :disabled="!form.continents_id">
              <option value="">{{ $t('請選擇所屬地區') }}</option>
              <option v-for="c in subContinents" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('所屬國家') }} *</label>
            <select v-model="form.country_id" class="ds-input" style="margin-top:4px" :disabled="!form.area_id">
              <option value="">{{ $t('請選擇所屬國家') }}</option>
              <option v-for="c in countries" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('是否首都') }}</label>
            <div style="display:flex;gap:24px;margin-top:4px">
              <label style="display:flex;align-items:center;gap:6px;font-size:14px;cursor:pointer">
                <input type="radio" name="isCapital" :checked="form.is_capital===1" @change="form.is_capital=1" style="accent-color:var(--color-primary)">
                {{ $t('是') }}
              </label>
              <label style="display:flex;align-items:center;gap:6px;font-size:14px;cursor:pointer">
                <input type="radio" name="isCapital" :checked="form.is_capital===0" @change="form.is_capital=0" style="accent-color:var(--color-primary)">
                {{ $t('否') }}
              </label>
            </div>
          </div>
        </div>

        <!-- Section 2: Demographics -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('城市資訊') }}</h3>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('貨幣') }} *</label>
            <input v-model="form.currency" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入貨幣，如 EUR')">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('官方語言') }} *</label>
            <input v-model="form.language" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入官方語言')">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('人口數量') }} *</label>
            <input v-model="form.population" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入人口數量')">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('種族') }} *</label>
            <input v-model="form.race" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入種族')">
          </div>
        </div>

        <!-- Section 3: Overview & History -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('城市詳情') }}</h3>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('城市概覽') }} *</label>
            <textarea v-model="form.overview" class="ds-textarea" rows="8" style="margin-top:4px" :placeholder="$t('請輸入城市概覽')"></textarea>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('城市歷史') }} *</label>
            <textarea v-model="form.history" class="ds-textarea" rows="8" style="margin-top:4px" :placeholder="$t('請輸入城市歷史')"></textarea>
          </div>
        </div>

        <!-- Section 4: Cover Images -->
        <div class="ds-card" style="padding:16px;margin-bottom:12px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('城市封面') }}（{{ $t('最多6張') }}）</h3>
          <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px">
            <div v-for="(pic, idx) in pictures" :key="'pic-'+idx" style="position:relative;aspect-ratio:1;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
              <img :src="pic.preview || pic" alt="" style="width:100%;height:100%;object-fit:cover">
              <button @click="removePic(idx)" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
            </div>
            <button v-if="pictures.length < 6" @click="$refs.picInput.click()" style="aspect-ratio:1;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
          </div>
          <input ref="picInput" type="file" accept="image/*" style="display:none" @change="onPicAdd">
          <p style="font-size:11px;color:var(--color-assistant-text);margin-top:10px">{{ $t('上傳城市封面圖片，第一張將作為主要展示圖') }}</p>
        </div>

        <!-- Submit -->
        <div style="display:flex;gap:12px;margin-top:20px;padding-bottom:32px">
          <button @click="$router.back()" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:12px 0">{{ $t('取消') }}</button>
          <button @click="handleSubmit" :disabled="submitting" class="ds-btn ds-btn-primary" style="flex:2;justify-content:center;padding:12px 0">
            {{ submitting ? $t('提交中...') : isEdit ? $t('保存修改') : $t('確認發布城市') }}
          </button>
        </div>
      </div>
    </div>
  `,

  data() {
    return {
      isEdit: false, editId: null,
      form: {
        name: '', name_en: '', continents_id: '', continents_name: '',
        area_id: '', area_name: '', country_id: '', country_name: '',
        is_capital: 0, currency: '', language: '', population: '', race: '',
        overview: '', history: '',
      },
      pictures: [],           // [{preview, file}] or server URLs
      continents: [], subContinents: [], countries: [],
      loading: true, submitting: false, formError: '', success: false,
      showDraftPrompt: false,
    };
  },

  computed: {
    isGuide() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 2;
    },
  },

  mounted() {
    if (!UserStore.isLogin || !this.isGuide || !UserStore.isVip) { this.loading = false; return; }
    this.init();
  },

  beforeUnmount() {
    // Save draft for new mode
    if (!this.isEdit && !this.success) this.saveDraft();
    // Revoke blob URLs
    this.pictures.forEach(p => {
      if (p.preview && p.preview.startsWith('blob:')) URL.revokeObjectURL(p.preview);
    });
  },

  methods: {
    async init() {
      const id = this.$route.query.id;
      if (id) {
        this.isEdit = true;
        this.editId = parseInt(id, 10);
      }

      // Load continents
      await this.fetchContinents(0);

      if (this.isEdit) {
        await this.fetchCityInfo();
      } else {
        this.checkDraft();
      }

      this.loading = false;
    },

    // --- Cascade selectors ---

    async fetchContinents(parentId) {
      try {
        const res = await ApiProvider.get(ApiUrl.getContinentsList, { parent_id: parentId });
        const list = res.data?.list || res.data || [];
        if (parentId === 0) {
          this.continents = Array.isArray(list) ? list : [];
          this.subContinents = [];
          this.countries = [];
        } else if (!this.form.area_id || this.form.area_id === parentId) {
          // Loading sub-continents after continent selection
          this.subContinents = Array.isArray(list) ? list : [];
          this.countries = [];
        } else {
          // Loading countries after area selection
          this.countries = Array.isArray(list) ? list : [];
        }
      } catch (e) { /* silent */ }
    },

    onContinentChange() {
      this.form.area_id = '';
      this.form.area_name = '';
      this.form.country_id = '';
      this.form.country_name = '';
      const selected = this.continents.find(c => c.id == this.form.continents_id);
      this.form.continents_name = selected ? selected.name : '';
      if (this.form.continents_id) this.fetchContinents(this.form.continents_id);
    },

    onAreaChange() {
      this.form.country_id = '';
      this.form.country_name = '';
      const selected = this.subContinents.find(c => c.id == this.form.area_id);
      this.form.area_name = selected ? selected.name : '';
      if (this.form.area_id) this.fetchContinents(this.form.area_id);
    },

    // --- File upload ---

    onPicAdd(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      this.pictures.push({ file, preview: URL.createObjectURL(file) });
      e.target.value = '';
    },

    removePic(idx) {
      const pic = this.pictures[idx];
      if (pic.preview && pic.preview.startsWith('blob:')) URL.revokeObjectURL(pic.preview);
      this.pictures.splice(idx, 1);
    },

    async uploadFile(file, existingUrl) {
      if (!file) return existingUrl;
      try {
        const res = await ApiProvider.upload(ApiUrl.fileUpload, file);
        return res.success && res.data ? (res.data.url || res.data) : existingUrl;
      } catch (e) { return existingUrl; }
    },

    // --- Draft ---

    getDraftMap() {
      try {
        const s = localStorage.getItem(DRAFT_KEY);
        return s ? JSON.parse(s) : null;
      } catch (e) { return null; }
    },

    checkDraft() {
      const draft = this.getDraftMap();
      if (draft && (draft.name || (draft.pictures && draft.pictures.length > 0))) {
        this.showDraftPrompt = true;
      }
    },

    restoreDraft() {
      const draft = this.getDraftMap();
      if (!draft) { this.showDraftPrompt = false; return; }
      this.form.name = draft.name || '';
      this.form.name_en = draft.name_en || '';
      this.form.continents_id = draft.continents_id || '';
      this.form.continents_name = draft.continents_name || '';
      this.form.area_id = draft.area_id || '';
      this.form.area_name = draft.area_name || '';
      this.form.country_id = draft.country_id || '';
      this.form.country_name = draft.country_name || '';
      this.form.is_capital = draft.is_capital || 0;
      this.form.currency = draft.currency || '';
      this.form.language = draft.language || '';
      this.form.population = draft.population || '';
      this.form.race = draft.race || '';
      this.form.overview = draft.overview || '';
      this.form.history = draft.history || '';
      if (draft.pictures && Array.isArray(draft.pictures)) {
        this.pictures = draft.pictures.filter(p => typeof p === 'string');
      }
      // Reload cascade if needed
      if (this.form.continents_id) {
        this.fetchContinents(this.form.continents_id).then(() => {
          if (this.form.area_id) this.fetchContinents(this.form.area_id);
        });
      }
      this.showDraftPrompt = false;
    },

    discardDraft() {
      localStorage.removeItem(DRAFT_KEY);
      this.showDraftPrompt = false;
    },

    saveDraft() {
      const hasContent = this.form.name.trim() || this.form.name_en.trim() || this.pictures.length > 0;
      if (!hasContent) return;
      const draft = {
        ...this.form,
        pictures: this.pictures.map(p => typeof p === 'string' ? p : (p.preview || '')),
      };
      localStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
    },

    // --- Fetch city info for edit ---

    async fetchCityInfo() {
      try {
        const res = await ApiProvider.get(ApiUrl.guideCityInfo, { id: this.editId });
        if (!res.success || !res.data) return;
        const d = res.data;
        this.form.name = d.name || '';
        this.form.name_en = d.name_en || '';
        this.form.continents_id = d.continents_id || '';
        this.form.continents_name = d.continents_name || '';
        this.form.area_id = d.area_id || '';
        this.form.area_name = d.area_name || '';
        this.form.country_id = d.country_id || '';
        this.form.country_name = d.country_name || '';
        this.form.is_capital = Number(d.is_capital) || 0;
        this.form.currency = d.currency || '';
        this.form.language = d.language || '';
        this.form.population = d.population || '';
        this.form.race = d.race || '';
        this.form.overview = d.overview || '';
        this.form.history = d.history || '';
        if (Array.isArray(d.pictures)) {
          this.pictures = d.pictures.map(p => typeof p === 'string' ? p : p);
        }
        // Reload cascade
        if (this.form.continents_id) {
          await this.fetchContinents(this.form.continents_id);
          if (this.form.area_id) await this.fetchContinents(this.form.area_id);
        }
      } catch (e) { /* silent */ }
    },

    // --- Validation ---

    validate() {
      if (!this.form.name.trim()) return '請輸入城市中文名';
      if (!this.form.name_en.trim()) return '請輸入城市英文名';
      if (!this.form.continents_id) return '請選擇所在大洲';
      if (!this.form.area_id) return '請選擇所屬地區';
      if (!this.form.country_id) return '請選擇所屬國家';
      if (!this.form.currency.trim()) return '請輸入貨幣';
      if (!this.form.language.trim()) return '請輸入官方語言';
      if (!this.form.population.trim()) return '請輸入人口數量';
      if (!this.form.race.trim()) return '請輸入種族';
      if (!this.form.overview.trim()) return '請輸入城市概覽';
      if (!this.form.history.trim()) return '請輸入城市歷史';
      return null;
    },

    // --- Submit ---

    async handleSubmit() {
      const err = this.validate();
      if (err) { this.formError = err; return; }
      this.formError = '';
      this.submitting = true;

      try {
        // Upload new pictures
        const uploadedUrls = [];
        for (const pic of this.pictures) {
          if (pic.file) {
            const url = await this.uploadFile(pic.file, null);
            if (url) uploadedUrls.push(url);
          } else if (typeof pic === 'string') {
            uploadedUrls.push(pic);
          }
        }

        const payload = {
          ...this.form,
          pictures: uploadedUrls,
          id: this.isEdit ? this.editId : undefined,
        };

        const endpoint = this.isEdit ? ApiUrl.guideEditCity : ApiUrl.guidePublishCity;
        const result = await ApiProvider.post(endpoint, payload);

        if (result.success) {
          localStorage.removeItem(DRAFT_KEY);
          this.success = true;
        } else {
          this.formError = result.message || '提交失敗';
        }
      } catch (e) {
        this.formError = e.message || '提交失敗';
      }
      this.submitting = false;
    },
  }
};
