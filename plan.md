# LuMo Guide Web 前端实现计划

> 最后更新：2026-07-05 | 当前状态：**Phase 6 完成 ✅** | 参考设计：`PPCC/lumoguide/web` | 已实现：67/67 路由 (100%)

---

## 设计系统 v2（参考 PPCC 设计稿）

以下设计令牌对比当前实现，需要在 Phase 2 开始时统一刷新：

| 令牌 | 当前值 | 参考值 (PPCC) | 变更 |
|------|--------|--------------|------|
| 页面背景 | `#F3F4FA` | `#F9F9F6` | 暖纸白，更有质感 |
| 主色 | `#666FFF` | `#666FFF` | ✅ 保持一致 |
| 主色浅 | `—` | `#EEEDFF` | 新增，用于选中态背景 |
| 文字主色 | `#1A2035` | `#162539` | ink 色，更深沉 |
| 文字次色 | `#5B6278` | `#6B7280` | — |
| 文字弱色 | `#9196A8` | `#9CA3AF` | — |
| 强调色 | `#F2553E/#FF8C52/#F5B842/#3DD68C` | `#EF4444/#F97316/#F59E0B/#10B981/#8B5CF6` | 统一为标准 Tailwind 色板 |
| 圆角-大 | `12px` | `20px` | 更圆润现代 |
| 圆角-小 | `8px` | `12px` | — |
| 展示字体 | `Noto Serif SC` | `Georgia, Noto Serif TC, serif` | 系统优先，中文降级 |
| 阴影 | `0 2px 8px rgba(...)` | `0 1px 3px rgba(0,0,0,.03)` | 更轻柔 |
| Header | 纯色背景 | `rgba(255,255,255,.85)` + `backdrop-filter: blur(16px)` | 毛玻璃效果 |

### 新增 CSS 组件类（参考 `globals.css`）

```
.btn-primary / .card / .input-field / .section-title
.ds-header / .ds-logo / .ds-nav / .ds-tabs / .ds-tab
.ds-type-tabs / .ds-type-tab（圆角药丸 tab）
.ds-card / .ds-card-hover（悬浮上浮效果）
.ds-info-card（横向滚动资讯卡片，300px 宽）
.ds-summary-card（消息摘要三列网格卡片）
.ds-msg / .ds-msg.unread（消息列表项，未读左侧 3px accent 竖线）
.ds-profile-card / .ds-avatar / .ds-stats / .ds-stat
.ds-menu-group / .ds-menu-item / .ds-menu-arrow
.ds-badge（guide/user/company 身份标签）
.ds-empty / .ds-input / .ds-textarea / .ds-btn系列
.ds-container-1280/960/760/600（内容宽度容器）
```

---

## 架构设计

### 导航栏（保持现有方案，融合参考设计）

**当前方案（Phase 0 成果）**：顶部导航栏 inline 在 AppShell 中，支持 tabs/back 两种模式，欢迎/登录/注册页隐藏。

**融合参考设计的改进点**：

1. **Header 毛玻璃效果**：`background: rgba(255,255,255,.85); backdrop-filter: blur(16px) saturate(180%)`
2. **LOGO 使用真实图片**（如果后端提供 `systemLogo` 配置），降级为路盟徽章
3. **桌面端扩展**（Phase 6）：≥860px 时显示搜索图标、消息铃铛（带红点）、用户头像
4. **子页面 header**：参考 `PageHeader` + `BackButton` 模式 — 左箭头 + serif 标题

```
Tab 页面（首页/城市/资讯/消息/我的）：
┌──────────────────────────────────────────────────┐
│ [盟] LUMOGUIDE    首頁  城市  資訊  消息   我的   │  ← 毛玻璃效果
├──────────────────────────────────────────────────┤
│              页面内容区域                          │
└──────────────────────────────────────────────────┘

子页面（详情/表单/设置等）：
┌──────────────────────────────────────────────────┐
│ ← 返回        页面标题（serif 字体）              │  ← 参考 PageHeader
├──────────────────────────────────────────────────┤
│              页面内容区域                          │
└──────────────────────────────────────────────────┘
```

### 页面模板（参考设计提炼）

