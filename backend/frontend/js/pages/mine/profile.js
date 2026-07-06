/* ============================================
   Profile Page (Refactored) — 个人中心
   Reference: PPCC profile/page.tsx + design/05-profile.html
   ============================================ */

const ProfilePage = {
  template: `
    <div class="page-content">
      <div v-if="!UserStore.isLogin" style="text-align:center;padding-top:80px">
        <div style="font-size:48px;margin-bottom:16px">👤</div>
        <p style="color:var(--color-secondary-text);margin-bottom:20px">{{ $t('登入後查看個人資訊與管理預約') }}</p>
        <button @click="$router.push('/login')" class="ds-btn ds-btn-primary" style="max-width:200px;margin:0 auto">
          {{ $t('立即登入') }}
        </button>
      </div>

      <div v-else-if="!user" class="loading-container" style="padding:80px 0">
        <div class="spinner"></div>
      </div>

      <div v-else class="ds-container-600">
        <!-- Profile Card -->
        <div class="ds-profile-card">
          <div class="ds-profile-top">
            <a href="#/profile/edit" class="ds-avatar" style="text-decoration:none;color:#fff">
              <img v-if="user.avatar" :src="user.avatar" alt="" style="width:100%;height:100%;border-radius:50%;object-fit:cover">
              <span v-else>{{ (user.nickname || user.name || '?')[0] }}</span>
            </a>
            <div class="ds-profile-info">
              <div class="ds-name-row">
                <span class="ds-name">{{ user.nickname || user.name }}</span>
                <span :class="['ds-badge', identityClass]">{{ identityLabel }}</span>
              </div>
              <div class="ds-meta">
                <span>ID: {{ (user.number || '').slice(0, 8) }}…</span>
                <span>{{ $t('邀請碼') }}: {{ user.inviter_code }}</span>
              </div>
            </div>
          </div>
          <div class="ds-stats">
            <a href="#/following" class="ds-stat">
              <div class="ds-stat-value">{{ user.follow_count ?? 0 }}</div>
              <div class="ds-stat-label">{{ $t('關注') }}</div>
            </a>
            <a href="#/followers" class="ds-stat">
              <div class="ds-stat-value">{{ user.fan_count ?? 0 }}</div>
              <div class="ds-stat-label">{{ $t('粉絲') }}</div>
            </a>
            <a href="#/integral" class="ds-stat">
              <div class="ds-stat-value">{{ user.integral ?? 0 }}</div>
              <div class="ds-stat-label">{{ $t('積分') }}</div>
            </a>
          </div>
        </div>

        <!-- Menu: Account -->
        <div class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('帳號') }}</div>
          <a href="#/profile/edit" class="ds-menu-item">
            <span>✏️ {{ $t('編輯資料') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/modify-password" class="ds-menu-item">
            <span>🔒 {{ $t('修改密碼') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/modify-phone" class="ds-menu-item">
            <span>📱 {{ $t('綁定手機') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Menu: Interaction -->
        <div class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('互動') }}</div>
          <a href="#/following" class="ds-menu-item">
            <span>❤️ {{ $t('我的關注') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/followers" class="ds-menu-item">
            <span>👥 {{ $t('我的粉絲') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/evaluations" class="ds-menu-item">
            <span>⭐ {{ $t('我的評價') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Menu: Bookings -->
        <div class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('預約') }}</div>
          <a href="#/my-bookings" class="ds-menu-item">
            <span>📋 {{ $t('我的預約') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a v-if="isGuide" href="#/guide/bookings" class="ds-menu-item">
            <span>📅 {{ $t('預約我的') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a v-if="isCompany" href="#/merchant/bookings" class="ds-menu-item">
            <span>📅 {{ $t('預約我的') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Menu: Management (for guide/company) -->
        <div v-if="isGuide || isCompany" class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('管理') }}</div>
          <a v-if="isGuide" href="#/guide/publish" class="ds-menu-item">
            <span>📝 {{ $t('發布管理') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a v-if="isGuide" href="#/guide/certify" class="ds-menu-item">
            <span>🏙️ {{ $t('我的城市') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a v-if="isCompany" href="#/merchant/manage" class="ds-menu-item">
            <span>🏪 {{ $t('店鋪管理') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Menu: Other -->
        <div class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('其他') }}</div>
          <a href="#/integral" class="ds-menu-item">
            <span>🎁 {{ $t('積分商城') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/vip" class="ds-menu-item">
            <span>💎 {{ $t('會員中心') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/address" class="ds-menu-item">
            <span>📦 {{ $t('收貨地址') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/invite" class="ds-menu-item">
            <span>🤝 {{ $t('邀請好友') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/feedback" class="ds-menu-item">
            <span>💬 {{ $t('意見反饋') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
          <a href="#/contact" class="ds-menu-item">
            <span>📞 {{ $t('聯絡我們') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Menu: Settings -->
        <div class="ds-menu-group">
          <div class="ds-menu-group-title">{{ $t('設定') }}</div>
          <a href="#/settings" class="ds-menu-item">
            <span>⚙️ {{ $t('設置') }}</span>
            <span class="ds-menu-arrow">›</span>
          </a>
        </div>

        <!-- Logout -->
        <button class="ds-logout-btn" @click="handleLogout">
          {{ $t('退出登錄') }}
        </button>
      </div>
    </div>
    </div>
  `,

  data() {
    return { loading: false };
  },

  computed: {
    user() {
      return UserStore.profile || UserStore.userInfo;
    },
    isGuide() {
      return (this.user?.identity || 1) === 2;
    },
    isCompany() {
      return (this.user?.identity || 1) === 3;
    },
    identityLabel() {
      if (this.isGuide) return this.$t ? this.$t('導遊') : '導遊';
      if (this.isCompany) return this.$t ? this.$t('企業') : '企業';
      return this.$t ? this.$t('用戶') : '用戶';
    },
    identityClass() {
      if (this.isGuide) return 'guide';
      if (this.isCompany) return 'company';
      return 'user';
    }
  },

  methods: {
    async handleLogout() {
      await UserStore.logout();
      this.$router.push('/welcome');
    }
  },

  mounted() {
    if (UserStore.isLogin && !this.user) {
      UserStore.fetchProfile?.() || UserStore.init?.();
    }
  }
};


