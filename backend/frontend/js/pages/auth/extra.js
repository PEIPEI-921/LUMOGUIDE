/* ============================================
   Auth Extra Pages — 忘记密码 / 验证码 / 设置密码
   ============================================ */

const ForgetPasswordPage = {
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <div class="auth-logo">
          <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="auth-logo-img" />
        </div>

        <div class="auth-heading">
          <div class="auth-heading-title">{{ $t('忘記密碼') }}</div>
          <div class="auth-heading-bar"></div>
        </div>

        <p style="font-size:13px;color:var(--color-secondary-text);text-align:center;">{{ $t('請輸入您的註冊郵箱，我們將發送驗證碼') }}</p>

        <div class="auth-input-group">
          <span class="auth-input-icon">📧</span>
          <input v-model="email" type="email" class="auth-input" :placeholder="$t('請輸入郵箱地址')">
        </div>

        <button @click="sendCode" :disabled="sending || !email" class="auth-btn">
          {{ sending ? $t('發送中...') : $t('發送驗證碼') }}
        </button>

        <p v-if="error" style="color:var(--color-red);font-size:13px;text-align:center;">{{ error }}</p>
        <p v-if="success" style="color:var(--color-green);font-size:13px;text-align:center;">{{ success }}</p>

        <div class="auth-switch">
          <a href="#" @click.prevent="$router.back()">{{ $t('返回登錄') }}</a>
        </div>
      </div>
    </div>
  `,
  data() {
    return { email: '', sending: false, error: '', success: '' };
  },
  methods: {
    async sendCode() {
      if (!this.email) return;
      this.sending = true;
      this.error = '';
      this.success = '';
      const res = await ApiProvider.post(ApiUrl.sendEmailCode, {
        email: this.email,
        type: 'reset'
      });
      if (res.success) {
        this.success = '驗證碼已發送';
        setTimeout(() => { this.$router.push('/verify-code?email=' + encodeURIComponent(this.email) + '&type=reset'); }, 1500);
      } else {
        this.error = res.message || '發送失敗';
      }
      this.sending = false;
    }
  }
};


const VerifyCodePage = {
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <div class="auth-logo">
          <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="auth-logo-img" />
        </div>

        <div class="auth-heading">
          <div class="auth-heading-title">{{ $t('輸入驗證碼') }}</div>
          <div class="auth-heading-bar"></div>
        </div>

        <p style="font-size:13px;color:var(--color-secondary-text);text-align:center;">
          {{ $t('驗證碼已發送至') }} {{ email }}
        </p>

        <div class="auth-input-group">
          <span class="auth-input-icon">✉️</span>
          <input v-model="code" class="auth-input" :placeholder="$t('請輸入6位驗證碼')" maxlength="6">
        </div>

        <button @click="verify" :disabled="verifying || code.length < 4" class="auth-btn">
          {{ verifying ? $t('驗證中...') : $t('驗證') }}
        </button>

        <button @click="resend" :disabled="countdown > 0"
          style="width:100%;text-align:center;font-size:13px;color:var(--color-primary);background:none;border:none;cursor:pointer;padding:8px;">
          {{ countdown > 0 ? countdown + 's' : $t('重新發送') }}
        </button>

        <p v-if="error" style="color:var(--color-red);font-size:13px;text-align:center;">{{ error }}</p>
      </div>
    </div>
  `,
  data() {
    return {
      email: '', code: '', type: 'reset', verifying: false,
      countdown: 0, countdownTimer: null, error: ''
    };
  },
  methods: {
    async verify() {
      this.verifying = true;
      this.error = '';
      const res = await ApiProvider.post(ApiUrl.verifyCode, {
        email: this.email,
        code: this.code,
        type: this.type
      });
      if (res.success) {
        this.$router.push('/password-input?email=' + encodeURIComponent(this.email) + '&code=' + this.code);
      } else {
        this.error = res.message || '驗證失敗';
      }
      this.verifying = false;
    },
    async resend() {
      if (this.countdown > 0) return;
      const res = await ApiProvider.post(ApiUrl.sendEmailCode, {
        email: this.email,
        type: this.type
      });
      if (res.success) {
        this.countdown = 60;
        this.countdownTimer = setInterval(() => {
          this.countdown--;
          if (this.countdown <= 0) clearInterval(this.countdownTimer);
        }, 1000);
      }
    }
  },
  mounted() {
    this.email = this.$route.query.email || '';
    this.type = this.$route.query.type || 'reset';
  },
  beforeUnmount() {
    if (this.countdownTimer) clearInterval(this.countdownTimer);
  }
};


const PasswordInputPage = {
  template: `
    <div class="auth-page">
      <div class="auth-card">
        <div class="auth-logo">
          <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="auth-logo-img" />
        </div>

        <div class="auth-heading">
          <div class="auth-heading-title">{{ $t('設置新密碼') }}</div>
          <div class="auth-heading-bar"></div>
        </div>

        <div class="auth-input-group">
          <span class="auth-input-icon">🔒</span>
          <input v-model="password" :type="showPw ? 'text' : 'password'" class="auth-input"
            :placeholder="$t('請輸入新密碼（至少6位）')">
          <button class="auth-pw-toggle" type="button" @click="showPw = !showPw">
            {{ showPw ? '🙈' : '👁' }}
          </button>
        </div>

        <div class="auth-input-group">
          <span class="auth-input-icon">🔒</span>
          <input v-model="confirmPwd" type="password" class="auth-input"
            :placeholder="$t('請再次輸入密碼')">
        </div>

        <button @click="reset" :disabled="resetting || !password || password !== confirmPwd" class="auth-btn">
          {{ resetting ? $t('重置中...') : $t('重置密碼') }}
        </button>

        <p v-if="error" style="color:var(--color-red);font-size:13px;text-align:center;">{{ error }}</p>
        <p v-if="success" style="color:var(--color-green);font-size:13px;text-align:center;">{{ success }}</p>
      </div>
    </div>
  `,
  data() {
    return { password: '', confirmPwd: '', resetting: false, error: '', success: '', showPw: false };
  },
  methods: {
    async reset() {
      if (this.password !== this.confirmPwd) {
        this.error = '兩次密碼不一致';
        return;
      }
      this.resetting = true;
      this.error = '';
      this.success = '';
      const res = await ApiProvider.post(ApiUrl.resetPassword, {
        email: this.$route.query.email || '',
        code: this.$route.query.code || '',
        password: this.password
      });
      if (res.success) {
        this.success = '密碼重置成功，即將跳轉到登錄頁';
        setTimeout(() => { this.$router.push('/login'); }, 1500);
      } else {
        this.error = res.message || '重置失敗';
      }
      this.resetting = false;
    }
  }
};
