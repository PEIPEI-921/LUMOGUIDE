/* ============================================
   RegisterPage — Email registration flow
   ============================================ */

const RegisterPage = {
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <!-- Logo -->
        <div class="auth-logo">
          <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="auth-logo-img" />
        </div>

        <!-- Title -->
        <div class="auth-heading">
          <div class="auth-heading-title">{{ t('註冊') }}</div>
          <div class="auth-heading-bar"></div>
        </div>

        <!-- Invite Code -->
        <div class="auth-input-group">
          <span class="auth-input-icon">🎫</span>
          <input class="auth-input" v-model="inviteCode"
            :placeholder="t('請輸入邀請碼')" />
        </div>

        <!-- Email -->
        <div class="auth-input-group">
          <span class="auth-input-icon">📧</span>
          <input class="auth-input" v-model="email" type="email"
            :placeholder="t('請輸入郵箱')" autocomplete="email" />
        </div>

        <!-- Verify Code + Send button -->
        <div style="display:flex;gap:10px;">
          <div class="auth-input-group" style="flex:1;">
            <span class="auth-input-icon">✉️</span>
            <input class="auth-input" v-model="code"
              :placeholder="t('請輸入驗證碼')" />
          </div>
          <button class="auth-btn" :disabled="countdown > 0" @click="sendCode"
            style="width:auto;flex-shrink:0;padding:0 20px;font-size:13px;font-weight:500;">
            <span v-if="countdown > 0">{{ countdown }}s</span>
            <span v-else>{{ t('發送驗證碼') }}</span>
          </button>
        </div>

        <!-- Password -->
        <div class="auth-input-group">
          <span class="auth-input-icon">🔒</span>
          <input class="auth-input" v-model="password" :type="showPw ? 'text' : 'password'"
            :placeholder="t('請輸入密碼')" />
          <button class="auth-pw-toggle" type="button" @click="showPw = !showPw">
            {{ showPw ? '🙈' : '👁' }}
          </button>
        </div>

        <!-- Confirm Password -->
        <div class="auth-input-group">
          <span class="auth-input-icon">🔒</span>
          <input class="auth-input" v-model="confirmPassword" type="password"
            :placeholder="t('請確認新密碼')" />
        </div>

        <!-- Register button -->
        <button class="auth-btn" :disabled="loading" @click="doRegister">
          <span v-if="loading">{{ t('加載中...') }}</span>
          <span v-else>{{ t('註冊') }}</span>
        </button>

        <!-- Agreement -->
        <div class="auth-agreement">
          <input type="checkbox" v-model="agreed" />
          <span>{{ t('我巳閱讀並同意') }}<a href="#" @click.prevent>{{ t('用戶協議') }}</a>{{ t('和') }}<a href="#" @click.prevent>{{ t('隱私政策') }}</a></span>
        </div>

        <!-- Switch to login -->
        <div class="auth-switch">
          <a href="#" @click.prevent="$router.push('/login')">{{ t('已有賬號？登錄') }}</a>
        </div>
      </div>
    </div>
  `,

  data() {
    return {
      email: '',
      code: '',
      password: '',
      confirmPassword: '',
      inviteCode: '',
      agreed: true,
      loading: false,
      countdown: 0,
      timer: null,
      showPw: false
    };
  },

  methods: {
    t(key) { return I18n.t(key); },

    async sendCode() {
      if (!this.email) { showToast(I18n.t('請輸入郵箱')); return; }
      const res = await ApiProvider.post(ApiUrl.sendEmailCode, { email: this.email });
      if (res.success) {
        showToast(I18n.t('已發送驗證碼'));
        this.countdown = 60;
        this.timer = setInterval(() => {
          this.countdown--;
          if (this.countdown <= 0) clearInterval(this.timer);
        }, 1000);
      } else {
        showToast(res.message || I18n.t('操作失敗'));
      }
    },

    async doRegister() {
      if (!this.email) { showToast(I18n.t('請輸入郵箱')); return; }
      if (!this.code) { showToast(I18n.t('驗證碼不能為空')); return; }
      if (!this.password || this.password.length < 6) { showToast(I18n.t('密碼長度不能少於6位')); return; }
      if (this.password !== this.confirmPassword) { showToast(I18n.t('兩次密碼不一致')); return; }
      if (!this.agreed) { showToast(I18n.t('請先同意用戶協議')); return; }

      this.loading = true;
      const res = await ApiProvider.post(ApiUrl.register, {
        email: this.email,
        code: this.code,
        password: this.password,
        inviter_code: this.inviteCode
      });
      this.loading = false;

      if (!res.success) {
        showToast(res.message || I18n.t('操作失敗'));
        return;
      }

      if (res.data && res.data.token) {
        await UserStore.login(res.data);
      }
      showToast(I18n.t('註冊成功'));
      this.$router.replace('/home');
    }
  },

  beforeUnmount() {
    if (this.timer) clearInterval(this.timer);
  }
};
