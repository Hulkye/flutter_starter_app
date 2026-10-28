#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_PROJECT=""
APP_ARB_DIR="$ROOT_DIR/lib/shared/localization/arb"

cleanup() {
  if [[ -n "$TEMP_PROJECT" ]]; then
    rm -rf "$TEMP_PROJECT"
  fi
}
trap cleanup EXIT

if command -v fvm >/dev/null 2>&1; then
	FLUTTER_CMD=(fvm flutter)
else
	FLUTTER_CMD=(flutter)
fi

generate_feature_l10n() {
  local feature_dir="$1"
  local feature_name="${feature_dir##*/}"
  local arb_dir="$feature_dir/localization/arb"
  local generated_dir="$feature_dir/localization/generated"
  local template_arb
  local expected_arb
  local app_arb
  local locale
  local temp_project
  local output_class
  local output_file
  local word
  local first_char
  local rest
  local -a words
  local -a arb_files
  local -a app_arb_files

  shopt -s nullglob
  arb_files=("$arb_dir"/*.arb)
  shopt -u nullglob
  ((${#arb_files[@]} > 0)) || return 0

  shopt -s nullglob
  app_arb_files=("$APP_ARB_DIR"/app_*.arb)
  shopt -u nullglob
  ((${#app_arb_files[@]} > 0)) || {
    printf '未在 %s 找到 App ARB 文件。\n' "$APP_ARB_DIR" >&2
    return 1
  }
  template_arb=""
  for app_arb in "${app_arb_files[@]}"; do
    locale="${app_arb##*/app_}"
    locale="${locale%.arb}"
    expected_arb="$arb_dir/${feature_name}_${locale}.arb"
    if [[ ! -f "$expected_arb" ]]; then
      printf 'Feature %s 缺少 App locale 对应的 ARB：%s\n' "$feature_name" "$expected_arb" >&2
      return 1
    fi
    if [[ -z "$template_arb" ]]; then
      template_arb="${feature_name}_${locale}.arb"
    fi
  done
  if ((${#arb_files[@]} != ${#app_arb_files[@]})); then
    printf 'Feature %s 的 ARB 数量必须与 App locale 数量一致（%d）。\n' \
      "$feature_name" "${#app_arb_files[@]}" >&2
    return 1
  fi
  IFS='_' read -r -a words <<< "$feature_name"
  output_class=""
  for word in "${words[@]}"; do
    first_char="$(printf '%s' "${word:0:1}" | tr '[:lower:]' '[:upper:]')"
    rest="${word:1}"
    output_class+="$first_char$rest"
  done
  output_class+="Localizations"
  output_file="${feature_name}_localizations.dart"
  TEMP_PROJECT="$(mktemp -d "$ROOT_DIR/build/feature_l10n.XXXXXX")"

  mkdir -p "$TEMP_PROJECT/arb" "$generated_dir"
  cp "${arb_files[@]}" "$TEMP_PROJECT/arb/"

  cat > "$TEMP_PROJECT/pubspec.yaml" <<'EOF'
name: feature_l10n_generation
publish_to: none
environment:
  sdk: ^3.11.4
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: 0.20.2
flutter:
  generate: true
EOF

  cat > "$TEMP_PROJECT/l10n.yaml" <<EOF
arb-dir: arb
template-arb-file: $template_arb
output-dir: lib/src/generated
output-localization-file: $output_file
output-class: $output_class
EOF

  printf '==> 生成 %s Feature 独立 ARB\n' "$feature_name"
  (cd "$TEMP_PROJECT" && "${FLUTTER_CMD[@]}" gen-l10n --project-dir="$TEMP_PROJECT")
  cp "$TEMP_PROJECT/lib/src/generated/"*.dart "$generated_dir/"
  printf '==> %s Feature 国际化代码生成完成\n' "$feature_name"
  rm -rf "$TEMP_PROJECT"
  TEMP_PROJECT=""
}

mkdir -p "$ROOT_DIR/build"
found_feature=false
for feature_dir in "$ROOT_DIR"/lib/features/*; do
  [[ -d "$feature_dir/localization/arb" ]] || continue
  shopt -s nullglob
  arb_files=("$feature_dir/localization/arb"/*.arb)
  shopt -u nullglob
  ((${#arb_files[@]} > 0)) || continue
  found_feature=true
  generate_feature_l10n "$feature_dir"
done

if [[ "$found_feature" == false ]]; then
  echo '没有发现包含 ARB 文件的 Feature，跳过生成。'
fi