| 模板 | 结构 | 适用场景 |
|------|------|---------|
| **列表页** | 筛选 tabs（药丸风格 `.ds-type-tab`）→ 卡片网格/列表 → 加载/空/错误 | 搜索结果、消息列表、预约列表等 |
| **详情页** | Banner 图（220px，渐变遮罩+标题）→ 信息卡片 → Tab 内容区 → 底部操作 | 城市/导游/资讯/商品详情 |
| **表单页** | 输入字段（`.ds-input`/`.ds-textarea`）→ 提交按钮 → loading | 资料编辑、发布、认证、地址 |
| **仪表盘** | 统计卡片 → 菜单分组（`.ds-menu-group`）→ 操作入口 | VIP 中心、积分商城、商家管理、设置 |
| **个人中心** | 头像 + 身份标签 + 统计行（关注/粉丝/积分）→ 分组菜单 → 退出登录 | profile |

---

## Phase 0：顶部导航栏 + LOGO ✅

**状态**：已完成

**新建文件**：
- `frontend/js/components/app-topbar.js` — 顶部导航栏组件（未使用，模板 inline 在 app.js）

**修改文件**：
- `frontend/js/app.js` — AppShell inline 顶部导航栏，tabs/back 模式自动切换
- `frontend/js/router.js` — 全部 59 条路由添加 `meta.title`
- `frontend/css/variables.css` — 新增 `--topbar-height: 48px`
- `frontend/css/components.css` — 新增 `.app-topbar` / `.topbar-*` 全套样式
- `frontend/css/app.css` — 移除底部 tab 栏 padding
- `frontend/index.html` — 加载 app-topbar.js

**停用文件**：`frontend/js/components/app-nav.js`（底部 tab 栏，保留不删）

---

## Phase 1：外壳 + 认证 + 5 Tab ✅

**状态**：已完成（Phase 0 之前已实现）

**已实现页面（8 个）**：

| 路由 | 组件 | 说明 |
|------|------|------|
| `/welcome` | WelcomePage | 路盟品牌入口、角色卡片、登录/注册 CTA |
| `/login` | LoginPage | 邮箱密码登录 |
| `/register` | RegisterPage | 邮箱验证码注册 |
| `/home` | HomePage | 首页：搜索、城市攻略、热门城市、导游、商家、资讯 |
| `/city` | CityPage | 城市列表（大洲分类 tab） |
| `/news` | NewsPage | 资讯列表（分类筛选） |
| `/message` | MessagePage | 消息中心（5 类通知） |
| `/mine` | MinePage | 个人中心：资料、VIP、服务菜单 |

---

## Phase 2：详情页 + 设计系统刷新（14 个页面）

**状态**：✅ 完成 (2026-07-05)

### 2.0 设计系统刷新 ✅

**状态**：已完成 (2026-07-05)

1. `frontend/css/variables.css` ✅ — 更新色板（`#F9F9F6` / `#162539`）、圆角（20px/12px）、阴影（轻柔）、字体栈（`--font-serif` / `--font-sans`）、Tailwind 强调色
2. `frontend/css/components.css` ✅ — 新增全套 `.ds-*` 组件类（header/nav/tabs/type-tabs/card/carousel/hero-search/strategy-card/message/profile/menu/form/button/list/empty）+ 毛玻璃 `.app-topbar`
3. `frontend/css/app.css` ✅ — 新增加 `.ds-container-*` 容器类、`.ds-page-head`、`.ds-subpage`、`.ds-section`、`.ds-section-head`
4. `frontend/index.html` ✅ — 预加载画面更新为新配色、新增 Noto Serif TC 字体

### 2.1 详情页列表

