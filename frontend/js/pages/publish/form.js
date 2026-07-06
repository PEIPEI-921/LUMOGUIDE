/* ============================================
   Publish Form Pages — 发布景点/交通/设施/活动/资讯
   Reference: PPCC guide-panel publish forms
   Shared form component reused across 5 content types
   ============================================ */

// Content type config
const PUBLISH_TYPES = {
  attraction: {
    label: '景點', endpoints: {
      add: ApiUrl.guideAttractionAdd, info: ApiUrl.guideAttractionInfo,
      edit: ApiUrl.guideAttractionEdit, del: ApiUrl.guideAttractionDel,
    },
  },
  transportation: {
    label: '交通', endpoints: {
      add: ApiUrl.guideTransportationAdd, info: ApiUrl.guideTransportationInfo,
      edit: ApiUrl.guideTransportationEdit, del: ApiUrl.guideTransportationDel,
    },
  },
  facility: {
    label: '設施', endpoints: {
      add: ApiUrl.guideFacilityAdd, info: ApiUrl.guideFacilityInfo,
      edit: ApiUrl.guideFacilityEdit, del: ApiUrl.guideFacilityDel,
    },
  },
  activity: {
    label: '活動', endpoints: {
      add: ApiUrl.guideActivityAdd, info: ApiUrl.guideActivityInfo,
      edit: ApiUrl.guideActivityEdit, del: ApiUrl.guideActivityDel,
    },
  },
  information: {
    label: '資訊', endpoints: {
      add: ApiUrl.guideInformationAdd, info: ApiUrl.guideInformationInfo,
      edit: ApiUrl.guideInformationEdit, del: ApiUrl.guideInformationDel,
    },
  },
};

/*** Shared Publish Form Component (used internally) ***/
function createPublishPage(typeKey) {
  const typeConfig = PUBLISH_TYPES[typeKey];
  if (!typeConfig) {
    return { template: '<div class="page-content"><empty-state text="未知發布類型" /></div>' };
  }

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

        <!-- Success -->
        <div v-else-if="success" style="text-align:center;padding:80px 16px">
          <div style="font-size:48px;margin-bottom:12px">✅</div>
          <p style="color:var(--color-secondary-text);margin-bottom:4px">{{ isEdit ? '編輯成功' : '發布成功' }}</p>
          <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:24px">內容已提交，請等待審核</p>
          <button @click="$router.push('/guide/publish')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">{{ $t('返回發布管理') }}</button>
        </div>

        <!-- Form -->
        <div v-else class="ds-container-600">
          <h2 class="ds-page-head" style="margin-bottom:20px">{{ isEdit ? '編輯' + typeLabel : '發布' + typeLabel }}</h2>

          <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:12px;border-radius:8px;margin-bottom:16px">{{ formError }}</div>

          <div class="ds-card" style="padding:16px">
            <!-- Name/Title -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('名稱') }} *</label>
              <input v-model="form.name" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入名稱')">
            </div>

            <!-- Title (for information type) -->
            <div v-if="typeKey==='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('標題') }}</label>
              <input v-model="form.title" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入標題')">
            </div>

            <!-- Description -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('描述') }}</label>
              <textarea v-model="form.desc" class="ds-textarea" rows="4" style="margin-top:4px" :placeholder="$t('請輸入描述')"></textarea>
            </div>

            <!-- Address (for attraction/facility/activity) -->
            <div v-if="typeKey!=='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('地址') }}</label>
              <input v-model="form.address" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入地址')">
            </div>

            <!-- Start Time (for activity) -->
            <div v-if="typeKey==='activity'" class="ds-form-group">
              <label class="ds-label">{{ $t('開始時間') }}</label>
              <input v-model="form.start_time" class="ds-input" type="datetime-local" style="margin-top:4px">
            </div>

            <!-- Content/Body (for information) -->
            <div v-if="typeKey==='information'" class="ds-form-group">
              <label class="ds-label">{{ $t('內容') }}</label>
              <textarea v-model="form.content" class="ds-textarea" rows="8" style="margin-top:4px" :placeholder="$t('請輸入內容')"></textarea>
            </div>

            <!-- First Picture -->
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('主圖') }}</label>
              <div style="margin-top:4px">
                <div v-if="picturePreview" style="position:relative;width:160px;height:100px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                  <img :src="picturePreview" alt="" style="width:100%;height:100%;object-fit:cover">
                  <button @click="picturePreview='';pictureFile=null" style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:10px;border:none;cursor:pointer;line-height:22px">✕</button>
                </div>
                <button v-else @click="$refs.picInput.click()" style="width:160px;height:100px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:24px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
                <input ref="picInput" type="file" accept="image/*" style="display:none" @change="onPicChange">
              </div>
            </div>

            <!-- City selection (for first-time publish, not edit) -->
            <div v-if="!isEdit" class="ds-form-group">
              <label class="ds-label">{{ $t('所屬城市') }}</label>
              <select v-model="form.city_id" class="ds-input" style="margin-top:4px">
                <option value="">{{ $t('請選擇城市') }}</option>
                <option v-for="c in myCities" :key="c.city_id" :value="c.city_id">{{ c.city_name || c.name }}</option>
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
        form: { name: '', title: '', desc: '', address: '', start_time: '', content: '', city_id: '', first_picture: '' },
        pictureFile: null, picturePreview: '',
        myCities: [],
        loading: false, submitting: false, formError: '', success: false,
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
    methods: {
      async init() {
        // Load my cities for city selector
        try {
          const citiesRes = await ApiProvider.get(ApiUrl.guideCityList, { page: 1, limit: 100 });
          if (citiesRes.success && citiesRes.data?.list) {
            this.myCities = citiesRes.data.list;
          }
        } catch (e) { /* silent */ }

        // Check if editing
        const editId = this.$route.query.id;
        if (editId) {
          this.isEdit = true;
          this.editId = editId;
          this.loading = true;
          try {
            const result = await ApiProvider.get(typeConfig.endpoints.info, { id: editId });
            if (result.success && result.data) {
              const d = result.data;
              this.form.name = d.name || '';
              this.form.title = d.title || '';
              this.form.desc = d.desc || '';
              this.form.address = d.address || '';
              this.form.start_time = d.start_time ? d.start_time.slice(0, 16) : '';
              this.form.content = d.content || '';
              this.form.city_id = d.city_id || '';
              this.form.first_picture = d.first_picture || '';
              if (d.first_picture) this.picturePreview = d.first_picture;
            }
          } catch (e) { /* silent */ }
          this.loading = false;
        }
      },
      onPicChange(e) {
        const file = e.target.files?.[0];
        if (!file) return;
        this.pictureFile = file;
        this.picturePreview = URL.createObjectURL(file);
      },
      async uploadFile(file, existingUrl) {
        if (!file) return existingUrl;
        try {
          const res = await ApiProvider.upload(ApiUrl.fileUpload, file);
          return res.success && res.data ? res.data.url || res.data : existingUrl;
        } catch (e) { return existingUrl; }
      },
      async handleSubmit() {
        this.formError = '';
        if (!this.form.name.trim()) { this.formError = '請輸入名稱'; return; }
        this.submitting = true;
        try {
          const pictureUrl = await this.uploadFile(this.pictureFile, this.form.first_picture);
          const payload = {
            ...this.form,
            first_picture: pictureUrl,
            id: this.isEdit ? this.editId : undefined,
          };
          const endpoint = this.isEdit ? typeConfig.endpoints.edit : typeConfig.endpoints.add;
          const result = await ApiProvider.post(endpoint, payload);
          if (result.success) {
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
