#!/usr/bin/env bash
# =============================================================================
# Flutter 移动端测试 runner
#
# 用途：运行 mobile/ 应用的 Flutter 单元/组件测试（mobile/test/ 下已有用例）。
# 运行：bash tests/mobile/run.sh            # 全部测试
#       bash tests/mobile/run.sh test/api_result_test.dart   # 单个文件
#
# 注意：首次运行会 pub get 拉取依赖（走国内镜像），耗时较长。
# =============================================================================
set -e

export PATH="/opt/flutter/bin:$PATH"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

cd "$(dirname "$0")/../../mobile"

echo "== Flutter 版本 =="
flutter --version | head -2

if [ $# -gt 0 ]; then
  flutter test "$@"
else
  flutter test
fi
