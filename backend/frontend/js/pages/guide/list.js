/* ============================================
   GuideListPage — 全部导游（三级联动：洲→地区→国家）
   只显示有导游内容的分类
   ============================================ */

function collectLeafIds(node) {
  if (!node.children || !node.children.length) return [node.id];
  let ids = [];
  for (const child of node.children) {
    ids = ids.concat(collectLeafIds(child));
  }
  return ids;
}

const GuideListPage = {
  template: `
    <div class="page-content">
      <div class="ds-page-wrapper" style="padding-top:16px">
        <!-- Search Bar -->
        <div style="display:flex;justify-content:center;margin-bottom:20px">
          <div style="position:relative;width:100%;max-width:640px">
            <input :value="searchText" @input="onSearchInput" :placeholder="$t('搜索導遊')"
              style="width:100%;padding:10px 36px 10px 0;background:none;border:none;border-bottom:1px solid rgba(226,232,240,.8);outline:none;font-size:14px;color:#0F172A;font-family:inherit;text-align:left"
              class="sketch-search-input">
            <svg style="position:absolute;right:0;top:50%;transform:translateY(-50%);pointer-events:none" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94A3B8" stroke-width="1.5"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.35-4.35"/></svg>
          </div>
        </div>

        <h1 style="font-family:var(--font-serif);font-size:24px;font-weight:400;margin-bottom:20px;color:#0F172A">{{ $t('導遊列表') }}</h1>

        <!-- Level 1: Continents -->
        <div v-if="level1.length > 0" style="display:flex;gap:24px;overflow-x:auto;margin-bottom:14px;padding-bottom:8px">
          <button @click="selectLevel(1, {id:0,name:'全部',children:level1})"
            style="font-size:14px;font-weight:400;white-space:nowrap;padding:0 0 6px;background:none;border:none;cursor:pointer;position:relative;color:rgba(51,65,85,.6)"
            :style="{ color: sel1 === null ? '#666FFF' : 'rgba(51,65,85,.6)' }">
            {{ $t('全部') }} ({{ allGuides.length }})
            <span v-if="sel1 === null" style="position:absolute;bottom:0;left:0;right:0;height:2px;background:#666FFF;border-radius:1px"></span>
          </button>
          <button v-for="c in level1" :key="c.id" @click="selectLevel(1, c)"
            style="font-size:14px;font-weight:400;white-space:nowrap;padding:0 0 6px;background:none;border:none;cursor:pointer;position:relative;color:rgba(51,65,85,.6)"
            :style="{ color: sel1 && sel1.id === c.id ? '#666FFF' : 'rgba(51,65,85,.6)' }">
            {{ c.name }} ({{ c._count }})
            <span v-if="sel1 && sel1.id === c.id" style="position:absolute;bottom:0;left:0;right:0;height:2px;background:#666FFF;border-radius:1px"></span>
          </button>
        </div>

        <!-- Level 2: Areas -->
        <div v-if="level2.length > 0" style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:10px">
          <button v-for="a in level2" :key="a.id" @click="selectLevel(2, a)"
            style="font-size:12px;padding:4px 12px;border-radius:100px;border:1px solid rgba(226,232,240,.8);background:none;cursor:pointer;white-space:nowrap;color:#475569"
            :style="sel2 && sel2.id === a.id ? { background:'#666FFF', color:'#fff', borderColor:'#666FFF' } : {}">
            {{ a.name }} ({{ a._count }})
          </button>
        </div>

        <!-- Level 3: Countries -->
        <div v-if="level3.length > 0" style="display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px;padding-bottom:8px">
          <button v-for="co in level3" :key="co.id" @click="selectLevel(3, co)"
            style="font-size:11px;padding:3px 10px;border-radius:100px;border:1px solid rgba(226,232,240,.8);background:none;cursor:pointer;white-space:nowrap;color:#475569"
            :style="sel3 && sel3.id === co.id ? { background:'#666FFF', color:'#fff', borderColor:'#666FFF' } : {}">
            {{ co.name }} ({{ co._count }})
          </button>
        </div>

        <!-- Loading -->
        <div v-if="loading" class="loading-container" style="padding:60px 0">
          <div class="spinner"></div>
        </div>

        <!-- Guide Grid -->
        <div v-else-if="guides.length > 0" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(140px,1fr));gap:12px">
          <a v-for="g in guides" :key="g.id" :href="'#/guide/' + g.id"
            class="ds-card ds-card-hover" style="text-decoration:none;color:inherit;display:flex;flex-direction:column;overflow:hidden;background:var(--color-bg-white)">
            <div style="aspect-ratio:3/4;overflow:hidden;background:var(--color-bg-card);border-bottom:1px solid var(--color-border)">
              <img v-if="g.photo" :src="g.photo" :alt="g.name" style="width:100%;height:100%;object-fit:cover;object-position:top center">
              <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;opacity:.25">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="8" r="4"/><path d="M20 22c0-4.4-3.6-8-8-8s-8 3.6-8 8"/></svg>
              </div>
            </div>
            <div style="padding:10px;color:var(--color-primary-text)">
              <div style="font-size:13px;font-weight:650;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ g.name }}</div>
              <div v-if="g.city_name" style="font-size:10px;color:var(--color-assistant-text);margin-top:2px;line-height:1.4">
                <div>{{ g.city_name }}</div>
                <div v-if="g.city_name_en">{{ g.city_name_en }}</div>
              </div>
            </div>
          </a>
        </div>

        <!-- Empty -->
        <div v-else class="ds-empty" style="color:rgba(255,255,255,.5)">{{ $t('暫無導遊') }}</div>
      </div>
    </div>
  `,

  data() {
    return {
      loading: true,
      allGuides: [],
      guides: [],
      tree: [],
      level1: [],
      level2: [],
      level3: [],
      sel1: null,
      sel2: null,
      sel3: null,
      searchText: '',
      hasGuideIds: new Set()  // Set of country_id that have at least one guide
    };
  },

  methods: {
    // Count guides in a tree node's subtree
    countGuides(node) {
      const leafIds = collectLeafIds(node);
      let count = 0;
      for (const id of leafIds) {
        if (this.hasGuideIds.has(id)) count++;
      }
      return count;
    },

    // Annotate each node with _count and filter out empty ones
    filterWithCounts(nodes) {
      return nodes.map(n => {
        n = { ...n, children: n.children || [] };
        n._count = this.countGuides(n);
        return n;
      }).filter(n => n._count > 0);
    },

    async load() {
      this.loading = true;
      const [guideRes, treeRes] = await Promise.all([
        ApiProvider.get(ApiUrl.guideList, { limit: 500 }),
        ApiProvider.get(ApiUrl.systemContinents)
      ]);
      if (guideRes.success && guideRes.data) {
        this.allGuides = guideRes.data.list || [];
      }
      // Build set of country_ids that have guides
      for (const g of this.allGuides) {
        if (g.country_id) this.hasGuideIds.add(g.country_id);
      }
      if (treeRes.success && treeRes.data) {
        this.tree = treeRes.data.data || [];
      }
      this.level1 = this.filterWithCounts(this.tree);
      this.applyFilter();
      this.loading = false;
    },

    selectLevel(level, node) {
      if (level === 1) {
        if (node.id === 0) {
          this.sel1 = null;
          this.sel2 = null;
          this.sel3 = null;
          this.level2 = [];
          this.level3 = [];
        } else {
          this.sel1 = node;
          this.sel2 = null;
          this.sel3 = null;
          this.level2 = this.filterWithCounts(node.children || []);
          this.level3 = [];
        }
      } else if (level === 2) {
        this.sel2 = node;
        this.sel3 = null;
        this.level3 = this.filterWithCounts(node.children || []);
      } else if (level === 3) {
        this.sel3 = node;
      }
      this.applyFilter();
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
      const res = await ApiProvider.get(ApiUrl.guideList, params);
      if (res.success && res.data) {
        this.allGuides = res.data.list || [];
      }
      // Rebuild hasGuideIds
      this.hasGuideIds = new Set();
      for (const g of this.allGuides) {
        if (g.country_id) this.hasGuideIds.add(g.country_id);
      }
      this.level1 = this.filterWithCounts(this.tree);
      // Refresh level2/level3 if a continent is selected
      if (this.sel1) {
        this.level2 = this.filterWithCounts(this.sel1.children || []);
        if (this.sel2) {
          this.level3 = this.filterWithCounts(this.sel2.children || []);
        }
      }
      this.applyFilter();
      this.loading = false;
    },

    applyFilter() {
      if (!this.searchText && !this.sel1) {
        this.guides = this.allGuides;
        return;
      }

      let filtered = this.allGuides;

      // Geographic filter (server already handles text search, client handles geo)
      if (this.sel1) {
        let targetIds;
        if (this.sel3) {
          targetIds = new Set([this.sel3.id]);
        } else if (this.sel2) {
          targetIds = new Set(collectLeafIds(this.sel2));
        } else {
          targetIds = new Set(collectLeafIds(this.sel1));
        }
        filtered = filtered.filter(g => targetIds.has(g.country_id));
      }

      this.guides = filtered;
    }
  },

  mounted() {
    this.load();
  },

  beforeUnmount() {
    clearTimeout(this._searchTimer);
  }
};
