/* ============================================
   LoginPage — Email/password login
   ============================================ */

const LoginPage = {
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <!-- Logo -->
        <div class="auth-logo">
          <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="auth-logo-img" />
        </div>

        <!-- Title -->
        <div class="auth-heading">
          <div class="auth-heading-title">{{ t('登錄') }}</div>
          <div class="auth-heading-bar"></div>
        </div>

        <!-- Email -->
        <div class="auth-input-group">
          <span class="auth-input-icon">📧</span>
          <input class="auth-input" v-model="email" type="email"
            :placeholder="t('請輸入郵箱')" autocomplete="email" />
        </div>

        <!-- Password -->
        <div class="auth-input-group">
          <span class="auth-input-icon">🔒</span>
          <input class="auth-input" v-model="password" :type="showPw ? 'text' : 'password'"
            :placeholder="t('請輸入密碼')" autocomplete="current-password" />
          <button class="auth-pw-toggle" type="button" @click="showPw = !showPw">
            {{ showPw ? '🙈' : '👁' }}
          </button>
        </div>

        <!-- Login button -->
        <button class="auth-btn" :disabled="loading" @click="doLogin">
          <span v-if="loading">{{ t('加載中...') }}</span>
          <span v-else>登 录</span>
        </button>

        <!-- Remember + Forgot -->
        <div style="display:flex;justify-content:space-between;align-items:center;">
          <label class="auth-remember">
            <input type="checkbox" v-model="remember" />
            {{ t('記住密碼') }}
          </label>
          <a class="auth-link" href="#" @click.prevent="$router.push('/forget-password')">{{ t('忘記密碼') }}</a>
        </div>

        <!-- Footer links -->
        <div class="auth-footer">
          <a href="#" @click.prevent="$router.push('/forget-password')">{{ t('忘記密碼') }}</a>
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
      agreed: true,
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