| # | 路由 | 参考路由 | 模板 | 文件 | 调用的 API |
|---|------|---------|------|------|-----------|
| 1 | `/city/detail` | `/cities/[id]` | 详情页 | `frontend/js/pages/city/detail.js` | `cityInfo`, `cityClass`, `cityGuide`, `cityContent` |
| 2 | `/city/strategy` | `/city-strategy` | 列表页 | `frontend/js/pages/city/strategy.js` | `cityContentList`（按类型筛选） |
| 3 | `/city/guide-list` | `/cities/[id]/guides` | 列表页 | `frontend/js/pages/city/guide-list.js` | `cityGuide` |
| 4 | `/guide/:id` | `/guides/[id]` | 详情页 | `frontend/js/pages/guide/detail.js` | `guideInfo`, `cityGuideInfo` |
| 5 | `/detail/:type` | `/cities/[id]/content/[contentId]` | 详情页 | `frontend/js/pages/common/detail.js` | `cityContentInfo` |
| 6 | `/company/:id` | — | 详情页 | `frontend/js/pages/company/detail.js` | `companyInfo`（如 API 存在） |
| 7 | `/news/:id` | `/news/[id]` | 详情页 | `frontend/js/pages/news/detail.js` | `newsInfo`, `newsEvaluate` |
| 8 | `/search` | `/search` | 列表页 | `frontend/js/pages/search/index.js` | `homeSearch` |
| 9 | `/message/system` | `/messages` (合并) | 列表页 | `frontend/js/pages/message/system.js` | `messageSystem` |
| 10 | `/message/follow` | `/messages` (合并) | 列表页 | `frontend/js/pages/message/follow.js` | `messageFollow` |
| 11 | `/message/comments` | `/messages` (合并) | 列表页 | `frontend/js/pages/message/comments.js` | `messageEvaluate` |
| 12 | `/message/reserves` | `/messages` (合并) | 列表页 | `frontend/js/pages/message/reserves.js` | `messageReserve` |
| 13 | `/evaluation/:id` | `/profile/evaluations` | 详情页 | `frontend/js/pages/evaluation/detail.js` | `evaluateDetail` |
| 14 | `/evaluate-list/:id` | `/profile/evaluations` | 列表页 | `frontend/js/pages/evaluation/list.js` | `evaluateList` |

### 2.2 关键设计参考

**城市详情页**（参考 `cities/[id]/page.tsx`）：
- Banner 图 220px，渐变遮罩，城市名+英文名叠在图上
- 10 个 Tab（概览/导游/景点/餐厅/购物/住宿/交通/设施/活动/票务），underline 风格
- 概览 Tab：信息卡片（货币/语言/人口/种族）+ 城市概述 + 历史
- 内容 Tab：子分类药丸 tab + 卡片网格

**资讯详情页**（参考 `news/[id]/page.tsx`）：
- 标题 serif 字体
- 作者信息行（头像+昵称+城市+关注按钮）
- 正文内容 + 图片
- 底部评价列表

**搜索页**（参考 `search/page.tsx`）：
- 搜索输入框（带搜索按钮，focus 时 accent 发光）
- 结果 Tab：城市/导游/内容
- 卡片网格展示

### 2.3 共享组件（本 Phase 创建）

- `frontend/js/components/page-header.js` — 返回按钮 + serif 标题
- `frontend/js/components/back-button.js` — chevron-left SVG 图标按钮
- `frontend/js/components/type-tabs.js` — 药丸风格分类 tab（`.ds-type-tab`）
- `frontend/js/components/banner-carousel.js` — 图片轮播（进度点+自动播放）
- `frontend/js/components/star-rating.js` — 星级评价展示

---

## Phase 3：用户操作（18 个页面）

**状态**：⬜ 待开始

对比参考设计后，Phase 3 从 15 页增加到 18 页（新增 followers、following、evaluations、privacy、avatar 相关，合并 nickname 到 edit）。

