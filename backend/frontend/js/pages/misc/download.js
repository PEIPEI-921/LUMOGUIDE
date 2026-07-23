/* ============================================
   AppDownloadPage — QR code download page
   Route: /download
   ============================================ */

const AppDownloadPage = {
  template: `
    <div class="page-content">
      <div class="ds-container-600" style="padding-top:48px">
        <div class="ds-page-head" style="text-align:center">
          <h1>{{ $t('下載LUMO Guide App') }}</h1>
        </div>

        <div class="download-qr-grid">
          <!-- iOS -->
          <div class="download-qr-card">
            <div class="download-qr-img-box">
              <!-- Replace src with actual iOS QR code image -->
              <div class="download-qr-placeholder">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" opacity="0.35">
                  <rect x="3" y="3" width="7" height="7" rx="1.2"/>
                  <rect x="14" y="3" width="7" height="7" rx="1.2"/>
                  <rect x="3" y="14" width="7" height="7" rx="1.2"/>
                  <path d="M14 14h3v3h-3zM18 14h3v3h-3zM14 18h3v3h-3zM18 18h3v3h-3z"/>
                </svg>
                <span>QR Code</span>
              </div>
            </div>
            <div class="download-platform-icon">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.02.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
            </div>
            <div class="download-platform-name">App Store</div>
            <div class="download-platform-desc">{{ $t('掃碼下載iOS版') }}</div>
          </div>

          <!-- Android -->
          <div class="download-qr-card">
            <div class="download-qr-img-box">
              <!-- Replace src with actual Android QR code image -->
              <div class="download-qr-placeholder">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" opacity="0.35">
                  <rect x="3" y="3" width="7" height="7" rx="1.2"/>
                  <rect x="14" y="3" width="7" height="7" rx="1.2"/>
                  <rect x="3" y="14" width="7" height="7" rx="1.2"/>
                  <path d="M14 14h3v3h-3zM18 14h3v3h-3zM14 18h3v3h-3zM18 18h3v3h-3z"/>
                </svg>
                <span>QR Code</span>
              </div>
            </div>
            <div class="download-platform-icon">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.792 12 3.609 22.186c-.213.213-.35.357-.456.357-.106 0-.153-.05-.153-.153V1.603c0-.1.05-.153.153-.153.106 0 .243.144.456.364zm.971-.814L17.03 10.31c.346.232.52.501.52.807 0 .306-.174.575-.52.807L4.58 22.993c-.42.284-.763.333-1.03.147-.266-.187-.398-.494-.398-.922V1.807c0-.426.132-.727.398-.913.267-.186.61-.137 1.03.106zM19.974 12L14.28 8.67v6.66L19.974 12zm2.127-.752c.42.286.63.633.63 1.043 0 .41-.21.757-.63 1.043l-2.133 1.448-2.14-1.47 2.14-1.47 2.133 1.449v-.043z"/></svg>
            </div>
            <div class="download-platform-name">Google Play</div>
            <div class="download-platform-desc">{{ $t('掃碼下載Android版') }}</div>
          </div>
        </div>

        <!-- Direct download links -->
        <div class="download-links">
          <a class="download-link-btn" href="#" target="_blank" rel="noopener">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.02.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
            <span>App Store</span>
          </a>
          <a class="download-link-btn" href="#" target="_blank" rel="noopener">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M3.609 1.814L13.792 12 3.609 22.186c-.213.213-.35.357-.456.357-.106 0-.153-.05-.153-.153V1.603c0-.1.05-.153.153-.153.106 0 .243.144.456.364zm.971-.814L17.03 10.31c.346.232.52.501.52.807 0 .306-.174.575-.52.807L4.58 22.993c-.42.284-.763.333-1.03.147-.266-.187-.398-.494-.398-.922V1.807c0-.426.132-.727.398-.913.267-.186.61-.137 1.03.106zM19.974 12L14.28 8.67v6.66L19.974 12zm2.127-.752c.42.286.63.633.63 1.043 0 .41-.21.757-.63 1.043l-2.133 1.448-2.14-1.47 2.14-1.47 2.133 1.449v-.043z"/></svg>
            <span>Google Play</span>
          </a>
        </div>

        <div class="download-note">{{ $t('若無法掃碼，請點擊上方按鈕直接下載') }}</div>
      </div>
    </div>
  `,

  mounted() {
    document.title = this.$t('下載LUMO Guide App');
  }
};