/* ============================================
   Profile Edit Page — 编辑个人资料
   ============================================ */

const ProfileEditPage = {
  template: `
    <div class="page-content"><div class="ds-subpage ds-container-600">
      <div class="ds-page-head" style="padding-top:0">
        <h1>{{ $t('編輯資料') }}</h1>
      </div>

      <!-- Avatar -->
      <div style="display:flex;align-items:center;gap:16px;margin-bottom:24px">
        <div style="width:72px;height:72px;border-radius:50%;background:linear-gradient(135deg,var(--color-primary),#9B9FFF);overflow:hidden;flex-shrink:0">
          <img v-if="avatarPreview" :src="avatarPreview" style="width:100%;height:100%;object-fit:cover">
          <div v-else style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:28px;color:#fff">{{ (form.nickname || '?')[0] }}</div>
        </div>
        <button @click="uploadAvatar" class="ds-btn ds-btn-outline" style="font-size:13px">
          {{ $t('更換頭像') }}
        </button>
        <input ref="avatarInput" type="file" accept="image/*" style="display:none" @change="onAvatarChange">
      </div>

      <div class="ds-form-group">
        <label class="ds-label">{{ $t('暱稱') }}</label>
        <input v-model="form.nickname" class="ds-input" :placeholder="$t('請輸入暱稱')">
      </div>

      <div class="ds-form-group">
        <label class="ds-label">{{ $t('手機號') }}</label>
        <input v-model="form.phone" class="ds-input" :placeholder="$t('請輸入手機號')">
      </div>

      <button @click="save" :disabled="saving" class="ds-btn ds-btn-primary" style="width:100%;margin-top:16px">
        {{ saving ? $t('保存中...') : $t('保存') }}
      </button>

      <p v-if="message" style="text-align:center;margin-top:12px;font-size:13px;color:var(--color-green)">{{ message }}</p>
    </div>
    </div>
  `,
  data() {
    return {
      form: { nickname: '', phone: '' },
      avatarPreview: '',
      avatarFile: null,
      saving: false,
      message: ''
    };
  },
  methods: {
    initForm() {
      const user = UserStore.profile || UserStore.userInfo || {};
      this.form.nickname = user.nickname || user.name || '';
      this.form.phone = user.phone || '';
      this.avatarPreview = user.avatar || '';
    },
    uploadAvatar() {
      this.$refs.avatarInput.click();
    },
    onAvatarChange(e) {
      const file = e.target.files[0];
      if (!file) return;
      this.avatarFile = file;
      const reader = new FileReader();
      reader.onload = (ev) => { this.avatarPreview = ev.target.result; };
      reader.readAsDataURL(file);
    },
    async save() {
      this.saving = true;
      this.message = '';

      // Upload avatar if changed
      let avatarUrl = '';
      if (this.avatarFile) {
        const uploadRes = await ApiProvider.upload(ApiUrl.fileUpload, this.avatarFile, 'image');
        if (uploadRes.success) {
          avatarUrl = uploadRes.data?.url || uploadRes.data?.path || '';
        }
      }

      const data = { nickname: this.form.nickname };
      if (this.form.phone) data.phone = this.form.phone;
      if (avatarUrl) data.avatar = avatarUrl;

      const res = await ApiProvider.post(ApiUrl.editUserInfo, data);
      if (res.success) {
        this.message = '保存成功';
        // Refresh user info
        if (UserStore.fetchProfile) UserStore.fetchProfile();
        setTimeout(() => { this.$router.back(); }, 1000);
      } else {
        this.message = res.message || '保存失敗';
      }
      this.saving = false;
    }
  },
  mounted() { this.initForm(); }
};