| # | 路由 | 参考路由 | 模板 | 文件 | 说明 |
|---|------|---------|------|------|------|
| 1 | `/forget-password` | `/auth/forgot-password` | 表单 | `frontend/js/pages/auth/forget-password.js` | 忘记密码—输入邮箱 |
| 2 | `/verify-code` | — | 表单 | `frontend/js/pages/auth/verify-code.js` | 验证码输入 |
| 3 | `/password-input` | — | 表单 | `frontend/js/pages/auth/password-input.js` | 设置新密码 |
| 4 | `/profile` | `/profile` | 仪表盘 | `frontend/js/pages/mine/profile.js` | 🆕 重构为参考风格：头像+身份标签+统计行+分组菜单 |
| 5 | `/settings` | `/profile/settings` | 仪表盘 | `frontend/js/pages/mine/settings.js` | 语言切换/隐私政策/清除缓存 |
| 6 | `/profile/edit` | `/profile/edit` | 表单 | `frontend/js/pages/mine/edit-profile.js` | 🆕 编辑资料（头像/昵称/手机，参考 design） |
| 7 | `/modify-phone` | `/profile/edit/phone` | 表单 | `frontend/js/pages/mine/modify-phone.js` | 修改手机号 |
| 8 | `/modify-password` | `/profile/edit/password` | 表单 | `frontend/js/pages/mine/modify-password.js` | 修改密码 |
| 9 | `/feedback` | `/profile/feedback` | 表单 | `frontend/js/pages/mine/feedback.js` | 意见反馈 |
| 10 | `/contact` | `/profile/contact` | 仪表盘 | `frontend/js/pages/mine/contact.js` | 联系客服 |
| 11 | `/invite` | `/profile/invite` | 仪表盘 | `frontend/js/pages/mine/invite.js` | 邀请好友 + 邀请记录 |
| 12 | `/my-bookings` | `/profile/bookings` | 列表 | `frontend/js/pages/mine/my-bookings.js` | 🆕 参考 booking 页：导游/商家双 tab + 状态筛选 |
| 13 | `/booking-detail/:type/:id` | `/profile/bookings/guide/[id]` 等 | 详情 | `frontend/js/pages/mine/booking-detail.js` | 🆕 预约详情 |
| 14 | `/address` | `/profile/addresses` | 列表 | `frontend/js/pages/address/list.js` | 地址列表 |
| 15 | `/address/edit` | `/profile/addresses/add` | 表单 | `frontend/js/pages/address/edit.js` | 新增/编辑地址 |
| 16 | `/followers` | `/profile/followers` | 列表 | `frontend/js/pages/mine/followers.js` | 🆕 粉丝列表 |
| 17 | `/following` | `/profile/following` | 列表 | `frontend/js/pages/mine/following.js` | 🆕 关注列表 |
| 18 | `/evaluations` | `/profile/evaluations` | 列表 | `frontend/js/pages/mine/evaluations.js` | 🆕 我的评价列表 |

---

## Phase 4：发布功能（12 个页面）

**状态**：✅ 完成 (2026-07-05)

| # | 路由 | 参考路由 | 模板 | 文件 | 说明 |
|---|------|---------|------|------|------|
| 1 | `/guide/certify` | `/guide-panel/apply` | 表单 | `frontend/js/pages/guide/certify.js` | 导游认证申请（3步向导） |
| 2 | `/guide/publish` | `/profile/my-publish` | 列表 | `frontend/js/pages/guide/publish.js` | 我的发布列表（5 Tab + 编辑/删除） |
| 3 | `/guide/publish-city` | `/guide-panel/cities` | 列表+表单 | `frontend/js/pages/guide/publish-city.js` | 我的城市 + 新增/删除 |
| 4 | `/guide/bookings` | `/guide-panel/bookings` | 列表 | `frontend/js/pages/guide/bookings.js` | 导游预约管理（日期+状态筛选，确认/拒绝快速操作） |
| 5 | `/guide/booking-detail/:id` | `/guide-panel/bookings/[id]` | 详情 | `frontend/js/pages/guide/bookings.js` | 预约详情（导游视角，确认/拒绝/完成操作） |
| 6 | `/guide/change-city` | — | 列表 | `frontend/js/pages/guide/change-city.js` | 切换服务城市（当前高亮） |
| 7 | `/publish/attraction` | `/guide-panel/publish/attraction` | 表单 | `frontend/js/pages/publish/form.js` | 发布景点 |
| 8 | `/publish/transportation` | `/guide-panel/publish/transportation` | 表单 | `frontend/js/pages/publish/form.js` | 发布交通 |
| 9 | `/publish/facility` | `/guide-panel/publish/facility` | 表单 | `frontend/js/pages/publish/form.js` | 发布设施 |
| 10 | `/publish/activity` | `/guide-panel/publish/activity` | 表单 | `frontend/js/pages/publish/form.js` | 发布活动（含开始时间） |
| 11 | `/publish/information` | `/guide-panel/publish/information` | 表单 | `frontend/js/pages/publish/form.js` | 发布资讯（含标题+正文） |
| 12 | `/merchant/entry` | `/company-panel/apply` | 表单 | `frontend/js/pages/merchant/entry.js` | 商家入驻（4步向导） |

