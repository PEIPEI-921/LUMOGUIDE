/* ============================================
   Merchant Entry Page — 商家入驻申请
   Reference: PPCC company-panel/apply/page.tsx
   4-step wizard: 基本资料 → 营业类型 → 联系方式 → 照片上传
   ============================================ */

const MERCHANT_STEPS = ['基本資料', '營業類型', '聯繫方式', '照片上傳'];
const BIZ_TYPES = ['餐廳', '住宿', '購物', '交通', '景點', '設施', '活動', '票務', '其他'];

const MerchantEntryPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🏪</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <!-- Loading -->
      <div v-else-if="loading" style="text-align:center;padding:80px 0">
        <div class="spinner"></div>
      </div>

      <!-- Success -->
      <div v-else-if="success" style="text-align:center;padding:80px 16px">
        <div style="font-size:48px;margin-bottom:12px">✅</div>
        <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ $t('企業入駐資料提交成功') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('請等待管理員審核') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Form -->
      <div v-else class="ds-container-600">
        <!-- Header -->
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px">
          <h1 style="font-family:var(--font-serif);font-size:20px;font-weight:400;margin:0">{{ $t('企業會員入駐') }}</h1>
          <button v-if="readOnly" @click="readOnly=false" style="margin-left:auto;font-size:12px;color:var(--color-primary);background:none;border:none;cursor:pointer">✏️ {{ $t('編輯') }}</button>
        </div>

        <!-- Step indicators -->
        <div style="display:flex;gap:8px;margin-bottom:20px">
          <div v-for="(s, i) in MERCHANT_STEPS" :key="s" style="flex:1;text-align:center">
            <div :style="{height:'4px',borderRadius:'2px',background:i<=step?'var(--color-primary)':'var(--color-border)',marginBottom:'8px',transition:'background .3s'}"></div>
            <span :style="{fontSize:'11px',color:i<=step?'var(--color-primary)':'var(--color-assistant-text)',fontWeight:i===step?600:400}">{{ s }}</span>
          </div>
        </div>

        <!-- Error -->
        <div v-if="error" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ error }}</div>

        <!-- Step 0: 基本资料 -->
        <div v-if="step===0" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('基本資料') }}</h3>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('企業名稱') }} *</label>
            <input v-model="form.name" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('英文名稱') }}</label>
            <input v-model="form.name_en" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫人') }} *</label>
            <input v-model="form.contact_name" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('電話') }} *</label>
            <input v-model="form.phone" class="ds-input" type="tel" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('郵箱') }} *</label>
            <input v-model="form.email" class="ds-input" type="email" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('國家') }}</label>
            <input v-model="form.country" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('地址') }}</label>
            <input v-model="form.address" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('企業簡介') }}</label>
            <textarea v-model="form.introduction" class="ds-textarea" rows="3" :disabled="readOnly" style="margin-top:4px"></textarea>
          </div>
        </div>

        <!-- Step 1: 营业类型 -->
        <div v-if="step===1" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('營業類型') }} *</h3>
          <div style="display:flex;flex-wrap:wrap;gap:8px">
            <button v-for="t in BIZ_TYPES" :key="t" @click="readOnly?null:toggleType(t)"
              :style="{padding:'8px 18px',borderRadius:'20px',fontSize:'13px',border:'1px solid '+(selectedTypes.includes(t)?'var(--color-primary)':'var(--color-border)'),background:selectedTypes.includes(t)?'var(--color-accent-soft)':'transparent',color:selectedTypes.includes(t)?'var(--color-primary)':'var(--color-secondary-text)',cursor:readOnly?'default':'pointer'}">{{ t }}</button>
          </div>
        </div>

        <!-- Step 2: 联系方式 -->
        <div v-if="step===2" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('聯繫方式') }}</h3>
          <div class="ds-form-group">
            <label class="ds-label">微信</label>
            <input v-model="form.wechat" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">WhatsApp</label>
            <input v-model="form.whats_app" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">Line</label>
            <input v-model="form.line" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('其他聯繫方式') }}</label>
            <input v-model="form.other_contact" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫電話') }}</label>
            <input v-model="form.contact_phone" class="ds-input" type="tel" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫郵箱') }}</label>
            <input v-model="form.contact_email" class="ds-input" type="email" :disabled="readOnly" style="margin-top:4px">
          </div>
        </div>

        <!-- Step 3: 照片上传 -->
        <div v-if="step===3" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('照片上傳') }}</h3>

          <div v-for="doc in docFields" :key="doc.key" class="ds-form-group">
            <label class="ds-label">{{ doc.label }}</label>
            <div style="margin-top:4px">
              <div v-if="docPreview(doc.key)" style="position:relative;width:100px;height:100px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                <img :src="docPreview(doc.key)" alt="" style="width:100%;height:100%;object-fit:cover">
                <button v-if="!readOnly" @click="clearDoc(doc.key)" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
              </div>
              <button v-else @click="$refs[doc.ref][0].click()" :disabled="readOnly" style="width:100px;height:100px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              <input :ref="doc.ref" type="file" accept="image/*" style="display:none" @change="onDocChange($event, doc.key)">
            </div>
          </div>

          <!-- Store pictures -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('店鋪照片') }}</label>
            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:4px">
              <div v-for="(p, i) in storePics" :key="i" style="position:relative;width:80px;height:60px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                <img :src="p" alt="" style="width:100%;height:100%;object-fit:cover">
                <button v-if="!readOnly" @click="storePics.splice(i,1)" style="position:absolute;top:2px;right:2px;width:18px;height:18px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer">✕</button>
              </div>
              <button v-if="!readOnly" @click="$refs.storePicInput.click()" style="width:80px;height:60px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:18px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
            </div>
            <input ref="storePicInput" type="file" accept="image/*" style="display:none" @change="onStorePicAdd">
          </div>
        </div>

        <!-- Bottom buttons -->
        <div style="display:flex;gap:12px;margin-top:20px;padding-bottom:32px">
          <button v-if="step>0" @click="step--;error=''" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:12px 0">{{ $t('上一步') }}</button>
          <button @click="nextStep" :disabled="submitting||readOnly" class="ds-btn ds-btn-primary" style="flex:2;justify-content:center;padding:12px 0">
            {{ submitting ? $t('提交中...') : step < 3 ? $t('下一步') : $t('提交入駐') }}
          </button>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      step: 0, loading: true, submitting: false, error: '', success: false, readOnly: false,
      selectedTypes: [],
      form: {
        name: '', name_en: '', contact_name: '', phone: '', email: '',
        country: '', address: '', introduction: '',
        wechat: '', whats_app: '', line: '', other_contact: '',
        contact_phone: '', contact_email: '',
        photo: '', license: '', id_card_front: '', id_card_back: '',
        store_pictures: [],
      },
      docFiles: { photo: null, license: null, idCardFront: null, idCardBack: null },
      storePics: [],
      docFields: [
        { key: 'photo', label: '企業 Logo', ref: 'photoRef' },
        { key: 'license', label: '營業執照', ref: 'licenseRef' },
        { key: 'idCardFront', label: '身分證正面', ref: 'idFrontRef' },
        { key: 'idCardBack', label: '身分證背面', ref: 'idBackRef' },
      ],
      MERCHANT_STEPS, BIZ_TYPES
    };
  },
  mounted() {
    if (!UserStore.isLogin) { this.loading = false; return; }
    this.loadData();
  },
  methods: {
    async loadData() {
      this.loading = true;
      try {
        const result = await ApiProvider.get(ApiUrl.applyCompanyInfo);
        if (result.success && result.data && result.data.id) {
          const d = result.data;
          const status = Number(d.audit_status ?? 0);
          if (status === 0 || status === 1) this.readOnly = true;
          Object.keys(this.form).forEach(k => { if (d[k] !== undefined) this.form[k] = d[k]; });
          if (Array.isArray(d.type)) this.selectedTypes = [...d.type];
          if (Array.isArray(d.store_pictures)) this.storePics = [...d.store_pictures];
        }
      } catch (e) { /* silent */ }
      this.loading = false;
    },
    toggleType(t) {
      const i = this.selectedTypes.indexOf(t);
      if (i >= 0) this.selectedTypes.splice(i, 1); else this.selectedTypes.push(t);
    },
    onDocChange(e, key) {
      const file = e.target.files?.[0];
      if (file) this.docFiles[key] = file;
    },
    onStorePicAdd(e) {
      const file = e.target.files?.[0];
      if (file) this.storePics.push(URL.createObjectURL(file));
    },
    docPreview(key) {
      const f = this.docFiles[key];
      if (f) return URL.createObjectURL(f);
      const map = { photo: 'photo', license: 'license', idCardFront: 'id_card_front', idCardBack: 'id_card_back' };
      return this.form[map[key]] || '';
    },
    clearDoc(key) {
      this.docFiles[key] = null;
      const map = { photo: 'photo', license: 'license', idCardFront: 'id_card_front', idCardBack: 'id_card_back' };
      this.form[map[key]] = '';
    },
    validateStep(s) {
      if (s === 0) {
        if (!this.form.name.trim()) return '請輸入企業名稱';
        if (!this.form.phone.trim()) return '請輸入電話';
        if (!this.form.email.trim()) return '請輸入郵箱';
      }
      if (s === 1) {
        if (this.selectedTypes.length === 0) return '請選擇營業類型';
      }
      return null;
    },
    async uploadFile(file, existingUrl) {
      if (!file) return existingUrl;
      try {
        const res = await ApiProvider.upload(ApiUrl.fileUpload, file);
        return res.success && res.data ? res.data.url || res.data : existingUrl;
      } catch (e) { return existingUrl; }
    },
    async nextStep() {
      const err = this.validateStep(this.step);
      if (err) { this.error = err; return; }
      this.error = '';
      if (this.step < 3) { this.step++; return; }
      // Submit
      this.submitting = true;
      try {
        const photoUrl = await this.uploadFile(this.docFiles.photo, this.form.photo);
        const licenseUrl = await this.uploadFile(this.docFiles.license, this.form.license);
        const idFrontUrl = await this.uploadFile(this.docFiles.idCardFront, this.form.id_card_front);
        const idBackUrl = await this.uploadFile(this.docFiles.idCardBack, this.form.id_card_back);
        const storeUrls = this.storePics.filter(p => !p.startsWith('blob:'));

        const result = await ApiProvider.post(ApiUrl.applyCompany, {
          ...this.form,
          type: this.selectedTypes,
          photo: photoUrl,
          license: licenseUrl,
          id_card_front: idFrontUrl,
          id_card_back: idBackUrl,
          store_pictures: storeUrls,
        });
        if (result.success) {
          this.success = true;
        } else {
          this.error = result.message || '提交失敗';
        }
      } catch (e) {
        this.error = e.message || '提交失敗';
      }
      this.submitting = false;
    },
  }
};
