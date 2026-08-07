/* ============================================
   MerchantListPage — 全部商家（两级标签：类型→子分类）
   ============================================ */

const HIDDEN_TYPES = new Set([5, 6, 7]); // 交通, 设施, 活动

const MerchantListPage = {
  template: `
    <div class="page-content">
      <div class="ds-page-wrapper" style="padding-top:16px">
        <!-- Search Bar -->
        <div style="display:flex;justify-content:center;margin-bottom:20px">
          <div style="position:relative;width:100%;max-width:640px">
            <input :value="searchText" @input="onSearchInput" :placeholder="$t('搜索商家')"
              style="width:100%;padding:10px 36px 10px 0;background:none;border:none;border-bottom:1px solid rgba(226,232,240,.8);outline:none;font-size:14px;color:#0F172A;font-family:inherit;text-align:left"
              class="sketch-search-input">
            <svg style="position:absolute;right:0;top:50%;transform:translateY(-50%);pointer-events:none" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94A3B8" stroke-width="1.5"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.35-4.35"/></svg>
          </div>
        </div>

        <h1 style="font-family:var(--font-serif);font-size:24px;font-weight:400;margin-bottom:20px;color:#0F172A">{{ $t('全部商家') }}</h1>

        <!-- Loading -->
        <div v-if="loading" class="loading-container" style="padding:60px 0">
          <div class="spinner"></div>
        </div>

        <template v-else>
          <!-- Level 1: Type Tabs -->
          <div v-if="categories.length > 0" style="display:flex;gap:24px;overflow-x:auto;margin-bottom:14px;padding-bottom:8px">
            <button @click="selectType(0)"
              style="font-size:14px;font-weight:400;white-space:nowrap;padding:0 0 6px;background:none;border:none;cursor:pointer;position:relative;color:rgba(51,65,85,.6)"
              :style="{ color: activeType === 0 ? '#666FFF' : 'rgba(51,65,85,.6)' }">
              {{ $t('全部') }} ({{ allMerchants.length }})
              <span v-if="activeType === 0" style="position:absolute;bottom:0;left:0;right:0;height:2px;background:#666FFF;border-radius:1px"></span>
            </button>
            <button v-for="cat in categories" :key="cat.type_id" @click="selectType(cat.type_id)"
              style="font-size:14px;font-weight:400;white-space:nowrap;padding:0 0 6px;background:none;border:none;cursor:pointer;position:relative;color:rgba(51,65,85,.6)"
              :style="{ color: activeType === cat.type_id ? '#666FFF' : 'rgba(51,65,85,.6)' }">
              {{ cat.type_name }} ({{ cat._count }})
              <span v-if="activeType === cat.type_id" style="position:absolute;bottom:0;left:0;right:0;height:2px;background:#666FFF;border-radius:1px"></span>
            </button>
          </div>

          <!-- Level 2: Class Pills -->
          <div v-if="level2.length > 0" style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px;padding-bottom:8px">
            <button v-for="cls in level2" :key="cls.class_id" @click="selectClass(cls.class_id)"
              style="font-size:12px;padding:4px 12px;border-radius:100px;border:1px solid rgba(226,232,240,.8);background:none;cursor:pointer;white-space:nowrap;color:#475569"
              :style="activeClass === cls.class_id ? { background:'#666FFF', color:'#fff', borderColor:'#666FFF' } : {}">
              {{ cls.class_name }} ({{ cls.list.length }})
            </button>
          </div>

          <!-- Merchant Grid -->
          <div v-if="displayList.length > 0" style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px">
            <a v-for="m in displayList" :key="m.id" :href="'#/detail/' + m.type_id + '?id=' + m.id"
              class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:flex;flex-direction:column;overflow:hidden;background:var(--color-bg-white)">
              <div style="aspect-ratio:16/9;overflow:hidden;background:var(--color-bg-card);border-bottom:1px solid var(--color-border)">
                <img v-if="m.first_picture" :src="m.first_picture" :alt="m.name" style="width:100%;height:100%;object-fit:cover">
                <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;opacity:.25">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                </div>
              </div>
              <div style="padding:10px;color:var(--color-primary-text)">
                <div style="font-size:13px;font-weight:650;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ m.name }}</div>
                <div v-if="m.city_name" style="font-size:10px;color:var(--color-assistant-text);margin-top:2px;line-height:1.4">
                  <div>{{ m.city_name }}</div>
                  <div v-if="m.address" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ m.address }}</div>
                </div>
                <div v-if="activeType === 0" style="font-size:9px;color:var(--color-primary);margin-top:3px;padding:1px 6px;border-radius:10px;background:var(--color-accent-soft);display:inline-block">{{ m.type_name }} · {{ m.class_name }}</div>
              </div>
            </a>
          </div>

          <!-- Empty -->
          <div v-else class="ds-empty" style="color:rgba(255,255,255,.5)">{{ $t('暫無商家') }}</div>
        </template>
      </div>
    </div>
  `,

  data() {
    return {
      loading: true,
      searchText: '',
      allMerchants: [],
      categories: [],
      activeType: 0,
      activeClass: 0,
      level2: []
    };
  },

  computed: {
    displayList() {
      if (this.activeType === 0) {
        return this.allMerchants;
      }
      if (this.activeClass > 0) {
        const l2 = this.level2.find(c => c.class_id === this.activeClass);
        return l2 ? l2.list : [];
      }
      return this.allMerchants.filter(m => m.type_id === this.activeType);
    }
  },

  methods: {
    async load() {
      await this.doSearch();
    },

    onSearchInput(e) {
      this.searchText = e.target.value;
      clearTimeout(this._searchTimer);
      this._searchTimer = setTimeout(() => {
        this.doSearch();
      }, 300);
    },

    async doSearch() {
      this.loading = true;
      const params = { limit: 500 };
      if (this.searchText) {
        params.search = this.searchText;
      }
      const res = await ApiProvider.get(ApiUrl.merchantList, params);
      if (res.success && res.data) {
        this.allMerchants = (res.data.all || []).filter(m => !HIDDEN_TYPES.has(m.type_id));
        this.categories = (res.data.categories || [])
          .filter(cat => !HIDDEN_TYPES.has(cat.type_id))
          .map(cat => {
            let count = 0;
            (cat.classes || []).forEach(cls => { count += cls.list.length; });
            return { ...cat, _count: count };
          });
        // Reset selection and refresh level2
        if (this.activeType > 0) {
          const cat = this.categories.find(c => c.type_id === this.activeType);
          this.level2 = cat ? (cat.classes || []) : [];
        }
      }
      this.loading = false;
    },

    selectType(typeId) {
      this.activeType = typeId;
      this.activeClass = 0;
      if (typeId === 0) {
        this.level2 = [];
      } else {
        const cat = this.categories.find(c => c.type_id === typeId);
        this.level2 = cat ? (cat.classes || []) : [];
      }
    },

    selectClass(classId) {
      this.activeClass = classId;
    }
  },

  mounted() {
    this.load();
  },

  beforeUnmount() {
    clearTimeout(this._searchTimer);
  }
};
