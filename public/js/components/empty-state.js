/* ============================================
   EmptyState — No data placeholder
   Mirrors Flutter EmptyWidget / EmptyListWidget
   ============================================ */

const EmptyState = {
  template: `
    <div class="empty-state">
      <div class="empty-icon">📭</div>
      <p class="empty-text">{{ text || $t('暫無記錄') }}</p>
      <button v-if="retry" class="btn-outline mt-md" @click="$emit('retry')">
        {{ $t('點擊重試') }}
      </button>
    </div>
  `,

  props: {
    text: { type: String, default: '' },
    retry: { type: Boolean, default: false }
  },

  emits: ['retry']
};
