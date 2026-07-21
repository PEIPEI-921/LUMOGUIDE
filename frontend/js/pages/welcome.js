/* ============================================
   WelcomePage v2 — Static logo + serif text
   Auto-redirect after 3s
   ============================================ */

const WelcomePage = {
  template: `
    <div class="welcome-page-v2">
      <div class="welcome-logo-v2">
        <img src="/images/logo-app-icon.png" alt="LUMO GUIDE" />
      </div>
      <div class="welcome-text-v2">{{ t('路上有光，盟友相伴') }}</div>
    </div>
  `,

  mounted() {
    setTimeout(() => {
      if (UserStore.isLogin) {
        this.$router.replace('/home');
      } else {
        this.$router.replace('/login');
      }
    }, 3000);
  }
};
