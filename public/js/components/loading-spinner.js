/* ============================================
   LoadingSpinner — Loading indicator
   ============================================ */

const LoadingSpinner = {
  template: `
    <div class="loading-container">
      <div>
        <div class="spinner"></div>
        <p v-if="text" class="loading-text">{{ text }}</p>
      </div>
    </div>
  `,

  props: {
    text: { type: String, default: '' }
  }
};
