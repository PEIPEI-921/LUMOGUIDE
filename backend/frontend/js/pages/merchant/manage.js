/* ============================================
   Merchant Manage — 店铺管理
   Reference: PPCC company-panel/shops/page.tsx
   List + Add/Edit shop form
   ============================================ */

const TYPE_OPTIONS = [
  { id: 1, name: '景點' }, { id: 2, name: '餐廳' }, { id: 3, name: '購物' },
  { id: 4, name: '住宿' }, { id: 5, name: '交通' }, { id: 6, name: '設施' },
  { id: 7, name: '活動' }, { id: 8, name: '票務' },
];

const MerchantManagePage = {
  template: `
    <div class="page-content">
      <!-- Not logged in -->
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🏪</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('請先登入') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('去登入') }}</button>
      </div>

      <!-- Not company -->
      <div v-else-if="!isCompany" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">🔒</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('此功能僅限企業使用') }}</p>
        <button @click="$router.back()" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回') }}</button>
      </div>

      <!-- Content -->
      <div v-else class="ds-container-640" style="padding-bottom:32px">
        <!-- Header -->
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
          <h2 class="ds-page-head" style="margin:0">{{ $t('店鋪管理') }}</h2>
          <button @click="showForm=true;editId=null;resetForm()" v-if="!showForm" style="font-size:13px;color:var(--color-primary);font-weight:500;background:none;border:none;cursor:pointer">+ {{ $t('新增店鋪') }}</button>
        </div>

        <!-- Add/Edit Form -->
        <div v-if="showForm" class="ds-card" style="padding:16px;margin-bottom:16px">
          <h3 style="font-weight:600;font-size:15px;margin-bottom:14px">{{ editId ? $t('編輯店鋪') : $t('新增店鋪') }}</h3>
          <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:10px 12px;border-radius:8px;margin-bottom:12px">{{ formError }}</div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('店鋪名稱') }} *</label>
            <input v-model="form.name" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入店鋪名稱')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('類型') }}</label>
            <select v-model="form.type_id" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇類型') }}</option>
              <option v-for="t in TYPE_OPTIONS" :key="t.id" :value="t.id">{{ t.name }}</option>
            </select>
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('地址') }}</label>
            <input v-model="form.address" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入地址')">
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('描述') }}</label>
            <textarea v-model="form.desc" class="ds-textarea" rows="3" style="margin-top:4px" :placeholder="$t('請輸入描述')"></textarea>
          </div>
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('主圖') }}</label>
            <div style="margin-top:4px">
              <div v-if="picPreview" style="position:relative;width:120px;height:80px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                <img :src="picPreview" alt="" style="width:100%;height:100%;object-fit:cover">
                <button @click="picPreview='';picFile=null" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
              </div>
              <button v-else @click="$refs.picInput.click()" style="width:120px;height:80px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              <input ref="picInput" type="file" accept="image/*" style="display:none" @change="onPicChange">
            </div>
          </div>
          <div style="display:flex;gap:12px;margin-top:16px">
            <button @click="showForm=false" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:10px 0">{{ $t('取消') }}</button>
            <button @click="handleSave" :disabled="saving" class="ds-btn ds-btn-primary" style="flex:2;justify-content:center;padding:10px 0">
              {{ saving ? $t('保存中...') : $t('保存') }}
            </button>
          </div>
        </div>

        <!-- Loading -->
        <div v-if="loading" style="text-align:center;padding:80px 0">
          <div class="spinner"></div>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="ds-empty">
          <div style="font-size:36px;margin-bottom:8px">⚠️</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ error }}</p>
          <button @click="fetchShops" class="ds-btn ds-btn-primary">{{ $t('重新載入') }}</button>
        </div>

        <!-- Empty -->
        <div v-else-if="shops.length===0" class="ds-empty">
          <div style="font-size:40px;margin-bottom:12px">🏪</div>
          <p style="color:var(--color-secondary-text);margin-bottom:12px">{{ $t('暫無店鋪') }}</p>
          <button @click="showForm=true" class="ds-btn ds-btn-primary">{{ $t('新增店鋪') }}</button>
        </div>

        <!-- Shop list -->
        <div v-else>
          <div v-for="shop in shops" :key="shop.id" class="ds-card" style="margin-bottom:10px;overflow:hidden">
            <div style="padding:14px">
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
                <div style="display:flex;align-items:center;gap:6px">
                  <span v-if="shop.is_read===0" style="width:7px;height:7px;border-radius:50%;background:var(--color-red)"></span>
                  <span style="font-size:11px;color:var(--color-assistant-text)">{{ typeLabel(shop.type_id) }}</span>
                </div>
                <span :class="['ds-badge-sm', auditCls(shop.audit_status)]">{{ auditLabel(shop.audit_status) }}</span>
              </div>
              <div style="display:flex;gap:12px">
                <div style="width:80px;height:60px;border-radius:8px;overflow:hidden;background:var(--color-bg-page);flex-shrink:0">
                  <img v-if="shop.first_picture" :src="shop.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
                  <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:20px">📷</div>
                </div>
                <div style="flex:1;min-width:0">
                  <p style="font-size:14px;font-weight:600;margin:0">{{ shop.name }}</p>
                  <p v-if="shop.city_name" style="font-size:11px;color:var(--color-assistant-text);margin-top:2px">{{ shop.city_name }}</p>
                  <p v-if="shop.address" style="font-size:11px;color:var(--color-assistant-text);margin-top:1px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">📍 {{ shop.address }}</p>
                </div>
              </div>
              <p v-if="shop.audit_status===2 && shop.audit_feedback" style="font-size:11px;color:var(--color-red);background:#FEF2F2;padding:8px 10px;border-radius:8px;margin-top:8px;margin-bottom:0">{{ $t('駁回原因') }}: {{ shop.audit_feedback }}</p>
            </div>
            <div style="display:flex;border-top:1px solid var(--color-border)">
              <button @click="editShop(shop)" style="flex:1;padding:10px 0;font-size:12px;font-weight:500;border:none;background:transparent;color:var(--color-primary-text);cursor:pointer"
                @mouseenter="$event.currentTarget.style.background='var(--color-bg-page)'" @mouseleave="$event.currentTarget.style.background='transparent'">{{ $t('編輯') }}</button>
              <button @click="handleDelete(shop.id)" style="flex:1;padding:10px 0;font-size:12px;font-weight:500;border:none;border-left:1px solid var(--color-border);background:transparent;color:var(--color-red);cursor:pointer"
                @mouseenter="$event.currentTarget.style.background='#FEF2F2'" @mouseleave="$event.currentTarget.style.background='transparent'">{{ $t('刪除') }}</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  data() {
    return {
      shops: [], loading: true, error: null,
      showForm: false, editId: null, saving: false, formError: '',
      form: { name: '', type_id: '', address: '', desc: '', first_picture: '' },
      picFile: null, picPreview: '',
      TYPE_OPTIONS
    };
  },
  computed: {
    isCompany() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 3;
    }
  },
  mounted() {
    if (!UserStore.isLogin || !this.isCompany) { this.loading = false; return; }
    this.fetchShops();
  },
  methods: {
    async fetchShops() {
      this.loading = true; this.error = null;
      try {
        const result = await ApiProvider.get(ApiUrl.companyShop, { page: 1, limit: 50 });
        if (result.success) {
          this.shops = result.data?.list || result.data || [];
        } else {
          this.error = result.message || '載入失敗';
        }
      } catch (e) {
        this.error = e.message || '載入失敗';
      }
      this.loading = false;
    },
    typeLabel(typeId) {
      const t = TYPE_OPTIONS.find(o => o.id === Number(typeId));
      return t ? t.name : '商家';
    },
    auditCls(s) {
      return Number(s) === 1 ? 'ds-badge-success' : Number(s) === 2 ? 'ds-badge-danger' : 'ds-badge-warning';
    },
    auditLabel(s) {
      return Number(s) === 1 ? '已通過' : Number(s) === 2 ? '已駁回' : '審核中';
    },
    resetForm() {
      this.form = { name: '', type_id: '', address: '', desc: '', first_picture: '' };
      this.picFile = null; this.picPreview = ''; this.formError = '';
    },
    editShop(shop) {
      this.editId = shop.id;
      this.form.name = shop.name || '';
      this.form.type_id = shop.type_id || '';
      this.form.address = shop.address || '';
      this.form.desc = shop.desc || '';
      this.form.first_picture = shop.first_picture || '';
      this.picPreview = shop.first_picture || '';
      this.showForm = true;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },
    onPicChange(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      this.picFile = file;
      this.picPreview = URL.createObjectURL(file);
    },
    async uploadFile(file, existingUrl) {
      if (!file) return existingUrl;
      try {
        const res = await ApiProvider.upload(ApiUrl.fileUpload, file);
        return res.success && res.data ? res.data.url || res.data : existingUrl;
      } catch (e) { return existingUrl; }
    },
    async handleSave() {
      this.formError = '';
      if (!this.form.name.trim()) { this.formError = '請輸入店鋪名稱'; return; }
      this.saving = true;
      try {
        const pictureUrl = await this.uploadFile(this.picFile, this.form.first_picture);
        const payload = { ...this.form, first_picture: pictureUrl };
        if (this.editId) payload.id = this.editId;
        const endpoint = this.editId ? ApiUrl.companyShopEdit : ApiUrl.companyShopAdd;
        const result = await ApiProvider.post(endpoint, payload);
        if (result.success) {
          this.showForm = false;
          this.resetForm();
          this.fetchShops();
        } else {
          this.formError = result.message || '保存失敗';
        }
      } catch (e) {
        this.formError = e.message || '保存失敗';
      }
      this.saving = false;
    },
    async handleDelete(shopId) {
      if (!confirm('確定要刪除此店鋪嗎？')) return;
      try {
        const result = await ApiProvider.post(ApiUrl.companyShopDel, { id: shopId });
        if (result.success) this.fetchShops();
      } catch (e) { /* silent */ }
    },
  }
};
