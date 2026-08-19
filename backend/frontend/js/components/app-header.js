/* ============================================
   AppHeader — Page header with back button
   Mirrors Flutter IAppBar
   ============================================ */

const AppHeader = {
  template: `
    <header class="page-header safe-top">
      <button v-if="showBack" class="back-btn" @click="goBack">
        ← <span>{{ $t('返回') }}</span>
      </button>
      <h1 class="header-title">{{ title }}</h1>
      <div v-if="$slots.right" class="header-right">
        <slot name="right"></slot>
      </div>
    </header>
  `,

  props: {
    title: { type: String, default: '' },
    showBack: { type: Boolean, default: false }
  },

  methods: {
    goBack() {
      if (window.history.length > 1) {
        this.$router.back();
      } else {
        this.$router.push('/home');
      }
    }
  }
};
