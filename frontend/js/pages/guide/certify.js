/* ============================================
   Guide Certify Page — 导游认证申请
   Reference: PPCC guide-panel/apply/page.tsx
   3-step wizard: 基本资料 → 专业资讯 → 证件上传
   ============================================ */

const STEPS = ['基本資料', '專業資訊', '證件上傳'];
const IDENTITY_OPTIONS = ['當地導遊', '中文導遊', '英文導遊', '司機兼導', '翻譯', '其他'];
const HAVE_OPTIONS = [{ label: '是', value: 1 }, { label: '否', value: 0 }];

const GuideCertifyPage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🎫</div>
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
        <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ $t('導遊認證資料提交成功') }}</p>
        <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">{{ $t('請等待管理員審核') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Form -->
      <div v-else class="ds-container-600">
        <!-- Header -->
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px">
          <h1 style="font-family:var(--font-serif);font-size:20px;font-weight:400;margin:0">LuMo Guide 認證</h1>
          <button v-if="readOnly" @click="readOnly=false" style="margin-left:auto;font-size:12px;color:var(--color-primary);background:none;border:none;cursor:pointer">✏️ {{ $t('編輯') }}</button>
        </div>

        <!-- Step indicators -->
        <div style="display:flex;gap:8px;margin-bottom:20px">
          <div v-for="(s, i) in STEPS" :key="s" style="flex:1;text-align:center">
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
            <label class="ds-label">{{ $t('照片') }} *</label>
            <div style="margin-top:4px">
              <div v-if="photoPreview" style="position:relative;width:100px;height:100px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                <img :src="photoPreview" alt="" style="width:100%;height:100%;object-fit:cover">
                <button v-if="!readOnly" @click="photoPreview='';photoFile=null" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
              </div>
              <button v-else @click="$refs.photoInput.click()" :disabled="readOnly" style="width:100px;height:100px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              <input ref="photoInput" type="file" accept="image/*" style="display:none" @change="onFileChange($event, 'photo')">
            </div>
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('真實姓名') }} *</label>
            <input v-model="form.name" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('英文姓名/拼音') }} *</label>
            <input v-model="form.name_en" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('聯繫電話') }} *</label>
            <input v-model="form.phone" class="ds-input" type="tel" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('郵箱地址') }} *</label>
            <input v-model="form.email" class="ds-input" type="email" :disabled="readOnly" style="margin-top:4px">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('賬單地址') }} *</label>
            <input v-model="form.bill_address" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
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
            <label class="ds-label">{{ $t('邀請碼') }}</label>
            <input v-model="form.invite_code" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>
        </div>

        <!-- Step 1: 专业资讯 -->
        <div v-if="step===1" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('專業資訊') }}</h3>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('語言') }} *</label>
            <div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:4px">
              <button v-for="l in languages" :key="l" @click="readOnly?null:toggleLang(l)"
                :style="{padding:'5px 14px',borderRadius:'20px',fontSize:'12px',border:'1px solid '+(selectedLangs.includes(l)?'var(--color-primary)':'var(--color-border)'),background:selectedLangs.includes(l)?'var(--color-accent-soft)':'transparent',color:selectedLangs.includes(l)?'var(--color-primary)':'var(--color-secondary-text)',cursor:readOnly?'default':'pointer'}">{{ l }}</button>
            </div>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('從業年份') }} *</label>
            <select v-model="form.year" :disabled="readOnly" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇') }}</option>
              <option v-for="y in yearOptions" :key="y" :value="String(y)">{{ y }}</option>
            </select>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('從業類型') }} *</label>
            <div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:4px">
              <button v-for="t in industryTypes" :key="t.name" @click="readOnly?null:toggleType(t.name)"
                :style="{padding:'5px 14px',borderRadius:'20px',fontSize:'12px',border:'1px solid '+(selectedTypes.includes(t.name)?'var(--color-primary)':'var(--color-border)'),background:selectedTypes.includes(t.name)?'var(--color-accent-soft)':'transparent',color:selectedTypes.includes(t.name)?'var(--color-primary)':'var(--color-secondary-text)',cursor:readOnly?'default':'pointer'}">{{ t.name }}</button>
            </div>
            <div v-if="selectedTypes.includes('Other')" style="margin-top:8px">
              <label class="ds-label">{{ $t('其他從業類型') }}</label>
              <input v-model="form.other_type" class="ds-input" :disabled="readOnly" style="margin-top:4px">
            </div>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('展示身份') }} *</label>
            <select v-model="form.identity_type" :disabled="readOnly" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇') }}</option>
              <option v-for="o in IDENTITY_OPTIONS" :key="o" :value="o">{{ o }}</option>
            </select>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('簡介') }} *</label>
            <textarea v-model="form.introduction" class="ds-textarea" rows="3" :disabled="readOnly" style="margin-top:4px"></textarea>
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('從業聯繫人') }} *</label>
            <input v-model="form.business_contact" class="ds-input" :disabled="readOnly" style="margin-top:4px">
          </div>

          <div class="ds-form-group">
            <label class="ds-label">{{ $t('是否有車輛') }}</label>
            <div style="display:flex;gap:12px;margin-top:4px">
              <label v-for="o in HAVE_OPTIONS" :key="o.value" style="display:flex;align-items:center;gap:4px;font-size:13px;cursor:readOnly?'default':'pointer'">
                <input type="radio" name="haveVehicle" :checked="form.have_vehicle===o.value" @change="!readOnly&&(form.have_vehicle=o.value)" style="accent-color:var(--color-primary)">
                {{ o.label }}
              </label>
            </div>
          </div>

          <template v-if="form.have_vehicle===1">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('車輛信息') }} *</label>
              <input v-model="form.vehicle_info" class="ds-input" :disabled="readOnly" style="margin-top:4px">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('車輛可否出租') }}</label>
              <div style="display:flex;gap:12px;margin-top:4px">
                <label v-for="o in HAVE_OPTIONS" :key="o.value" style="display:flex;align-items:center;gap:4px;font-size:13px;cursor:readOnly?'default':'pointer'">
                  <input type="radio" name="vehicleRent" :checked="form.vehicle_rent===o.value" @change="!readOnly&&(form.vehicle_rent=o.value)" style="accent-color:var(--color-primary)">
                  {{ o.label }}
                </label>
              </div>
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('車輛圖片') }}</label>
              <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:4px">
                <div v-for="(p, i) in carPics" :key="i" style="position:relative;width:80px;height:60px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                  <img :src="p.preview || p" alt="" style="width:100%;height:100%;object-fit:cover">
                  <button v-if="!readOnly" @click="carPics.splice(i,1)" style="position:absolute;top:2px;right:2px;width:18px;height:18px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer">✕</button>
                </div>
                <button v-if="!readOnly" @click="$refs.carPicInput.click()" style="width:80px;height:60px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:18px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              </div>
              <input ref="carPicInput" type="file" accept="image/*" style="display:none" @change="onCarPicAdd">
            </div>
          </template>
        </div>

        <!-- Step 2: 证件上传 -->
        <div v-if="step===2" class="ds-card" style="padding:16px">
          <h3 style="font-weight:600;margin-bottom:14px;font-size:15px">{{ $t('證件上傳') }}（{{ $t('選填') }}）</h3>
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
        </div>

        <!-- Bottom buttons -->
        <div style="display:flex;gap:12px;margin-top:20px;padding-bottom:32px">
          <button v-if="step>0" @click="step--;error=''" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:12px 0">{{ $t('上一步') }}</button>
          <button @click="nextStep" :disabled="submitting||readOnly" class="ds-btn ds-btn-primary" style="flex:2;justify-content:center;padding:12px 0">
            {{ submitting ? $t('提交中...') : step < 2 ? $t('下一步') : $t('提交認證') }}
          </button>
        </div>
      </div>
    </div>
  `,
  data() {
    const now = new Date();
    const years = [];
    for (let i = 0; i < 50; i++) years.push(now.getFullYear() - i);
    return {
      step: 0, loading: true, submitting: false, error: '', success: false, readOnly: false,
      languages: [], industryTypes: [],
      selectedLangs: [], selectedTypes: [],
      form: {
        name: '', name_en: '', phone: '', email: '', bill_address: '',
        wechat: '', whats_app: '', line: '', other_contact: '', invite_code: '',
        photo: '', year: '', identity_type: '', introduction: '', business_contact: '',
        have_vehicle: 0, vehicle_rent: 0, vehicle_info: '',
        certificate_picture: '', passport_picture: '', driver_license_front: '', driver_license_back: '',
        car_pictures: [],
      },
      photoFile: null, photoPreview: '',
      docFiles: { certificate: null, passport: null, licenseFront: null, licenseBack: null },
      carPics: [],
      docFields: [
        { key: 'certificate', label: '證件照片', ref: 'certInput' },
        { key: 'passport', label: '護照照片', ref: 'passportInput' },
        { key: 'licenseFront', label: '駕照正面', ref: 'licFrontInput' },
        { key: 'licenseBack', label: '駕照背面', ref: 'licBackInput' },
      ],
      yearOptions: years, STEPS, IDENTITY_OPTIONS, HAVE_OPTIONS
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
        // Load existing application
        const applyData = await ApiProvider.get(ApiUrl.applyGuideInfo);
        if (applyData.success && applyData.data && applyData.data.id) {
          const d = applyData.data;
          const status = Number(d.audit_status ?? 0);
          if (status === 0 || status === 1) this.readOnly = true;
          Object.keys(this.form).forEach(k => { if (d[k] !== undefined) this.form[k] = d[k]; });
          if (Array.isArray(d.language)) this.selectedLangs = [...d.language];
          if (Array.isArray(d.industry_type)) this.selectedTypes = [...d.industry_type];
          if (Array.isArray(d.car_pictures)) this.carPics = [...d.car_pictures];
          if (d.photo) this.photoPreview = d.photo;
        }
        // Load languages from config
        const configRes = await ApiProvider.get(ApiUrl.config);
        if (configRes.success && configRes.data && configRes.data.languages) {
          this.languages = configRes.data.languages.split(',').map(s => s.trim()).filter(Boolean);
        }
        // Load industry types
        const typeRes = await ApiProvider.get(ApiUrl.getType);
        if (typeRes.success && typeRes.data && Array.isArray(typeRes.data.list)) {
          this.industryTypes = typeRes.data.list;
        }
      } catch (e) { /* silent */ }
      this.loading = false;
    },
    toggleLang(l) {
      const i = this.selectedLangs.indexOf(l);
      if (i >= 0) this.selectedLangs.splice(i, 1); else this.selectedLangs.push(l);
    },
    toggleType(t) {
      const i = this.selectedTypes.indexOf(t);
      if (i >= 0) this.selectedTypes.splice(i, 1); else this.selectedTypes.push(t);
    },
    onFileChange(e, type) {
      const file = e.target.files?.[0];
      if (!file) return;
      if (type === 'photo') {
        this.photoFile = file;
        this.photoPreview = URL.createObjectURL(file);
      }
    },
    onCarPicAdd(e) {
      const file = e.target.files?.[0];
      if (file) this.carPics.push({ file, preview: URL.createObjectURL(file) });
    },
    onDocChange(e, key) {
      const file = e.target.files?.[0];
      if (!file) return;
      this.docFiles[key] = file;
    },
    docPreview(key) {
      const f = this.docFiles[key];
      if (f) return URL.createObjectURL(f);
      const map = { certificate: 'certificate_picture', passport: 'passport_picture', licenseFront: 'driver_license_front', licenseBack: 'driver_license_back' };
      return this.form[map[key]] || '';
    },
    clearDoc(key) {
      this.docFiles[key] = null;
      const map = { certificate: 'certificate_picture', passport: 'passport_picture', licenseFront: 'driver_license_front', licenseBack: 'driver_license_back' };
      this.form[map[key]] = '';
    },
    validateStep(s) {
      if (s === 0) {
        if (!this.photoPreview && !this.form.photo) return '請上傳照片';
        if (!this.form.name.trim()) return '請輸入真實姓名';
        if (!this.form.name_en.trim()) return '請輸入英文姓名';
        if (!this.form.phone.trim()) return '請輸入聯繫電話';
        if (!this.form.email.trim()) return '請輸入郵箱地址';
        if (!this.form.bill_address.trim()) return '請輸入賬單地址';
      }
      if (s === 1) {
        if (this.selectedLangs.length === 0) return '請選擇語言';
        if (!this.form.year) return '請選擇從業年份';
        if (this.selectedTypes.length === 0) return '請選擇從業類型';
        if (!this.form.identity_type) return '請選擇身份類型';
        if (!this.form.introduction.trim()) return '請輸入簡介';
        if (!this.form.business_contact.trim()) return '請輸入從業聯繫人';
        if (this.form.have_vehicle === 1 && !this.form.vehicle_info.trim()) return '請輸入車輛信息';
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
      if (this.step < 2) { this.step++; return; }
      // Submit
      this.submitting = true;
      try {
        const photoUrl = await this.uploadFile(this.photoFile, this.form.photo);
        const certUrl = await this.uploadFile(this.docFiles.certificate, this.form.certificate_picture);
        const passportUrl = await this.uploadFile(this.docFiles.passport, this.form.passport_picture);
        const licFrontUrl = await this.uploadFile(this.docFiles.licenseFront, this.form.driver_license_front);
        const licBackUrl = await this.uploadFile(this.docFiles.licenseBack, this.form.driver_license_back);
        // Upload car pics
        const carUrls = [];
        for (const pic of this.carPics) {
          if (pic.file) {
            // New upload — upload File then collect server URL
            const url = await this.uploadFile(pic.file, null);
            if (url) carUrls.push(url);
          } else if (typeof pic === 'string') {
            // Existing server URL
            carUrls.push(pic);
          } else if (pic.preview && !pic.file) {
            // Legacy blob-only entry — skip
          }
        }

        const result = await ApiProvider.post(ApiUrl.applyGuide, {
          ...this.form,
          photo: photoUrl,
          language: this.selectedLangs,
          industry_type: this.selectedTypes,
          certificate_picture: certUrl,
          passport_picture: passportUrl,
          driver_license_front: licFrontUrl,
          driver_license_back: licBackUrl,
          car_pictures: carUrls,
        });
        if (result.success) {
          this.success = true;
        } else {
          this.error = result.message || '提交失败';
        }
      } catch (e) {
        this.error = e.message || '提交失败';
      }
      this.submitting = false;
    }
  },

  beforeUnmount() {
    // Revoke blob URLs to prevent memory leaks
    if (this.photoPreview && this.photoPreview.startsWith('blob:')) URL.revokeObjectURL(this.photoPreview);
    this.carPics.forEach(p => { if (p.preview && p.preview.startsWith('blob:')) URL.revokeObjectURL(p.preview); });
    Object.values(this.docFiles).forEach(f => { if (f instanceof File) { /* File objects don't need revoking */ } });
  }
};
