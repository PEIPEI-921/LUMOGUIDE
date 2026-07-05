/* ============================================
   RegisterPage — Email registration flow
   ============================================ */

const RegisterPage = {
  template: `
    <div class="auth-page">
      <app-header :title="t('註冊')" :show-back="true"></app-header>
      <div class="auth-content">
        <h1 class="auth-title">{{ t('註冊') }}</h1>
        <p class="auth-subtitle">{{ t('還沒有賬號？註冊') }}</p>

        <div class="form-group">
          <label class="form-label">{{ t('郵箱') }}</label>
          <input class="form-input" v-model="email" type="email"
            :placeholder="t('請輸入郵箱')" autocomplete="email" />
        </div>

        <div class="form-group flex gap-sm">
          <input class="form-input" v-model="code" style="flex:1;"
            :placeholder="t('請輸入驗證碼')" />
          <button class="btn-outline" :disabled="countdown > 0" @click="sendCode" style="flex-shrink:0;">
            <span v-if="countdown > 0">{{ countdown }}{{ t('秒後重新發送') }}</span>
            <span v-else>{{ t('發送驗證碼') }}</span>
          </button>
        </div>

        <div class="form-group">
          <label class="form-label">{{ t('密碼') }}</label>
          <input class="form-input" v-model="password" type="password"
            :placeholder="t('請輸入密碼')" />
        </div>

        <div class="form-group">
          <label class="form-label">{{ t('確認密碼') }} </label>
          <input class="form-input" v-model="confirmPassword" type="password"
            :placeholder="t('請確認新密碼')" />
        </div>

        <div class="form-group">
          <label class="form-label">{{ t('邀請碼') }} </label>
          <input class="form-input" v-model="inviteCode"
            :placeholder="t('請輸入邀請碼')" />
        </div>
      </div>

      <div class="bottom-actions">
        <div class="agreement-row mb-sm">
          <input type="checkbox" v-model="agreed" />
          <span>{{ t('我巳閱讀並同意') }}<a href="#" @click.prevent>{{ t('用戶協議') }}</a>{{ t('和') }}<a href="#" @click.prevent>{{ t('隱私政策') }}</a></span>
        </div>

        <button class="btn-primary" :disabled="loading" @click="doRegister">
          <span v-if="loading">{{ t('加載中...') }}</span>
          <span v-else>{{ t('註冊') }}</span>
        </button>

        <div style="text-align:center;">
          <a href="#" @click.prevent="$router.push('/login')" style="font-size:14px;color:var(--color-primary);">
            {{ t('已有賬號？登錄') }}
          </a>
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
      timer: null
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

      // Auto-login after register
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
