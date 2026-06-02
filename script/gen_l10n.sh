#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f "$ROOT_DIR/l10n.yaml" ]]; then
	echo "未找到 l10n.yaml: $ROOT_DIR/l10n.yaml"
	exit 1
fi

if command -v fvm >/dev/null 2>&1; then
	FLUTTER_CMD=(fvm flutter)
else
	FLUTTER_CMD=(flutter)
fi

echo "==> 生成 Flutter 国际化代码"
"${FLUTTER_CMD[@]}" gen-l10n

echo "==> 国际化代码生成完成"
