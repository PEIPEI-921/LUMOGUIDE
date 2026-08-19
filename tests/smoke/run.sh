#!/usr/bin/env bash
# =============================================================================
# LUMOGUIDE 线上冒烟测试（只读，无副作用）
#
# 用途：每次部署/改代码后运行，快速确认线上站点核心链路正常。
# 运行：bash tests/smoke/run.sh
# 可选环境变量：
#   SMOKE_BASE_URL  默认 https://api.lumoguide.com
#   SMOKE_VERBOSE=1 显示失败响应内容
#
# 设计原则：全部为 GET 或无效凭据 POST，不产生任何数据变更。
# =============================================================================
set -u

BASE="${SMOKE_BASE_URL:-https://api.lumoguide.com}"
PASS=0
FAIL=0
FAILED=()

log_pass() { echo "  PASS  [$1] $2"; PASS=$((PASS + 1)); }
log_fail() { echo "  FAIL  [$1] $2 (期望 $3${4:+，匹配 }${4:-})"; FAIL=$((FAIL + 1)); FAILED+=("$2"); }

# check <名称> <方法> <路径> <期望状态码> [grep 内容]
check() {
  local name="$1" method="$2" path="$3" expect="$4" grep_for="${5:-}"
  local out code body
  out=$(curl -sk -m 20 -X "$method" -w $'\n%{http_code}' "$BASE$path" 2>/dev/null)
  code=$(echo "$out" | tail -1)
  body=$(echo "$out" | sed '$d')
  if [ "$code" = "$expect" ] && { [ -z "$grep_for" ] || echo "$body" | grep -q "$grep_for"; }; then
    log_pass "$code" "$name"
  else
    log_fail "$code" "$name" "$expect" "$grep_for"
    if [ "${SMOKE_VERBOSE:-0}" = "1" ]; then echo "$body" | head -c 500; echo; fi
  fi
}

echo "== LUMOGUIDE 线上冒烟测试 =="
echo "目标: $BASE"
echo

echo "-- 页面与静态资源 --"
check "首页" GET "/" 200
check "SPA 静态入口 index.html" GET "/index.html" 200
HSTS=$(curl -skI -m 20 "$BASE/" | grep -i "strict-transport-security")
if [ -n "$HSTS" ]; then
  log_pass "200" "HSTS 安全头存在（响应头）"
else
  log_fail "200" "HSTS 安全头存在（响应头）" "strict-transport-security"
fi

# 从首页提取构建 bundle hash，验证构建产物真实存在且可下载
BUNDLE_JS=$(curl -sk -m 20 "$BASE/" | grep -oE '/dist/js/app\.bundle\.[a-f0-9]+\.js' | head -1)
BUNDLE_CSS=$(curl -sk -m 20 "$BASE/" | grep -oE '/dist/css/app\.bundle\.[a-f0-9]+\.css' | head -1)
if [ -n "$BUNDLE_JS" ]; then
  check "前端 JS bundle 可访问 ($BUNDLE_JS)" GET "$BUNDLE_JS" 200
else
  log_fail "-" "首页未引用 dist bundle（可能构建失败或被替换为源文件）" 200
fi
if [ -n "$BUNDLE_CSS" ]; then
  check "前端 CSS bundle 可访问 ($BUNDLE_CSS)" GET "$BUNDLE_CSS" 200
else
  log_fail "-" "首页未引用 dist CSS bundle" 200
fi

echo
echo "-- 公开 API（读）--"
check "健康检查 /api/health" GET "/api/health" 200 '"code":200'
check "应用配置 /api/common/config" GET "/api/common/config" 200
check "洲列表 /api/common/getContinents" GET "/api/common/getContinents" 200
check "导游列表 /api/common/guideList" GET "/api/common/guideList" 200
check "商户列表 /api/common/merchantList" GET "/api/common/merchantList" 200
check "城市列表 /api/city/lists" GET "/api/city/lists" 200
check "城市选项 /api/city/options" GET "/api/city/options" 200
check "资讯列表 /api/information/lists" GET "/api/information/lists" 200
check "多语言数据 /api/data/zh" GET "/api/data/zh" 200

echo
echo "-- 用户上传文件（storage 软链）--"
UPLOAD_FILE=$(find /www/wwwroot/lumo_new/backend/storage/app/public/uploads -type f 2>/dev/null | tr -d '\0' | head -1)
if [ -n "$UPLOAD_FILE" ]; then
  UPLOAD_URL="${UPLOAD_FILE#/www/wwwroot/lumo_new/backend/storage/app/public}"
  check "上传文件可访问 /storage$UPLOAD_URL" GET "/storage$UPLOAD_URL" 200
else
  log_fail "-" "uploads 目录中未找到样本文件" 200
fi

echo
echo "-- 错误处理与安全 --"
check "无效 API 路径返回 404（已知行为）" GET "/api/does-not-exist-xyz" 404
check ".env 不可访问" GET "/.env" 404
check "管理端 /manage 可到达（未登录 302 跳登录页）" GET "/manage" 302

echo
echo "-- 认证（无效凭据，无副作用）--"
AUTH_BODY=$(curl -sk -m 20 -X POST -H "Content-Type: application/json" \
  -d '{"email":"smoke-nonexistent@example.com","password":"wrong-pass"}' "$BASE/api/auth/login")
if echo "$AUTH_BODY" | grep -q '"code"' && ! echo "$AUTH_BODY" | grep -q '"code":200'; then
  log_pass "200" "无效登录被正确拒绝（返回业务错误码）"
else
  log_fail "?" "无效登录被正确拒绝" "业务错误码"
fi
PROTECTED=$(curl -sk -m 20 "$BASE/api/user/index")
if [ "$(echo "$PROTECTED" | grep -o '"code":[0-9]*' | head -1)" = '"code":401' ]; then
  log_pass "200" "未带 token 访问受保护接口返回业务码 401"
else
  log_fail "200" "未带 token 访问受保护接口返回业务码 401" '"code":401'
fi

echo
echo "======================================"
echo "结果: $PASS 通过, $FAIL 失败"
if [ "$FAIL" -gt 0 ]; then
  echo "失败项:"
  printf '  - %s\n' "${FAILED[@]}"
  exit 1
fi
echo "全部通过 ✓"
exit 0
