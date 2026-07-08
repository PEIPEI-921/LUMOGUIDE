/* ============================================
   WelcomePage — 品牌开场动画
   手写逐字出现 → 停留 2s → 自动跳转
   非中文系统自动切换英文版
   ============================================ */

const isZh = (navigator.language || navigator.userLanguage || '').toLowerCase().startsWith('zh');

const WelcomePage = {
  template: `
    <div class="welcome-page" :class="{ 'welcome-page--en': !isZh }">
      <div class="welcome-handwrite">
        <div class="welcome-line1">
          <span
            v-for="(char, i) in line1"
            :key="'a'+i"
            class="welcome-char"
            :class="{ 'welcome-char--big': isZh, 'welcome-char--en': !isZh }"
            :style="{ animationDelay: (i * delay) + 's' }"
          >{{ char }}</span>
        </div>
        <div class="welcome-line2">
          <span
            v-for="(char, j) in line2"
            :key="'b'+j"
            class="welcome-char"
            :class="{ 'welcome-char--en2': !isZh }"
            :style="{ animationDelay: (line1.length + j) * delay + 's' }"
          >{{ char }}</span>
        </div>
      </div>
    </div>
  `,

  data() {
    return {
      isZh,
      line1: isZh ? '路上有光，盟友相伴'.split('') : 'LUMO leads, GUIDE exceeds'.split(''),
      line2: isZh ? '——路盟'.split('') : '-- LUMO'.split(''),
      delay: isZh ? 0.18 : 0.1
    };
  },

  mounted() {
    const totalChars = this.line1.length + this.line2.length;
    const totalDelay = (totalChars - 0.5) * this.delay + 0.65 + 2;
    setTimeout(() => {
      if (UserStore.isLogin) {
        this.$router.replace('/home');
      } else {
        this.$router.replace('/login');
      }
    }, totalDelay * 1000);
  }
};
