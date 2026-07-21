/* ============================================
   LoginPage — Email/password login
   ============================================ */

const LoginPage = {
  template: `
    <div class="auth-page">
      <!-- White logo above card -->
      <img src="/images/logo_lumoguide.png" alt="LUMO GUIDE"
        style="height:42px;width:auto;margin-bottom:28px;filter:brightness(0) invert(1);opacity:0.9" />

      <div class="auth-card">
        <div class="auth-brand-sub">{{ t('路上有光，盟友相伴') }}</div>

        <form class="auth-form" @submit.prevent="doLogin" autocomplete="on">
          <!-- Email -->
          <div class="auth-input-group">
            <span class="auth-input-icon">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <rect x="2" y="4" width="20" height="16" rx="2"/>
                <path d="m22 4-10 8L2 4"/>
              </svg>
            </span>
            <input class="auth-input" v-model="email" type="email" name="email"
              :placeholder="t('請輸入郵箱')" autocomplete="email" />
          </div>

          <!-- Password -->
          <div class="auth-input-group">
            <span class="auth-input-icon">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                <circle cx="12" cy="16" r="1"/>
              </svg>
            </span>
            <input class="auth-input" v-model="password" :type="showPw ? 'text' : 'password'" name="password"
              :placeholder="t('請輸入密碼')" autocomplete="current-password" />
            <button class="auth-pw-toggle" type="button" @click="showPw = !showPw">
              <svg v-if="showPw" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                <path d="m14.12 14.12a3 3 0 1 1-4.24-4.24"/>
                <line x1="1" y1="1" x2="23" y2="23"/>
              </svg>
              <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
            </button>
          </div>

          <!-- Login button -->
          <button class="auth-btn" type="submit" :disabled="loading">
            <span v-if="loading">{{ t('加載中...') }}</span>
            <span v-else>{{ t('登錄') }}</span>
          </button>
        </form>

        <!-- Remember + Forgot -->
        <div class="auth-remember-row">
          <label class="auth-remember">
            <input type="checkbox" v-model="remember" />
            {{ t('記住密碼') }}
          </label>
          <a class="auth-link" href="#" @click.prevent="$router.push('/forget-password')">{{ t('忘記密碼') }}</a>
        </div>

        <!-- Footer links -->
        <div class="auth-footer">
          <a href="#" @click.prevent="$router.push('/register')">{{ t('還沒有賬號？去註冊') }}</a>
        </div>

        <!-- Agreement -->
        <div class="auth-agreement">
          <input type="checkbox" v-model="agreed" />
          <span>{{ t('我巳閱讀並同意') }}<a href="#" @click.prevent="showProtocol('user')">{{ t('用戶協議') }}</a>{{ t('和') }}<a href="#" @click.prevent="showProtocol('privacy')">{{ t('隱私政策') }}</a></span>
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
      agreed: false,
      loading: false,
      showPw: false
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
      window.open('/protocol/' + (type === 'user' ? 'user_protocol' : 'privacy_protocol'), '_blank');
    }
  }
};
