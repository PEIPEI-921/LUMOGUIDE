/* ============================================
   WelcomePage — Splash/landing page
   ============================================ */

const WelcomePage = {
  template: `
    <div class="welcome-page">
      <div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;">
        <div style="font-size:64px;">🌍</div>
        <h1 style="font-size:28px;font-weight:700;color:var(--color-primary);">
          LUMOGUIDE
        </h1>
        <p style="font-size:16px;color:var(--color-secondary-text);text-align:center;">
          {{ $t('你的隨身旅遊指南') }}
        </p>
      </div>
      <div style="width:100%;max-width:320px;display:flex;flex-direction:column;gap:12px;padding-bottom:40px;">
        <button class="btn-primary" @click="goLogin">
          {{ $t('登錄') }}
        </button>
        <button class="btn-outline" style="width:100%;height:44px;justify-content:center;" @click="goRegister">
          {{ $t('註冊') }}
        </button>
        <button class="btn-text" @click="goHome">
          {{ $t('開始探索') }}
        </button>
      </div>
    </div>
  `,

  methods: {
    goLogin() {
      this.$router.push('/login');
    },
    goRegister() {
      this.$router.push('/register');
    },
    goHome() {
      this.$router.push('/home');
    }
  }
};
