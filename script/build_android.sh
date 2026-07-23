#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUILD_TYPE="${1:-apk}" # apk | aab
if [[ "$BUILD_TYPE" != "apk" && "$BUILD_TYPE" != "aab" ]]; then
  echo "用法: ./script/build_android.sh [apk|aab]"
  exit 1
fi

if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
else
  FLUTTER_CMD=(flutter)
fi

PUBSPEC_FILE="$ROOT_DIR/pubspec.yaml"
APP_NAME="$(awk -F': ' '/^name:/{print $2; exit}' "$PUBSPEC_FILE")"
VERSION_RAW="$(awk -F': ' '/^version:/{print $2; exit}' "$PUBSPEC_FILE")"
VERSION_NAME="${VERSION_RAW%%+*}"

SYMBOLS_BASE_DIR="$ROOT_DIR/symbols/android"
SYMBOLS_DIR="$SYMBOLS_BASE_DIR/${VERSION_NAME}"
PACKAGES_DIR="$ROOT_DIR/app_release_packages/android/${VERSION_NAME}"

rm -rf "$SYMBOLS_DIR"
mkdir -p "$SYMBOLS_DIR" "$PACKAGES_DIR"

echo "==> Flutter 依赖拉取"
"${FLUTTER_CMD[@]}" pub get

echo "==> 开始构建 Android ${BUILD_TYPE} (release + 混淆 + 压缩)"
if [[ "$BUILD_TYPE" == "apk" ]]; then
  "${FLUTTER_CMD[@]}" build apk --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
  SOURCE_FILE="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
  TARGET_FILE="$PACKAGES_DIR/${APP_NAME}_v${VERSION_NAME}_release.apk"
else
  "${FLUTTER_CMD[@]}" build appbundle --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
  SOURCE_FILE="$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab"
  TARGET_FILE="$PACKAGES_DIR/${APP_NAME}_v${VERSION_NAME}_release.aab"
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "未找到构建产物: $SOURCE_FILE"
  exit 2
fi

cp -f "$SOURCE_FILE" "$TARGET_FILE"

# 额外收集 R8 混淆映射
MAPPING_FILE="$ROOT_DIR/build/app/outputs/mapping/release/mapping.txt"
if [[ -f "$MAPPING_FILE" ]]; then
  cp -f "$MAPPING_FILE" "$PACKAGES_DIR/mapping.txt"
fi

# 在打包目录内保留一份符号表
cp -R "$SYMBOLS_DIR" "$PACKAGES_DIR/symbols"

echo ""
echo "Android 构建完成:"
echo "  产物: $TARGET_FILE"
echo "  符号: $SYMBOLS_DIR"
echo "  归档: $PACKAGES_DIR"
