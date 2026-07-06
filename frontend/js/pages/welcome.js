/* ============================================
   WelcomePage — 路盟品牌入口
   旅游行业人士的信息资源交流平台
   ============================================ */

const WelcomePage = {
  template: `
    <div class="welcome-page">
      <!-- Logo -->
      <div class="welcome-logo">
        <img src="/images/logo_lumoguide.png" alt="LuMo Guide" class="welcome-logo-img" />
      </div>

      <!-- Slogan -->
      <p class="welcome-slogan">路上有光，盟友相伴</p>

      <!-- Platform positioning -->
      <p class="welcome-desc">旅游行业人士的<br>信息资源交流平台</p>

      <!-- Role cards -->
      <div class="welcome-roles">
        <div class="welcome-role-card">
          <div class="welcome-role-icon">🧑‍💼</div>
          <div class="welcome-role-name">导游</div>
          <div class="welcome-role-desc">发布城市内容</div>
        </div>
        <div class="welcome-role-card">
          <div class="welcome-role-icon">🏪</div>
          <div class="welcome-role-name">商家</div>
          <div class="welcome-role-desc">管理店铺预约</div>
        </div>
        <div class="welcome-role-card">
          <div class="welcome-role-icon">📝</div>
          <div class="welcome-role-name">创作者</div>
          <div class="welcome-role-desc">分享行业资讯</div>
        </div>
      </div>

      <!-- CTA buttons -->
      <button class="welcome-btn-primary" @click="goLogin">登 录</button>
      <button class="welcome-btn-outline" @click="goRegister">注 册</button>

      <!-- Lock notice -->
      <p class="welcome-lock">
        <span>🔒</span> 已通过身份审核的成员方可进入
      </p>
    </div>
  `,

  methods: {
    goLogin()    { this.$router.push('/login'); },
    goRegister() { this.$router.push('/register'); },
  }
};
