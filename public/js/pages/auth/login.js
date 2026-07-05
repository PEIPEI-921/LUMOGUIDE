/* ============================================
   LoginPage — Email/password login
   ============================================ */

const LoginPage = {
  template: `
    <div class="auth-page">
      <app-header :title="t('登錄')" :show-back="true"></app-header>
      <div class="auth-content">
        <h1 class="auth-title">{{ t('登錄') }}</h1>
        <p class="auth-subtitle">{{ t('歡迎來到 LUMOGUIDE') }}</p>

        <div class="form-group">
          <label class="form-label">{{ t('郵箱') }}</label>
          <input class="form-input" v-model="email" type="email"
            :placeholder="t('請輸入郵箱')" autocomplete="email" />
        </div>

        <div class="form-group">
          <label class="form-label">{{ t('請輸入密碼') }}</label>
          <input class="form-input" v-model="password" type="password"
            :placeholder="t('請輸入密碼')" autocomplete="current-password" />
        </div>

        <div class="form-group flex items-center justify-between">
          <label class="flex items-center gap-sm" style="font-size:12px;color:var(--color-assistant-text);">
            <input type="checkbox" v-model="remember" style="accent-color:var(--color-primary);" />
            {{ t('記住密碼') }}
          </label>
          <a href="#" @click.prevent="$router.push('/forget-password')" style="font-size:12px;color:var(--color-primary);">
            {{ t('忘記密碼') }}
          </a>
        </div>
      </div>

      <div class="bottom-actions">
        <div class="agreement-row mb-sm">
          <input type="checkbox" v-model="agreed" />
          <span>{{ t('我巳閱讀並同意') }}<a href="#" @click.prevent="showProtocol('user')">{{ t('用戶協議') }}</a>{{ t('和') }}<a href="#" @click.prevent="showProtocol('privacy')">{{ t('隱私政策') }}</a></span>
        </div>

        <button class="btn-primary" :disabled="loading" @click="doLogin">
          <span v-if="loading">{{ t('加載中...') }}</span>
          <span v-else>{{ t('登錄') }}</span>
        </button>

        <div style="text-align:center;">
          <a href="#" @click.prevent="$router.push('/register')" style="font-size:14px;color:var(--color-primary);">
            {{ t('還沒有賬號？註冊') }}
          </a>
        </div>
      </div>
    </div>
  `,

  data() {
    const creds = UserStore.getCredentials();
    return {
      email: creds.email,
      password: creds.password,
      remember: creds.remember,
      agreed: true,
      loading: false
    };
  },

  methods: {
    t(key) { return I18n.t(key); },

    async doLogin() {
      if (!this.email) { showToast(I18n.t('請輸入郵箱')); return; }
      if (!this.password || this.password.length < 6) { showToast(I18n.t('密碼長度不能少於6位')); return; }
      if (!this.agreed) { showToast(I18n.t('請先同意用戶協議')); return; }

      this.loading = true;
      const res = await ApiProvider.post(ApiUrl.login, { email: this.email, password: this.password });
      this.loading = false;

      if (!res.success) {
        showToast(res.message || I18n.t('操作失敗'));
        return;
      }

      UserStore.saveCredentials(this.email, this.password, this.remember);
      await UserStore.login(res.data);
      showToast(I18n.t('登錄成功'));
      this.$router.replace('/home');
    },

    showProtocol(type) {
      // Open protocol page in new tab
      window.open('/protocol/' + (type === 'user' ? 'user_protocol' : 'privacy_protocol'), '_blank');
    }
  }
};