**新增文件（7 个）**：guide/certify.js, guide/publish.js, guide/publish-city.js, guide/bookings.js（含 GuideBookingsPage + GuideBookingDetailPage）, guide/change-city.js, publish/form.js（5 组件共享工厂函数）, merchant/entry.js。发布表单合并到 `publish/form.js` 使用 `createPublishPage()` 工厂函数。

---

## Phase 5：电商功能（13 个页面）

**状态**：✅ 完成 (2026-07-05)

对比参考设计后，增加 points 子页面和 exchange 流程页面。

| # | 路由 | 参考路由 | 模板 | 文件 | 说明 |
|---|------|---------|------|------|------|
| 1 | `/integral` | `/points` | 仪表盘 | `frontend/js/pages/integral/index.js` | 🆕 积分商城首页（渐变色余额卡+分类tab+商品网格） |
| 2 | `/integral/mall` | — | 列表 | `frontend/js/pages/integral/mall.js` | 积分商城（合并到 index） |
| 3 | `/integral/goods/:id` | `/points/[id]` | 详情 | `frontend/js/pages/integral/goods-detail.js` | 商品详情 |
| 4 | `/integral/exchange/:id` | `/points/exchange/[id]` | 表单 | `frontend/js/pages/integral/exchange.js` | 积分兑换确认 |
| 5 | `/integral/exchange/result` | `/points/exchange/result` | 结果 | `frontend/js/pages/integral/exchange-result.js` | 🆕 兑换结果页 |
| 6 | `/integral/exchange/order/:id` | `/points/exchange/order/[id]` | 详情 | `frontend/js/pages/integral/exchange-order.js` | 🆕 兑换订单详情 |
| 7 | `/integral/records` | `/profile/points/records` | 列表 | `frontend/js/pages/integral/records.js` | 🆕 积分记录 |
| 8 | `/vip` | `/vip` | 仪表盘 | `frontend/js/pages/vip/index.js` | VIP 会员中心 |
| 9 | `/booking-guide/:id` | `/booking/guide/[id]` | 表单 | `frontend/js/pages/booking/guide.js` | 预约导游 |
| 10 | `/booking-merchant/:id` | `/booking/merchant/[id]` | 表单 | `frontend/js/pages/booking/merchant.js` | 预约商家 |
| 11 | `/merchant/manage` | `/company-panel/shops` | 仪表盘 | `frontend/js/pages/merchant/manage.js` | 🆕 店铺管理（含 add/edit 子功能） |
| 12 | `/merchant/bookings` | `/company-panel/bookings` | 列表 | `frontend/js/pages/merchant/bookings.js` | 商家预约管理 |
| 13 | `/merchant/booking-detail/:id` | `/company-panel/bookings/[id]` | 详情 | `frontend/js/pages/merchant/booking-detail.js` | 🆕 预约详情（商家视角） |

---

## Phase 6：打磨收尾（2 个页面）✅

**状态**：✅ 完成 (2026-07-05)

| # | 路由 | 参考路由 | 文件 | 说明 |
|---|------|---------|------|------|
| 1 | `/photo` | `/photo-view` | `frontend/js/pages/misc/photo.js` | 全屏图片查看器（深色背景、多图导航、键盘快捷键、关闭提示） |
| 2 | `/web` | — | `frontend/js/pages/misc/web.js` | 内嵌网页（iframe + 标题栏 + 加载状态 + 浏览器打开降级） |

