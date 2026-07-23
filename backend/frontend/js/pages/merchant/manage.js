/* ============================================
   Merchant Manage — 店铺管理
   Reference: Flutter merchant_management + merchant_editor
   Aligned: 2026-07-22
   ============================================ */

const TYPE_OPTIONS = [
  { id: 1, name: '景點' }, { id: 2, name: '餐廳' }, { id: 3, name: '購物' },
  { id: 4, name: '住宿' }, { id: 5, name: '交通' }, { id: 6, name: '設施' },
  { id: 7, name: '活動' }, { id: 8, name: '票務' },
];

const MERCHANT_DRAFT_KEY = 'merchant_editor_draft';

function emptyForm() {
  return {
    city_id: '', city_name: '',
    type_id: '', type_class_id: '', type_class_name: '',
    name: '', phone: '', email: '', website: '',
    address: '', introduce: '',
    start_time: '', capacity: '',
    order_food: '', tickets_free: '1', price: '',
    arrive: '', other_phone: '',
    pictures: [],
    first_picture: ''
  };
}

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
          <button v-if="!showForm" @click="onAddShop"
            style="padding:8px 18px;font-size:13px;font-weight:600;color:#fff;background:var(--color-primary);border:none;border-radius:100px;cursor:pointer;transition:background .2s"
            @mouseenter="$event.currentTarget.style.background='var(--color-primary-dark)'"
            @mouseleave="$event.currentTarget.style.background='var(--color-primary)'">
            + {{ $t('新增店鋪') }}
          </button>
        </div>

        <!-- Add/Edit Form -->
        <div v-if="showForm" class="ds-card" style="padding:16px;margin-bottom:16px">
          <h3 style="font-weight:600;font-size:15px;margin-bottom:14px">{{ editId ? $t('編輯店鋪') : $t('新增店鋪') }}</h3>
          <div v-if="formError" style="background:#FEF2F2;color:var(--color-red);font-size:12px;padding:10px 12px;border-radius:8px;margin-bottom:12px">{{ formError }}</div>

          <!-- City (required) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('城市') }} *</label>
            <select v-model="form.city_id" @change="onCityChange" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇所屬城市') }}</option>
              <option v-for="c in cities" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>

          <!-- Type (required) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('商家類型') }} *</label>
            <select v-model="form.type_id" @change="onTypeChange" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇商家類型') }}</option>
              <option v-for="t in TYPE_OPTIONS" :key="t.id" :value="t.id">{{ t.name }}</option>
            </select>
          </div>

          <!-- Category (required, depends on type) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('分類') }} *</label>
            <select v-model="form.type_class_id" class="ds-input" style="margin-top:4px">
              <option value="">{{ $t('請選擇分類') }}</option>
              <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
            </select>
          </div>

          <!-- Name (required) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('名稱') }} *</label>
            <input v-model="form.name" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入名稱')">
          </div>

          <!-- === Type-specific fields === -->

          <!-- Restaurant (type_id=2): startTime, capacity, orderFood -->
          <template v-if="showType === 'restaurant'">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('營業時間') }} *</label>
              <input v-model="form.start_time" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入營業時間')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('餐廳可容納人數') }}</label>
              <input v-model="form.capacity" class="ds-input" style="margin-top:4px" type="number" :placeholder="$t('請輸入餐廳可容納人數')">
            </div>
            <div class="ds-form-group" style="margin-top:12px">
              <label class="ds-label" style="margin-bottom:4px;display:block">{{ $t('是否接受團餐預訂') }}</label>
              <div style="display:flex;gap:20px">
                <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:14px">
                  <input type="radio" v-model="form.order_food" value="1" /> {{ $t('是') }}
                </label>
                <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:14px">
                  <input type="radio" v-model="form.order_food" value="0" /> {{ $t('否') }}
                </label>
              </div>
            </div>
          </template>

          <!-- Scenic (type_id=1): startTime, ticketsFree, price, phone, email, website, arrive -->
          <template v-if="showType === 'scenic'">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('開放時間') }} *</label>
              <input v-model="form.start_time" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入景點開放時間')">
            </div>
            <div class="ds-form-group" style="margin-top:12px">
              <label class="ds-label" style="margin-bottom:4px;display:block">{{ $t('門票') }}</label>
              <div style="display:flex;gap:20px">
                <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:14px">
                  <input type="radio" v-model="form.tickets_free" value="1" /> {{ $t('免費') }}
                </label>
                <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:14px">
                  <input type="radio" v-model="form.tickets_free" value="0" /> {{ $t('收費') }}
                </label>
              </div>
            </div>
            <div v-if="form.tickets_free === '0'" class="ds-form-group">
              <label class="ds-label">{{ $t('票價') }} *</label>
              <input v-model="form.price" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入票價，可填寫單人、優惠票、團體票的信息')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('電話') }} *</label>
              <input v-model="form.phone" class="ds-input" style="margin-top:4px" type="tel" :placeholder="$t('請輸入包含國際區號的電話號碼')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('郵箱') }}</label>
              <input v-model="form.email" class="ds-input" style="margin-top:4px" type="email" :placeholder="$t('請輸入郵箱')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('官方網站') }}</label>
              <input v-model="form.website" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入官方網站')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('如何到達') }}</label>
              <textarea v-model="form.arrive" class="ds-textarea" rows="3" style="margin-top:4px" :placeholder="$t('請輸入內容')"></textarea>
            </div>
          </template>

          <!-- Shopping (type_id=3): startTime -->
          <template v-if="showType === 'shopping'">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('營業時間') }} *</label>
              <input v-model="form.start_time" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入營業時間')">
            </div>
          </template>

          <!-- Ticket (type_id=8): phone, email, website, otherPhone, price -->
          <template v-if="showType === 'ticket'">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('電話') }} *</label>
              <input v-model="form.phone" class="ds-input" style="margin-top:4px" type="tel" :placeholder="$t('請輸入包含國際區號的電話號碼')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('郵箱') }}</label>
              <input v-model="form.email" class="ds-input" style="margin-top:4px" type="email" :placeholder="$t('請輸入郵箱')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('網址') }}</label>
              <input v-model="form.website" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入網址')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('其他聯係方式') }}</label>
              <input v-model="form.other_phone" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入其他聯係方式')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('價格') }} *</label>
              <textarea v-model="form.price" class="ds-textarea" rows="4" style="margin-top:4px" :placeholder="$t('請輸入價格')"></textarea>
            </div>
          </template>

          <!-- Common contact fields: 餐廳(2)/購物(3)/住宿(4)/交通(5)/設施(6)/活動(7) -->
          <template v-if="showCommonContact">
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('電話') }} *</label>
              <input v-model="form.phone" class="ds-input" style="margin-top:4px" type="tel" :placeholder="$t('請輸入包含國際區號的電話號碼')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('郵箱') }}</label>
              <input v-model="form.email" class="ds-input" style="margin-top:4px" type="email" :placeholder="$t('請輸入郵箱')">
            </div>
            <div class="ds-form-group">
              <label class="ds-label">{{ $t('網址') }}</label>
              <input v-model="form.website" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入網址')">
            </div>
          </template>

          <!-- Address (required) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('地址') }} *</label>
            <input v-model="form.address" class="ds-input" style="margin-top:4px" :placeholder="$t('請輸入地址')">
          </div>

          <!-- Introduce (required) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('商家介紹') }} *</label>
            <textarea v-model="form.introduce" class="ds-textarea" rows="6" style="margin-top:4px" :placeholder="$t('請輸入商家介紹')"></textarea>
          </div>

          <!-- Pictures (multi, up to 6) -->
          <div class="ds-form-group">
            <label class="ds-label">{{ $t('商家圖片') }} *</label>
            <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:6px">
              <div v-for="(pic,i) in form.pictures" :key="i"
                style="position:relative;width:90px;height:90px;border-radius:8px;overflow:hidden;background:var(--color-bg-page)">
                <img :src="pic" alt="" style="width:100%;height:100%;object-fit:cover">
                <button @click="removePic(i)"
                  style="position:absolute;top:4px;right:4px;width:22px;height:22px;border-radius:50%;background:rgba(0,0,0,.5);color:#fff;font-size:11px;border:none;cursor:pointer;line-height:22px">✕</button>
              </div>
              <button v-if="form.pictures.length < 6" @click="$refs.picInput.click()"
                style="width:90px;height:90px;border-radius:8px;border:2px dashed var(--color-border);display:flex;align-items:center;justify-content:center;font-size:28px;color:var(--color-assistant-text);cursor:pointer;background:transparent">+</button>
              <input ref="picInput" type="file" accept="image/*" style="display:none" @change="onPicAdd">
            </div>
            <div style="font-size:11px;color:var(--color-assistant-text);margin-top:6px">
              {{ $t('最多可上傳6張圖片') }}（{{ form.pictures.length }}/6）
            </div>
          </div>

          <div style="display:flex;gap:12px;margin-top:16px">
            <button @click="closeForm" class="ds-btn ds-btn-outline" style="flex:1;justify-content:center;padding:10px 0">{{ $t('取消') }}</button>
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
          <button v-if="UserStore.isVip" @click="onAddShop" class="ds-btn ds-btn-primary">{{ $t('新增店鋪') }}</button>
          <div v-else style="margin-top:8px">
            <p style="font-size:13px;color:var(--color-assistant-text);margin-bottom:12px">{{ $t('企業會員才能新增店鋪') }}</p>
            <button @click="$router.push('/vip')" class="ds-btn ds-btn-primary" style="background:linear-gradient(135deg,#F59E0B,#EF4444);border:none">{{ $t('去加入') }}</button>
          </div>
        </div>

        <!-- Shop list (Flutter-aligned card) -->
        <div v-else>
          <div v-for="shop in shops" :key="shop.id" style="margin-bottom:10px;background:var(--color-bg-elevated);border:1px solid var(--color-border);border-radius:var(--radius-md);overflow:hidden;box-shadow:var(--shadow-card)">
            <!-- Card body -->
            <div style="padding:10px">
              <!-- Row 1: publish time + status badge -->
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
                <div style="display:flex;align-items:center;gap:4px">
                  <span v-if="shop.is_read === 0" style="width:7px;height:7px;border-radius:50%;background:var(--color-red);flex-shrink:0"></span>
                  <span style="font-size:11px;color:var(--color-secondary-text)">{{ $t('發佈時間') }}: {{ formatDate(shop.created_at) }}</span>
                </div>
                <span :style="{fontSize:'10px',padding:'4px 8px',borderRadius:'4px',border:'1px solid',color:auditColor(shop.audit_status),borderColor:auditColor(shop.audit_status)}">
                  {{ auditLabel(shop.audit_status) }}
                </span>
              </div>

              <!-- Row 2: cover image (185px Flutter proportion) -->
              <div style="width:100%;height:180px;border-radius:6px;overflow:hidden;background:var(--color-bg-page);margin-bottom:10px">
                <img v-if="shop.first_picture" :src="shop.first_picture" alt="" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:36px">🏪</div>
              </div>

              <!-- Row 3: name + type badge -->
              <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
                <span style="font-size:14px;font-weight:700;color:var(--color-primary-text);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1;min-width:0">{{ shop.name }}</span>
                <span style="font-size:10px;color:#FF8A00;padding:3px 10px;border:1px solid #FF8A00;border-radius:30px;flex-shrink:0;margin-left:8px">{{ shop.type || typeLabel(shop.type_id) }}</span>
              </div>

              <!-- Row 4: phone -->
              <div v-if="shop.phone" style="display:flex;align-items:center;gap:4px;margin-bottom:4px;font-size:12px;color:var(--color-assistant-text)">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                <span>{{ $t('電話') }}: {{ shop.phone }}</span>
              </div>

              <!-- Row 5: address -->
              <div v-if="shop.address" style="display:flex;align-items:center;gap:4px;margin-bottom:4px;font-size:12px;color:var(--color-assistant-text)">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <span>{{ $t('地址') }}: {{ shop.address }}</span>
              </div>

              <!-- Rejection reason -->
              <p v-if="shop.audit_status === 2 && shop.audit_feedback"
                style="font-size:11px;color:#DD0000;margin-top:8px;margin-bottom:0">{{ $t('駁回原因') }}: {{ shop.audit_feedback }}</p>
            </div>

            <!-- Operate bar: Edit / Delete -->
            <div style="display:flex;border-top:1px solid var(--color-border);background:rgba(255,255,255,0.6)">
              <button @click="editShop(shop)"
                style="flex:1;padding:10px 0;font-size:14px;font-weight:500;border:none;background:transparent;color:var(--color-primary-text);cursor:pointer;display:flex;align-items:center;justify-content:center;gap:4px"
                @mouseenter="$event.currentTarget.style.background='var(--color-bg-page)'" @mouseleave="$event.currentTarget.style.background='transparent'">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                {{ $t('編輯') }}
              </button>
              <div style="width:1px;height:20px;background:var(--color-assistant-text);opacity:0.3;align-self:center"></div>
              <button @click="handleDelete(shop.id)"
                style="flex:1;padding:10px 0;font-size:14px;font-weight:500;border:none;background:transparent;color:var(--color-primary-text);cursor:pointer;display:flex;align-items:center;justify-content:center;gap:4px"
                @mouseenter="$event.currentTarget.style.background='var(--color-bg-page)'" @mouseleave="$event.currentTarget.style.background='transparent'">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                {{ $t('刪除') }}
              </button>
            </div>
          </div>
        </div>

        <!-- FAB -->
        <a v-if="!showForm && shops.length > 0" href="#" @click.prevent="onAddShop"
          style="position:fixed;bottom:24px;right:24px;z-index:100;display:flex;flex-direction:column;align-items:center;justify-content:center;width:56px;height:56px;border-radius:56px;background:var(--color-primary);color:#fff;text-decoration:none;box-shadow:0 4px 16px rgba(102,111,255,0.35);transition:transform .15s,box-shadow .15s"
          @mouseenter="$event.currentTarget.style.transform='scale(1.08)';$event.currentTarget.style.boxShadow='0 6px 24px rgba(102,111,255,0.45)'"
          @mouseleave="$event.currentTarget.style.transform='scale(1)';$event.currentTarget.style.boxShadow='0 4px 16px rgba(102,111,255,0.35)'">
          <span style="font-size:22px;line-height:1;font-weight:300">+</span>
          <span style="font-size:10px;line-height:1;margin-top:1px">{{ $t('發佈') }}</span>
        </a>
      </div>
    </div>
  `,

  data() {
    return {
      shops: [], loading: true, error: null,
      showForm: false, editId: null, saving: false, formError: '',
      form: emptyForm(),
      newPicFiles: [],  // File objects for new uploads
      cities: [], categories: [],
      TYPE_OPTIONS
    };
  },

  computed: {
    isCompany() {
      const profile = UserStore.profile || UserStore.userInfo;
      return profile && Number(profile.identity) === 3;
    },
    showType() {
      const t = Number(this.form.type_id);
      if (t === 1) return 'scenic';
      if (t === 2) return 'restaurant';
      if (t === 3) return 'shopping';
      if (t === 8) return 'ticket';
      return 'common';
    },
    // Common contact fields for: restaurant(2)/shopping(3)/hotel(4)/traffic(5)/facility(6)/activity(7)
    // NOT for scenic(1) and ticket(8) — they have their own
    showCommonContact() {
      const t = Number(this.form.type_id);
      return t === 2 || t === 3 || t === 4 || t === 5 || t === 6 || t === 7;
    }
  },

  mounted() {
    if (!UserStore.isLogin || !this.isCompany) { this.loading = false; return; }
    this.fetchCities();
    this.fetchShops();
  },

  methods: {
    // ---- VIP gate ----
    onAddShop() {
      if (!UserStore.isVip) {
        showToast(I18n.t('企業會員才能新增店鋪'));
        this.$router.push('/vip');
        return;
      }
      // Free VIP: only 1 shop
      if (UserStore.isFreeVip && this.shops.length >= 1) {
        showToast(I18n.t('免費試用期間只能添加一個店鋪'));
        this.$router.push('/vip');
        return;
      }
      this.editId = null;
      this.resetForm();
      this.showForm = true;
      this.checkDraft();
    },

    // ---- City ----
    async fetchCities() {
      try {
        const res = await ApiProvider.get(ApiUrl.cityList, { page: 1, limit: 1000 });
        if (res.success) {
          this.cities = res.data?.list || res.data || [];
        }
      } catch (e) { /* silent */ }
    },
    onCityChange() {
      const c = this.cities.find(c => c.id === Number(this.form.city_id));
      this.form.city_name = c ? c.name : '';
    },

    // ---- Type / Category ----
    async onTypeChange() {
      this.form.type_class_id = '';
      this.form.type_class_name = '';
      this.categories = [];
      if (!this.form.type_id) return;
      try {
        const res = await ApiProvider.get(ApiUrl.getTypeClass, { type_id: this.form.type_id });
        if (res.success) {
          this.categories = Array.isArray(res.data) ? res.data : (res.data?.list || []);
        }
      } catch (e) { /* silent */ }
    },
    onCategoryChange() {
      const c = this.categories.find(c => c.id === Number(this.form.type_class_id));
      this.form.type_class_name = c ? (c.name || '') : '';
    },

    // ---- Pictures ----
    onPicAdd(e) {
      const file = e.target.files?.[0];
      if (!file) return;
      const blobUrl = URL.createObjectURL(file);
      this.form.pictures.push(blobUrl);
      this.newPicFiles.push(file);
      e.target.value = '';
    },
    removePic(i) {
      this.form.pictures.splice(i, 1);
      // If it's an existing URL (not a new file), mark it for removal from the array only
      if (i < this.newPicFiles.length) this.newPicFiles.splice(i, 1);
    },

    // ---- Form ----
    resetForm() {
      this.form = emptyForm();
      this.newPicFiles = [];
      this.categories = [];
      this.formError = '';
    },
    closeForm() {
      if (!this.editId) this.saveDraft();
      this.showForm = false;
    },
    editShop(shop) {
      this.editId = shop.id;
      this.form.city_id = shop.city_id || '';
      this.form.city_name = shop.city_name || '';
      this.form.type_id = shop.type_id || '';
      this.form.type_class_id = shop.type_class_id || '';
      this.form.type_class_name = shop.type_class_name || '';
      this.form.name = shop.name || '';
      this.form.phone = shop.phone || '';
      this.form.email = shop.email || '';
      this.form.website = shop.website || '';
      this.form.address = shop.address || '';
      this.form.introduce = shop.introduce || '';
      this.form.start_time = shop.start_time || '';
      this.form.capacity = shop.capacity || '';
      this.form.order_food = shop.order_food != null ? String(shop.order_food) : '';
      this.form.tickets_free = shop.tickets_free != null ? String(shop.tickets_free) : '1';
      this.form.price = shop.price || '';
      this.form.arrive = shop.how_arrive || '';
      this.form.other_phone = shop.other_phone || '';
      this.form.pictures = Array.isArray(shop.pictures) ? [...shop.pictures] : (shop.first_picture ? [shop.first_picture] : []);
      this.form.first_picture = shop.first_picture || '';
      this.newPicFiles = [];
      this.showForm = true;
      // Load categories for this type
      this.onTypeChange();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },

    // ---- Draft ----
    saveDraft() {
      if (this.editId) return;
      const f = this.form;
      if (!f.name && !f.address && !f.pictures.length) return;
      try {
        localStorage.setItem(MERCHANT_DRAFT_KEY, JSON.stringify({
          ...f, pictures: f.pictures, ts: Date.now()
        }));
      } catch (e) { /* silent */ }
    },
    checkDraft() {
      try {
        const raw = localStorage.getItem(MERCHANT_DRAFT_KEY);
        if (!raw) return;
        const draft = JSON.parse(raw);
        if (!draft.name && !draft.pictures?.length) return;
        if (confirm(I18n.t('檢測到上次未提交的填寫數據，是否使用？'))) {
          this.form.city_id = draft.city_id || '';
          this.form.city_name = draft.city_name || '';
          this.form.type_id = draft.type_id || '';
          this.form.type_class_id = draft.type_class_id || '';
          this.form.name = draft.name || '';
          this.form.phone = draft.phone || '';
          this.form.email = draft.email || '';
          this.form.website = draft.website || '';
          this.form.address = draft.address || '';
          this.form.introduce = draft.introduce || '';
          this.form.start_time = draft.start_time || '';
          this.form.capacity = draft.capacity || '';
          this.form.order_food = draft.order_food || '';
          this.form.tickets_free = draft.tickets_free || '1';
          this.form.price = draft.price || '';
          this.form.arrive = draft.arrive || '';
          this.form.other_phone = draft.other_phone || '';
          this.form.pictures = draft.pictures || [];
          if (this.form.type_id) this.onTypeChange();
        } else {
          localStorage.removeItem(MERCHANT_DRAFT_KEY);
        }
      } catch (e) { /* silent */ }
    },
    clearDraft() {
      localStorage.removeItem(MERCHANT_DRAFT_KEY);
    },

    // ---- Save ----
    async uploadFile(file) {
      if (!file) return '';
      try {
        const res = await ApiProvider.upload(ApiUrl.fileUpload, file);
        return res.success && res.data ? (res.data.url || res.data) : '';
      } catch (e) { return ''; }
    },
    async handleSave() {
      this.formError = '';
      if (!this.form.city_id) { this.formError = I18n.t('請選擇所屬城市'); return; }
      if (!this.form.type_class_id) { this.formError = I18n.t('請選擇分類'); return; }
      if (!this.form.name.trim()) { this.formError = I18n.t('請輸入名稱'); return; }

      // Validate type-specific required fields
      const t = this.showType;
      if ((t === 'restaurant' || t === 'shopping') && !this.form.start_time.trim()) {
        this.formError = t === 'restaurant' ? I18n.t('請輸入營業時間') : I18n.t('請輸入營業時間');
        return;
      }
      if (t === 'scenic') {
        if (!this.form.start_time.trim()) { this.formError = I18n.t('請輸入景點開放時間'); return; }
      }
      if (t === 'scenic' && this.form.tickets_free === '0' && !this.form.price.trim()) {
        this.formError = I18n.t('請輸入票價'); return;
      }
      if ((this.showCommonContact || t === 'scenic' || t === 'ticket') && !this.form.phone.trim()) {
        this.formError = I18n.t('請輸入電話'); return;
      }
      if (t === 'ticket' && !this.form.price.trim()) {
        this.formError = I18n.t('請輸入價格'); return;
      }
      if (!this.form.address.trim()) { this.formError = I18n.t('請輸入地址'); return; }
      if (!this.form.pictures.length) { this.formError = I18n.t('請上傳最少一張圖片'); return; }

      this.saving = true;
      try {
        // Upload new picture files
        const uploadedUrls = [];
        for (let i = 0; i < this.form.pictures.length; i++) {
          const pic = this.form.pictures[i];
          if (pic.startsWith('blob:') && this.newPicFiles[i]) {
            const url = await this.uploadFile(this.newPicFiles[i]);
            if (!url) { this.formError = I18n.t('圖片上傳失敗'); this.saving = false; return; }
            uploadedUrls.push(url);
          } else {
            uploadedUrls.push(pic); // existing URL
          }
        }

        const payload = {
          city_id: Number(this.form.city_id),
          type_id: Number(this.form.type_id),
          type_class_id: Number(this.form.type_class_id),
          name: this.form.name.trim(),
          phone: this.form.phone.trim(),
          email: this.form.email.trim(),
          website: this.form.website.trim(),
          address: this.form.address.trim(),
          introduce: this.form.introduce.trim(),
          start_time: this.form.start_time.trim(),
          capacity: this.form.capacity.trim(),
          order_food: this.form.order_food !== '' ? Number(this.form.order_food) : undefined,
          tickets_free: Number(this.form.tickets_free),
          price: this.form.price.trim(),
          how_arrive: this.form.arrive.trim(),
          other_phone: this.form.other_phone.trim(),
          pictures: uploadedUrls,
          first_picture: uploadedUrls[0] || this.form.first_picture
        };

        if (this.editId) payload.id = this.editId;
        const endpoint = this.editId ? ApiUrl.companyShopEdit : ApiUrl.companyShopAdd;
        const result = await ApiProvider.post(endpoint, payload);
        if (result.success) {
          this.clearDraft();
          this.showForm = false;
          this.resetForm();
          this.fetchShops();
        } else {
          this.formError = result.message || I18n.t('保存失敗');
        }
      } catch (e) {
        this.formError = e.message || I18n.t('保存失敗');
      }
      this.saving = false;
    },

    // ---- Fetch ----
    async fetchShops() {
      this.loading = true; this.error = null;
      try {
        const result = await ApiProvider.get(ApiUrl.companyShop, { page: 1, limit: 50 });
        if (result.success) {
          this.shops = result.data?.list || result.data || [];
        } else {
          this.error = result.message || I18n.t('加載失敗');
        }
      } catch (e) {
        this.error = e.message || I18n.t('加載失敗');
      }
      this.loading = false;
    },

    // ---- Delete ----
    async handleDelete(shopId) {
      if (!confirm(I18n.t('確定要刪除該店鋪麼？'))) return;
      try {
        const result = await ApiProvider.post(ApiUrl.companyShopDel, { id: shopId });
        if (result.success) {
          showToast(I18n.t('已刪除'));
          this.fetchShops();
        }
      } catch (e) { /* silent */ }
    },

    // ---- Helpers ----
    typeLabel(typeId) {
      const t = TYPE_OPTIONS.find(o => o.id === Number(typeId));
      return t ? t.name : '商家';
    },
    auditColor(s) {
      if (Number(s) === 0) return 'var(--color-primary)';
      if (Number(s) === 1) return '#00BEAA';
      if (Number(s) === 2) return '#DD0000';
      return 'var(--color-assistant-text)';
    },
    auditLabel(s) {
      if (Number(s) === 0) return I18n.t('審核中');
      if (Number(s) === 1) return I18n.t('審核通過');
      if (Number(s) === 2) return I18n.t('審核駁回');
      return '';
    },
    formatDate(d) {
      if (!d) return '—';
      return d.slice(0, 16).replace('T', ' ');
    }
  },

  beforeUnmount() {
    if (this.showForm && !this.editId) this.saveDraft();
  }
};
