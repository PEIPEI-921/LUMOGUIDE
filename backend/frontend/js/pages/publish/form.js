/* ============================================
   Publish Form Pages — publish attraction/transport/
   facility/activity/information content types
   Reference: Flutter publish_<type>/controller.dart
   Extended with: category selector, phone, email,
   website, open_time, tickets toggle+price, multiple
   images (up to 6), introduce textarea
   ============================================ */

// Content type config with field definitions
const PUBLISH_TYPES = {
  attraction: {
    label: '景點',
    categoryLabel: '景點類型',
    categorySource: 'scenic',  // from ConfigService or getTypeClass
    endpoints: {
      add: ApiUrl.guideAttractionAdd, info: ApiUrl.guideAttractionInfo,
      edit: ApiUrl.guideAttractionEdit, del: ApiUrl.guideAttractionDel,
    },
    has: {
      openTime: true, ticketsFree: true, price: true,
      phone: true, email: true, website: true,
      arrive: true, introduce: true,
    },
  },
  transportation: {
    label: '交通',
    categoryLabel: '交通類型',
    categorySource: 'traffic',
    endpoints: {
      add: ApiUrl.guideTransportationAdd, info: ApiUrl.guideTransportationInfo,
      edit: ApiUrl.guideTransportationEdit, del: ApiUrl.guideTransportationDel,
    },
    has: {
      phone: true, introduce: true,
    },
  },
  facility: {
    label: '設施',
    categoryLabel: '設施類型',
    categorySource: 'facility',
    endpoints: {
      add: ApiUrl.guideFacilityAdd, info: ApiUrl.guideFacilityInfo,
      edit: ApiUrl.guideFacilityEdit, del: ApiUrl.guideFacilityDel,
    },
    has: {
      phone: true, introduce: true,
    },
  },
  activity: {
    label: '活動',
    categoryLabel: '活動類型',
    categorySource: 'activity',
    endpoints: {
      add: ApiUrl.guideActivityAdd, info: ApiUrl.guideActivityInfo,
      edit: ApiUrl.guideActivityEdit, del: ApiUrl.guideActivityDel,
    },
    has: {
      startTime: true, phone: true, email: true,
      website: true, introduce: true,
    },
  },
  information: {
    label: '資訊',
    categoryLabel: '資訊分類',
    categorySource: 'information', // uses getInformationClass API
    endpoints: {
      add: ApiUrl.guideInformationAdd, info: ApiUrl.guideInformationInfo,
      edit: ApiUrl.guideInformationEdit, del: ApiUrl.guideInformationDel,
    },
    has: {
      title: true, content: true,
    },
  },
};

