/* ============================================
   Address List & Edit Pages — 地址管理
   ============================================ */

const AddressListPage = {
  template: `
    <div class="page-content"><div class="ds-container-640" style="padding-top:16px;padding-bottom:16px">
      <div class="ds-page-head" style="padding-top:0;display:flex;align-items:center;justify-content:space-between">
        <h1>{{ $t('收貨地址') }}</h1>
        <a href="#/address/edit" class="ds-btn ds-btn-primary" style="padding:8px 18px;font-size:12px;width:auto;height:auto;border-radius:20px">{{ $t('新增地址') }}</a>
      </div>

      <div v-if="loading" class="loading-container"><div class="spinner"></div></div>
      <div v-else-if="addresses.length === 0" class="ds-empty">
        <div style="font-size:40px;margin-bottom:12px">📦</div>
        <p>{{ $t('暫無地址') }}</p>
      </div>
      <div v-else>
        <div v-for="addr in addresses" :key="addr.id" class="card" style="padding:16px;margin-bottom:10px;position:relative">
          <div v-if="addr.is_default" class="tag tag-primary" style="margin-bottom:8px">{{ $t('默認') }}</div>
          <div style="font-size:14px;font-weight:650">{{ addr.name }}</div>
          <div style="font-size:13px;color:var(--color-secondary-text);margin-top:4px">{{ addr.phone }}</div>
          <div style="font-size:13px;color:var(--color-secondary-text);margin-top:2px">{{ addr.province }}{{ addr.city }}{{ addr.district }} {{ addr.address }}</div>
          <div style="display:flex;gap:12px;margin-top:12px;justify-content:flex-end">
            <a :href="'#/address/edit?id=' + addr.id" style="font-size:12px;color:var(--color-primary);font-weight:500">{{ $t('編輯') }}</a>
            <button @click="deleteAddr(addr.id)" style="font-size:12px;color:var(--color-red);font-weight:500;background:none;border:none;cursor:pointer">{{ $t('刪除') }}</button>
          </div>
        </div>
      </div>
    </div>
    </div>
  `,
  data() { return { addresses: [], loading: true }; },
  async mounted() {
    const res = await ApiProvider.get(ApiUrl.addressLists);
    if (res.success) { const data = res.data?.list || res.data || []; this.addresses = Array.isArray(data) ? data : []; }
    this.loading = false;
  },
  methods: {
    async deleteAddr(id) {
      if (!confirm('確定刪除？')) return;
      const res = await ApiProvider.post(ApiUrl.addressDelete, { id });
      if (res.success) {
        this.addresses = this.addresses.filter(a => a.id !== id);
      }
    }
  }
};


const AddressEditPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ isEdit ? $t('編輯地址') : $t('新增地址') }}</h1>
      </div>

      <div class="ds-form-group">
        <label class="ds-label">{{ $t('收貨人') }}</label>
        <input v-model="form.name" class="ds-input" :placeholder="$t('請輸入收貨人姓名')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('手機號') }}</label>
        <input v-model="form.phone" class="ds-input" :placeholder="$t('請輸入手機號')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('省份') }}</label>
        <input v-model="form.province" class="ds-input" :placeholder="$t('省份')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('城市') }}</label>
        <input v-model="form.city" class="ds-input" :placeholder="$t('城市')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('區') }}</label>
        <input v-model="form.district" class="ds-input" :placeholder="$t('區')">
      </div>
      <div class="ds-form-group">
        <label class="ds-label">{{ $t('詳細地址') }}</label>
        <textarea v-model="form.address" class="ds-textarea" :placeholder="$t('請輸入詳細地址')" rows="3"></textarea>
      </div>
      <div class="ds-form-group" style="display:flex;align-items:center;gap:8px">
        <input type="checkbox" v-model="form.is_default" style="accent-color:var(--color-primary)">
        <label style="font-size:13px">{{ $t('設為默認地址') }}</label>
      </div>

      <button @click="save" :disabled="saving" class="ds-btn ds-btn-primary" style="width:100%">
        {{ saving ? $t('保存中...') : $t('保存') }}
      </button>
    </div>
    </div>
  `,
  data() {
    return {
      isEdit: false, addressId: 0,
      form: { name: '', phone: '', province: '', city: '', district: '', address: '', is_default: false },
      saving: false
    };
  },
  async mounted() {
    const id = this.$route.query.id;
    if (id) {
      this.isEdit = true;
      this.addressId = parseInt(id, 10);
      const res = await ApiProvider.get(ApiUrl.addressLists);
      if (res.success) {
        const list = res.data?.list || res.data || [];
        const addr = Array.isArray(list) ? list.find(a => a.id === this.addressId) : null;
        if (addr) {
          this.form.name = addr.name || '';
          this.form.phone = addr.phone || '';
          this.form.province = addr.province || '';
          this.form.city = addr.city || '';
          this.form.district = addr.district || '';
          this.form.address = addr.address || '';
          this.form.is_default = addr.is_default === 1;
        }
      }
    }
  },
  methods: {
    async save() {
      this.saving = true;
      const ep = this.isEdit ? ApiUrl.addressEdit : ApiUrl.addressAdd;
      const data = { ...this.form, is_default: this.form.is_default ? 1 : 0 };
      if (this.isEdit) data.id = this.addressId;
      const res = await ApiProvider.post(ep, data);
      if (res.success) {
        this.$router.back();
      } else {
        alert(res.message || '保存失敗');
      }
      this.saving = false;
    }
  }
};