### Phase 6 细节
- **PhotoViewerPage**：支持单图 (url) 和多图 (urls JSON + index)，prev/next 导航按钮，键盘 Escape/←/→ 快捷键，加载/错误/重试状态，阻止 body 滚动，毛玻璃关闭按钮
- **WebViewPage**：自定义 header（返回 + 标题 + 关闭），iframe sandbox，15s 安全超时，加载/错误/重试/浏览器打开降级
- **previewImage 迁移**：`common/details.js`（3处）和 `news/detail.js`（1处）从 `window.open(url, '_blank')` 改为 `this.$router.push('/photo?url=...')`

### 全局优化项（后续迭代）
- 设计系统统一、首页/消息/个人中心重构
- 所有列表页：下拉刷新 + 无限滚动
- 主要列表页：骨架屏替代 loading spinner
- 响应式：`max-width` 容器（600/760/960/1280px），≥860px 桌面端优化

---

## 实施依赖关系

```
Phase 0 ──→ Phase 2.0（设计系统刷新）──→ Phase 2.1（详情页）
                                        ──→ Phase 3（用户操作）
                                        ──→ Phase 4（发布功能）✅
                                        ──→ Phase 5（电商功能）
                                                                     ──→ Phase 6（打磨）
```

Phase 3 和 Phase 4 可并行开发。Phase 4 已完成 ✅，Phase 5 已完成 ✅。

---

## 文件统计（更新后）

| 类别 | 原计划 | 更新后 | 变化 |
|------|--------|--------|------|
| 总路由 | 59 | 67 | Phase 4-5 新增 `/guide/booking-detail`,`/integral/exchange/*`,`/integral/records`,`/merchant/booking-detail` 等 |
| 已实现（Phase 0-6） | 40 | **67** | +27（Phase 4: 12, Phase 5: 13, Phase 6: 2） |
| 待实现 | 19 | **0** | 全部完成 🎉 |
| 新建页面文件（Phase 4-6） | — | 17 | guide/* (5), publish/form.js, merchant/* (3), integral/* (4), vip/index.js, booking/form.js, misc/* (2) |

---

## 验证基准

每个 Phase 完成后验证：

1. `node --check` — 全部 JS 文件语法检查
2. `curl http://localhost:8000/#/[route]` — 路由 HTTP 200
3. 浏览器逐个路由检查：
   - 顶部导航栏 LOGO 始终可见
   - Tab 切换正常 / 返回按钮工作
   - 加载状态 → 数据展示 → 空状态 → 错误重试 全部覆盖
   - 设计风格与参考稿一致（暖白背景、毛玻璃 header、serif 标题）

---

## 参考设计文件索引

| 参考文件 | 对应页面 | 用途 |
|---------|---------|------|
| `design/01-home.html` | 首页 | Hero 区、分类攻略网格、城市分组、资讯列表 |
| `design/02-cities.html` | 城市列表+详情 | 侧边栏、卡片网格、Tab 导航 |
| `design/03-news.html` | 资讯列表+详情 | 列表布局、详情页排版 |
| `design/04-messages.html` | 消息中心 | 摘要卡片网格、消息列表、弹窗详情 |
| `design/05-profile.html` | 个人中心 | Profile card、统计行、分组菜单、退出登录 |
| `src/app/page.tsx` | 首页 | 完整实现参考（Hero+搜索+城市+导游轮播+商家Banner+资讯） |
| `src/app/cities/page.tsx` | 城市列表 | 侧边栏+内容区布局、手机版 tab |
| `src/app/cities/[id]/page.tsx` | 城市详情 | Banner+10Tab+子分类+内容网格 |
| `src/app/messages/page.tsx` | 消息 | 分类网格+摘要卡片+系统消息+弹窗 |
| `src/app/profile/page.tsx` | 个人中心 | Profile card+stats+分组菜单 |
| `src/app/profile/bookings/page.tsx` | 我的预约 | 导游/商家 tab+状态筛选+操作按钮 |
| `src/app/points/page.tsx` | 积分商城 | 余额渐变卡+分类+商品网格 |
| `src/lib/api/client.ts` | API 层 | 完整的 endpoints 清单（290+ 端点） |
| `src/lib/types/index.ts` | 数据模型 | TypeScript 类型定义（对应 Flutter models） |

> 参考项目位置：`/Users/guanpei/Downloads/PPCC/lumoguide/web/`（Next.js + Tailwind CSS）
