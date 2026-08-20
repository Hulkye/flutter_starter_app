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

PACKAGES_DIR="$ROOT_DIR/app_release_packages/android/${VERSION_NAME}"
SYMBOLS_DIR="$PACKAGES_DIR/symbols"

rm -rf "$SYMBOLS_DIR"
mkdir -p "$SYMBOLS_DIR" "$PACKAGES_DIR"

echo "==> 清理 Flutter 构建缓存"
"${FLUTTER_CMD[@]}" clean

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

SYMBOLS_FILE="$(find "$SYMBOLS_DIR" -maxdepth 1 -type f -name '*.symbols' -print -quit)"
if [[ -z "$SYMBOLS_FILE" ]]; then
  echo "未找到 Flutter/Dart 符号表: $SYMBOLS_DIR"
  exit 3
fi

cp -f "$SOURCE_FILE" "$TARGET_FILE"

# 额外收集 R8 混淆映射
MAPPING_FILE="$ROOT_DIR/build/app/outputs/mapping/release/mapping.txt"
if [[ -f "$MAPPING_FILE" ]]; then
  cp -f "$MAPPING_FILE" "$PACKAGES_DIR/mapping.txt"
fi

# 额外收集 Android 原生/NDK 符号
NATIVE_SYMBOLS_FILE="$ROOT_DIR/build/app/outputs/native-debug-symbols/release/native-debug-symbols.zip"
if [[ -f "$NATIVE_SYMBOLS_FILE" ]]; then
  cp -f "$NATIVE_SYMBOLS_FILE" "$PACKAGES_DIR/native-debug-symbols.zip"
fi

echo ""
echo "Android 构建完成:"
echo "  产物: $TARGET_FILE"
echo "  符号: $SYMBOLS_DIR"
echo "  原生符号: $PACKAGES_DIR/native-debug-symbols.zip"
echo "  归档: $PACKAGES_DIR"
