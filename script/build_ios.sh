#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
else
  FLUTTER_CMD=(flutter)
fi

PUBSPEC_FILE="$ROOT_DIR/pubspec.yaml"
APP_NAME="$(awk -F': ' '/^name:/{print $2; exit}' "$PUBSPEC_FILE")"
VERSION_RAW="$(awk -F': ' '/^version:/{print $2; exit}' "$PUBSPEC_FILE")"
VERSION_NAME="${VERSION_RAW%%+*}"

PACKAGES_DIR="$ROOT_DIR/app_release_packages/ios/${VERSION_NAME}"
SYMBOLS_DIR="$PACKAGES_DIR/symbols"
EXPORT_DIR="$ROOT_DIR/build/ios/ipa"
ARCHIVE_DIR="$ROOT_DIR/build/ios/archive/Runner.xcarchive"

generate_missing_objective_c_dsym() {
  local framework_binary="$ARCHIVE_DIR/Products/Applications/Runner.app/Frameworks/objective_c.framework/objective_c"
  local dsym_path="$ARCHIVE_DIR/dSYMs/objective_c.framework.dSYM"

  if [[ ! -f "$framework_binary" || -d "$dsym_path" ]]; then
    return
  fi

  echo "==> 补齐 objective_c.framework.dSYM"
  mkdir -p "$ARCHIVE_DIR/dSYMs"
  dsymutil "$framework_binary" -o "$dsym_path"
}

rm -rf "$SYMBOLS_DIR"
mkdir -p "$SYMBOLS_DIR" "$PACKAGES_DIR"

echo "==> Flutter 依赖拉取"
"${FLUTTER_CMD[@]}" pub get

echo "==> 开始构建 iOS IPA（release + 混淆 + 压缩）"
"${FLUTTER_CMD[@]}" build ipa --release --obfuscate --split-debug-info="$SYMBOLS_DIR"

generate_missing_objective_c_dsym

shopt -s nullglob
ipa_candidates=("$EXPORT_DIR"/*.ipa)
shopt -u nullglob
if [[ ${#ipa_candidates[@]} -eq 0 ]]; then
  echo "未找到 IPA 产物: $EXPORT_DIR"
  exit 2
fi
IPA_FILE="${ipa_candidates[0]}"

TARGET_IPA="$PACKAGES_DIR/${APP_NAME}_v${VERSION_NAME}_release.ipa"
cp -f "$IPA_FILE" "$TARGET_IPA"

# 收集 iOS dSYM（若存在）
DSYM_DIR="$ARCHIVE_DIR/dSYMs"
if [[ -d "$DSYM_DIR" ]]; then
  cp -R "$DSYM_DIR" "$PACKAGES_DIR/dSYMs"
fi

echo ""
echo "iOS 构建完成:"
echo "  产物: $TARGET_IPA"
echo "  符号: $SYMBOLS_DIR"
echo "  归档: $PACKAGES_DIR"
