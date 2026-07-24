/* ============================================
   LoginPage — Email/password login
   ============================================ */

// Login attempt tracker (anti-brute-force)
const LOGIN_ATTEMPT_KEY = '_login_attempts';
const MAX_ATTEMPTS = 5;
const ATTEMPT_WINDOW_MS = 10 * 60 * 1000;   // 10 minutes
const LOCKOUT_DURATION_MS = 15 * 60 * 1000;  // 15 minutes

function getLoginAttempts() {
  try { return JSON.parse(localStorage.getItem(LOGIN_ATTEMPT_KEY)) || []; } catch (e) { return []; }
}
function saveLoginAttempts(attempts) {
  localStorage.setItem(LOGIN_ATTEMPT_KEY, JSON.stringify(attempts));
}
function clearLoginAttempts() {
  localStorage.removeItem(LOGIN_ATTEMPT_KEY);
}
function getLockoutRemaining() {
  const attempts = getLoginAttempts();
  if (attempts.length < MAX_ATTEMPTS) return 0;
  const now = Date.now();
  // Clean expired attempts
  const recent = attempts.filter(ts => now - ts < ATTEMPT_WINDOW_MS);
  if (recent.length < MAX_ATTEMPTS) { saveLoginAttempts(recent); return 0; }
  const earliest = recent[recent.length - MAX_ATTEMPTS];
  const unlockAt = earliest + ATTEMPT_WINDOW_MS;
  return Math.max(0, unlockAt - now);
}

const LoginPage = {
  template: `
    <div class="auth-page">
      <!-- White logo above card -->
      <img src="/images/logo_lumoguide.png" alt="LUMO GUIDE"
        style="height:42px;width:auto;margin-bottom:28px;filter:brightness(0) invert(1);opacity:0.9" />

      <div class="auth-card">
        <div class="auth-brand-sub">{{ t('路上有光，盟友相伴') }}</div>

        <!-- Lockout warning -->
        <div v-if="lockoutRemaining > 0" class="auth-lockout">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
          <span>{{ t('登錄嘗試次數過多，請稍後再試') }} ({{ formatLockout }})</span>
        </div>

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
              :placeholder="t('請輸入郵箱')" autocomplete="email" :disabled="lockedOut" />
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
              :placeholder="t('請輸入密碼')" autocomplete="current-password" :disabled="lockedOut" />
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
          <button class="auth-btn" type="submit" :disabled="loading || lockedOut">
            <span v-if="loading">{{ t('加載中...') }}</span>
            <span v-else-if="lockedOut">{{ formatLockout }}</span>
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
      showPw: false,
      lockoutRemaining: 0,
      _lockoutTimer: null
    };
  },

  computed: {
    lockedOut() { return this.lockoutRemaining > 0; },
    formatLockout() {
      const s = Math.ceil(this.lockoutRemaining / 1000);
      const m = Math.floor(s / 60);
      const sec = s % 60;
      return m > 0 ? `${m}m ${sec.toString().padStart(2, '0')}s` : `${sec}s`;
    }
  },

  methods: {
    t(key) { return I18n.t(key); },

    async doLogin() {
      if (this.lockedOut) return;
      if (!this.email) { showToast(I18n.t('請輸入郵箱')); return; }
      if (!this.password || this.password.length < 6) { showToast(I18n.t('密碼長度不能少於6位')); return; }
      if (!this.agreed) { showToast(I18n.t('請先同意用戶協議')); return; }

      this.loading = true;
      const res = await ApiProvider.post(ApiUrl.login, { email: this.email, password: this.password });
      this.loading = false;

      if (!res.success) {
        // Record failed attempt
        const attempts = getLoginAttempts();
        attempts.push(Date.now());
        saveLoginAttempts(attempts);
        // Check if locked out now
        const remaining = getLockoutRemaining();
        if (remaining > 0) {
          this.lockoutRemaining = remaining;
          this.startLockoutCountdown();
          showToast(I18n.t('登錄嘗試次數過多，請15分鐘後再試'));
        } else {
          showToast(res.message || I18n.t('登錄失敗'));
        }
        return;
      }

      // Success — clear attempts
      clearLoginAttempts();
      UserStore.saveCredentials(this.email, this.password, this.remember);
      await UserStore.login(res.data);
      showToast(I18n.t('登錄成功'));
      this.$router.replace('/home');
    },

    startLockoutCountdown() {
      if (this._lockoutTimer) clearInterval(this._lockoutTimer);
      this._lockoutTimer = setInterval(() => {
        const remaining = getLockoutRemaining();
        if (remaining <= 0) {
          this.lockoutRemaining = 0;
          clearInterval(this._lockoutTimer);
          this._lockoutTimer = null;
        } else {
          this.lockoutRemaining = remaining;
        }
      }, 1000);
    },

    showProtocol(type) {
      window.open('/protocol/' + (type === 'user' ? 'user_protocol' : 'privacy_protocol'), '_blank');
    }
  },

  mounted() {
    const remaining = getLockoutRemaining();
    if (remaining > 0) {
      this.lockoutRemaining = remaining;
      this.startLockoutCountdown();
    }
  },

  beforeUnmount() {
    if (this._lockoutTimer) { clearInterval(this._lockoutTimer); this._lockoutTimer = null; }
  }
};