/*** Shared Publish Form Component (factory) ***/
function createPublishPage(typeKey) {
  const typeConfig = PUBLISH_TYPES[typeKey];
  if (!typeConfig) {
    return { template: '<div class="page-content"><div class="ds-container-600 ds-empty" style="padding-top:80px">{{ $t(\'未知發布類型\') }}</div></div>' };
  }
  const f = typeConfig.has;

  return {
    template: `
      <div class="page-content">
        <!-- Not logged in -->
        <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
          <div style="font-size:48px;margin-bottom:16px">📝</div>
          <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
          <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
        </div>

        <!-- Not guide -->
        <div v-else-if="!isGuide" style="text-align:center;padding-top:80px">
          <div style="font-size:48px;margin-bottom:16px">🔒</div>
          <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('此功能僅限導遊使用') }}</p>
          <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
        </div>

        <!-- Not VIP (new publish only, editing is always allowed) -->
        <div v-else-if="!isEdit && !UserStore.isVip" style="text-align:center;padding-top:80px">
          <div style="font-size:48px;margin-bottom:16px">💎</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ $t('發布功能需要VIP會員') }}</p>
          <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:20px">{{ $t('請先開通VIP會員後再使用發布功能') }}</p>
          <a href="#/vip" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto;text-decoration:none;display:inline-block;padding:10px 24px;border-radius:100px">{{ $t('開通VIP') }}</a>
        </div>

        <!-- Success -->
        <div v-else-if="success" style="text-align:center;padding:80px 16px">
          <div style="font-size:48px;margin-bottom:12px">✅</div>
          <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ isEdit ? $t('編輯成功') : $t('發布成功') }}</p>
          <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('內容已提交，請等待審核') }}</p>
          <button @click="$router.push('/guide/publish')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回發布管理') }}</button>
        </div>

        <!-- Form -->
        <div v-else class="ds-container-600">
          <h2 class="ds-page-head" style="margin-bottom:20px">{{ isEdit ? $t('編輯') + typeLabel : $t('發布') + typeLabel }}</h2>

          <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ formError }}</div>

          <!-- Draft restore prompt -->
          <div v-if="showDraftPrompt" class="ds-card" style="padding:16px;margin-bottom:16px;background:var(--color-accent-soft);border:1px solid rgba(102,111,255,.15)">
            <p style="font-size:13px;color:var(--color-primary-text);margin-bottom:10px">{{ $t('檢測到上次未提交的填寫數據，是否使用？') }}</p>
            <div style="display:flex;gap:8px">
              <button @click="restoreDraft" class="ds-btn ds-btn-primary" style="padding:6px 16px;font-size:12px">{{ $t('使用') }}</button>
              <button @click="discardDraft" class="ds-btn ds-btn-outline" style="padding:6px 16px;font-size:12px">{{ $t('不使用') }}</button>
            </div>
          </div>

          <div class="ds-card" style="padding:16px">
            <!-- Name -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('名稱') }} *</label>
              <input v-model="form.name" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入名稱')">
            </div>

            <!-- English Name -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('英文名稱') }}</label>
              <input v-model="form.name_en" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入英文名稱')">
            </div>

            <!-- Title (information only) -->
            <div v-if="${f.title ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('標題') }} *</label>
              <input v-model="form.title" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入標題')">
            </div>

            <!-- Category selector -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('${typeConfig.categoryLabel}') }}</label>
              <div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:4px">
                <button v-for="cat in categories" :key="cat.id"
                  @click="form.type_class_id=cat.id;form.type_class_name=cat.name"
                  :style="{padding:'5px 14px',borderRadius:'20px',fontSize:'12px',border:'1px solid '+(form.type_class_id===cat.id?'var(--color-primary)':'var(--color-border)'),background:form.type_class_id===cat.id?'var(--color-accent-soft)':'transparent',color:form.type_class_id===cat.id?'var(--color-primary)':'var(--color-secondary-text)',cursor:'pointer'}">{{ cat.name }}</button>
              </div>
            </div>

            <!-- Open Time (attraction) -->
            <div v-if="${f.openTime ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('開放時間') }} *</label>
              <input v-model="form.open_time" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入開放時間')">
            </div>

            <!-- Tickets Free/Paid toggle (attraction) -->
            <div v-if="${f.ticketsFree ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('門票') }}</label>
              <div style="display:flex;gap:24px;margin-top:4px">
                <label style="display:flex;align-items:center;gap:6px;font-size:14px;cursor:pointer">
                  <input type="radio" name="ticketsFree" :checked="form.tickets_free===1" @change="form.tickets_free=1;form.price=''" style="accent-color:var(--color-primary)">
                  {{ $t('免費') }}
                </label>
                <label style="display:flex;align-items:center;gap:6px;font-size:14px;cursor:pointer">
                  <input type="radio" name="ticketsFree" :checked="form.tickets_free===0" @change="form.tickets_free=0" style="accent-color:var(--color-primary)">
                  {{ $t('收費') }}
                </label>
              </div>
            </div>

            <!-- Price (attraction, when paid) -->
            <div v-if="${f.ticketsFree ? 'true' : 'false'} && form.tickets_free===0" class="ds-form-group">
              <label class="ds-label">{{ $t('票價') }} *</label>
              <input v-model="form.price" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入票價，可填寫單人、優惠票、團體票')">
            </div>

            <!-- Start Time (activity) -->
            <div v-if="${f.startTime ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('開始時間') }}</label>
              <input v-model="form.start_time" class="ds-input" type="datetime-local" style="margin-top:4px">
            </div>

            <!-- Phone -->
            <div v-if="${f.phone ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('電話') }}</label>
              <input v-model="form.phone" class="ds-input" type="tel" style="margin-top:4px" :placeholder="$t('請輸入電話')">
            </div>

            <!-- Email -->
            <div v-if="${f.email ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('郵箱') }}</label>
              <input v-model="form.email" class="ds-input" type="email" style="margin-top:4px" :placeholder="$t('請輸入郵箱')">
            </div>

            <!-- Website -->
            <div v-if="${f.website ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('官方網站') }}</label>
              <input v-model="form.website" class="ds-input" type="url" style="margin-top:4px" :placeholder="$t('請輸入網站')">
            </div>

            <!-- Address (non-information types) -->
            <div v-if="typeKey!=='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('地址') }} *</label>
              <input v-model="form.address" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入地址')">
            </div>

            <!-- How to Arrive (attraction) -->
            <div v-if="${f.arrive ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('如何到達') }}</label>
              <textarea v-model="form.how_arrive" class="ds-textarea" rows="3" style="margin-top:4px" :placeholder="$t('請輸入如何到達')"></textarea>
            </div>

            <!-- Introduce / Description -->
            <div v-if="${f.introduce ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('相關介紹') }}</label>
              <textarea v-model="form.introduce" class="ds-textarea" rows="6" style="margin-top:4px" :placeholder="$t('請輸入相關介紹')"></textarea>
            </div>

            <!-- Description (for types without introduce) -->
            <div v-if="typeKey!=='information' && !${f.introduce ? 'true' : 'false'}" class="ds-form-group">
              <label class="ds-label">{{ $t('描述') }}</label>
              <textarea v-model="form.desc" class="ds-textarea" rows="4" style="margin-top:4px" :placeholder="$t('請輸入描述')"></textarea>
            </div>

            <!-- Content (information) -->
            <div v-if="typeKey==='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('內容') }} *</label>
              <textarea v-model="form.content" class="ds-textarea" rows="10" style="margin-top:4px" :placeholder="$t('請輸入內容')"></textarea>
            </div>

            <!-- Pictures (up to 6) -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('圖片') }}（{{ $t('最多6張') }}）</label>
              <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-top:4px">
                <div v-for="(pic, idx) in pictures" :key="'pic-'+idx" style="position:relative;aspect-ratio:16/10;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                  <img :src="pic.preview || pic" alt="" style="width:100%;height:100%;object-fit:cover">
                  <button @click="removePic(idx)" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
                </div>
                <button v-if="pictures.length < 6" @click="$refs.picInput.click()" style="aspect-ratio:16/10;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              </div>
              <input ref="picInput" type="file" accept="image/*" style="display:none" @change="onPicAdd">
            </div>

            <!-- City selection (for first-time publish of non-information types) -->
            <div v-if="!isEdit && typeKey!=='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('所屬城市') }}</label>
              <select v-model="form.city_id" class="ds-input" style="margin-top:4px">
                <option value="">{{ $t('請選擇城市') }}</option>
                <option v-for="c in myCities" :key="c.city_id || c.id" :value="c.city_id || c.id">{{ c.city_name || c.name }}</option>
              </select>
            </div>
          </div>

          <!-- Submit -->
          <div style="display:flex;gap:12px;margin-top:20px;padding-bottom:32px">
            <button v-if="isEdit" @click="handleDelete" :disabled="submitting" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:12px 0;border-color:var(--color-red);color:var(--color-red)">{{ $t('刪除') }}</button>
            <button @click="handleSubmit" :disabled="submitting" class="ds-btn ds-btn-primary" style="flex:2;justify-content:center;padding:12px 0">
              {{ submitting ? $t('提交中...') : isEdit ? $t('保存修改') : $t('發布') }}
            </button>
          </div>
        </div>
      </div>
    `,
    data() {
      return {
        typeKey, typeLabel: typeConfig.label,
        isEdit: false, editId: null,
        form: {
          name: '', name_en: '', title: '', desc: '', address: '', start_time: '',
          content: '', city_id: '', type_class_id: '', type_class_name: '',
          open_time: '', tickets_free: 1, price: '',
          phone: '', email: '', website: '', how_arrive: '', introduce: '',
        },
        pictures: [],           // [{file, preview}] or server URL strings
        myCities: [], categories: [],
        loading: false, submitting: false, formError: '', success: false,
        showDraftPrompt: false, draftKey: 'publish_' + typeKey + '_draft',
      };
    },
    computed: {
      isGuide() {
        const profile = UserStore.profile || UserStore.userInfo;
        return profile && Number(profile.identity) === 2;
      },
    },
    mounted() {
      if (!UserStore.isLogin || !this.isGuide) return;
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
        // Load my cities
        try {
          const citiesRes = await ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 });
          if (citiesRes.success && citiesRes.data?.list) {
            this.myCities = citiesRes.data.list;
          }
        } catch (e) { /* silent */ }

        // Load categories
        if (typeKey === 'information') {
          try {
            const res = await ApiProvider.get(ApiUrl.getInformationClass);
            if (res.success && res.data?.list) this.categories = res.data.list;
          } catch (e) { /* silent */ }
        } else {
          // Use getTypeClass for non-information types
          try {
            const res = await ApiProvider.get(ApiUrl.getTypeClass, { type_id: 1 });
            if (res.success && res.data?.list) this.categories = res.data.list;
          } catch (e) { /* silent */ }
        }

        // Check if editing
        const editId = this.$route.query.id;
        if (editId) {
          this.isEdit = true;
          this.editId = parseInt(editId, 10);
          this.loading = true;
          try {
            const result = await ApiProvider.get(typeConfig.endpoints.info, { id: this.editId });
            if (result.success && result.data) {
              const d = result.data;
              this.form.name = d.name || '';
              this.form.name_en = d.name_en || '';
              this.form.title = d.title || '';
              this.form.desc = d.desc || '';
              this.form.address = d.address || '';
              this.form.start_time = d.start_time ? d.start_time.slice(0, 16) : '';
              this.form.content = d.content || '';
              this.form.city_id = d.city_id || '';
              this.form.type_class_id = d.type_class_id || '';
              this.form.type_class_name = d.type_class_name || '';
              this.form.open_time = d.open_time || d.start_time || '';
              this.form.tickets_free = d.tickets_free !== undefined ? Number(d.tickets_free) : 1;
              this.form.price = d.price || '';
              this.form.phone = d.phone || '';
              this.form.email = d.email || '';
              this.form.website = d.website || '';
              this.form.how_arrive = d.how_arrive || '';
              this.form.introduce = d.introduce || d.desc || '';
              if (Array.isArray(d.pictures)) {
                this.pictures = d.pictures.map(p => typeof p === 'string' ? p : p);
              } else if (d.first_picture) {
                this.pictures = [d.first_picture];
              }
              // Ensure tickets_free consistency
              if (this.form.tickets_free === 1) this.form.price = '';
            }
          } catch (e) { /* silent */ }
          this.loading = false;
        } else {
          // New mode — pre-fill city_id from route query (e.g., from city detail FAB)
          const cityIdFromRoute = this.$route.query.city_id;
          if (cityIdFromRoute && !this.isEdit) {
            this.form.city_id = parseInt(cityIdFromRoute, 10);
          }
          // Check for draft
          this.checkDraft();
        }
      },

      // --- Draft ---

      getDraftMap() {
        try {
          const s = localStorage.getItem(this.draftKey);
          return s ? JSON.parse(s) : null;
        } catch (e) { return null; }
      },

      checkDraft() {
        const draft = this.getDraftMap();
        if (draft && (draft.name || draft.name_en || draft.title || (draft.pictures && draft.pictures.length > 0))) {
          this.showDraftPrompt = true;
        }
      },

      restoreDraft() {
        const draft = this.getDraftMap();
        if (!draft) { this.showDraftPrompt = false; return; }
        this.form.name = draft.name || '';
        this.form.name_en = draft.name_en || '';
        this.form.title = draft.title || '';
        this.form.desc = draft.desc || '';
        this.form.address = draft.address || '';
        this.form.start_time = draft.start_time || '';
        this.form.content = draft.content || '';
        this.form.city_id = draft.city_id || '';
        this.form.type_class_id = draft.type_class_id || '';
        this.form.type_class_name = draft.type_class_name || '';
        this.form.open_time = draft.open_time || '';
        this.form.tickets_free = draft.tickets_free !== undefined ? draft.tickets_free : 1;
        this.form.price = draft.price || '';
        this.form.phone = draft.phone || '';
        this.form.email = draft.email || '';
        this.form.website = draft.website || '';
        this.form.how_arrive = draft.how_arrive || '';
        this.form.introduce = draft.introduce || '';
        if (draft.pictures && Array.isArray(draft.pictures)) {
          this.pictures = draft.pictures.filter(p => typeof p === 'string');
        }
        this.showDraftPrompt = false;
      },

      discardDraft() {
        localStorage.removeItem(this.draftKey);
        this.showDraftPrompt = false;
      },

      saveDraft() {
        const hasContent = this.form.name.trim() || this.form.title.trim() || this.pictures.length > 0;
        if (!hasContent) return;
        const draft = {
          ...this.form,
          pictures: this.pictures.map(p => typeof p === 'string' ? p : (p.preview || '')),
        };
        localStorage.setItem(this.draftKey, JSON.stringify(draft));
      },

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

      async handleSubmit() {
        this.formError = '';
        if (!this.form.name.trim() && typeKey !== 'information') { this.formError = '請輸入名稱'; return; }
        if (typeKey === 'information') {
          if (!this.form.title.trim()) { this.formError = '請輸入標題'; return; }
          if (!this.form.content.trim()) { this.formError = '請輸入內容'; return; }
        }
        this.submitting = true;
        try {
          // Upload new images
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
            first_picture: uploadedUrls.length > 0 ? uploadedUrls[0] : '',
            id: this.isEdit ? this.editId : undefined,
          };

          const endpoint = this.isEdit ? typeConfig.endpoints.edit : typeConfig.endpoints.add;
          const result = await ApiProvider.post(endpoint, payload);
          if (result.success) {
            localStorage.removeItem(this.draftKey);
            this.success = true;
          } else {
            this.formError = result.message || '提交失敗';
          }
        } catch (e) {
          this.formError = e.message || '提交失敗';
        }
        this.submitting = false;
      },

      async handleDelete() {
        if (!confirm('確定刪除？此操作不可撤銷。')) return;
        this.submitting = true;
        try {
          const result = await ApiProvider.post(typeConfig.endpoints.del, { id: this.editId });
          if (result.success) {
            this.$router.push('/guide/publish');
          } else {
            this.formError = result.message || '刪除失敗';
          }
        } catch (e) {
          this.formError = e.message || '刪除失敗';
        }
        this.submitting = false;
      },
    }
  };
}

// Export all 5 publish components
const PublishAttractionPage = createPublishPage('attraction');
const PublishTransportationPage = createPublishPage('transportation');
const PublishFacilityPage = createPublishPage('facility');
const PublishActivityPage = createPublishPage('activity');
const PublishInformationPage = createPublishPage('information');
