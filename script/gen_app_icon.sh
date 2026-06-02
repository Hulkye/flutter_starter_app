#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_ICON="$ROOT_DIR/assets/app_icon.png"

if [[ ! -f "$APP_ICON" ]]; then
  echo "未找到 app 图标: $APP_ICON"
  echo "请将图标文件放置为 $APP_ICON 后重新执行"
  exit 1
fi

if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
else
  FLUTTER_CMD=(flutter)
fi

echo "==> 生成 App 图标"
"${FLUTTER_CMD[@]}" pub run flutter_launcher_icons

echo "==> App 图标生成完成"
