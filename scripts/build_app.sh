#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
configuration="${CONFIGURATION:-release}"
output_dir="${OUTPUT_DIR:-${project_dir}/.artifacts}"
app_path="${output_dir}/QuotaGlow.app"
plist_path="${app_path}/Contents/Info.plist"

cd "${project_dir}"
swift build -c "${configuration}" --product QuotaGlow
bin_dir="$(swift build -c "${configuration}" --show-bin-path)"

rm -rf "${app_path}"
mkdir -p "${app_path}/Contents/MacOS" "${app_path}/Contents/Frameworks"
ditto "${bin_dir}/QuotaGlow" "${app_path}/Contents/MacOS/QuotaGlow"
ditto "${project_dir}/Info.plist" "${plist_path}"
if [[ -f "${project_dir}/Resources/AppIcon.icns" ]]; then
  mkdir -p "${app_path}/Contents/Resources"
  ditto "${project_dir}/Resources/AppIcon.icns" "${app_path}/Contents/Resources/AppIcon.icns"
fi

sparkle_framework="$(find "${bin_dir}" "${project_dir}/.build/artifacts" -type d -name Sparkle.framework -print -quit 2>/dev/null || true)"
if [[ -z "${sparkle_framework}" ]]; then
  echo "未找到 Sparkle.framework，无法生成发布应用。" >&2
  exit 1
fi
ditto "${sparkle_framework}" "${app_path}/Contents/Frameworks/Sparkle.framework"

plist_buddy="/usr/libexec/PlistBuddy"
version="${APP_VERSION:-$(${plist_buddy} -c 'Print :CFBundleShortVersionString' "${plist_path}")}"
build="${APP_BUILD:-$(${plist_buddy} -c 'Print :CFBundleVersion' "${plist_path}")}"
channel="${RELEASE_CHANNEL:-local}"
feed_url="${QUOTAGLOW_UPDATE_FEED_URL:-}"
public_key="${QUOTAGLOW_PUBLIC_ED_KEY:-}"

${plist_buddy} -c "Set :CFBundleShortVersionString ${version}" "${plist_path}"
${plist_buddy} -c "Set :CFBundleVersion ${build}" "${plist_path}"
${plist_buddy} -c "Set :QuotaGlowReleaseChannel ${channel}" "${plist_path}"
${plist_buddy} -c 'Delete :SUFeedURL' "${plist_path}" >/dev/null 2>&1 || true
${plist_buddy} -c 'Delete :SUPublicEDKey' "${plist_path}" >/dev/null 2>&1 || true

if [[ -n "${feed_url}" || -n "${public_key}" ]]; then
  if [[ -z "${feed_url}" || -z "${public_key}" || "${feed_url}" != https://* ]]; then
    echo "更新源必须同时提供 HTTPS QUOTAGLOW_UPDATE_FEED_URL 和 QUOTAGLOW_PUBLIC_ED_KEY。" >&2
    exit 1
  fi
  ${plist_buddy} -c "Add :SUFeedURL string ${feed_url}" "${plist_path}"
  ${plist_buddy} -c "Add :SUPublicEDKey string ${public_key}" "${plist_path}"
elif [[ "${channel}" != "local" ]]; then
  echo "非 local 发布必须配置 Sparkle 更新源和 EdDSA 公钥。" >&2
  exit 1
fi

identity="${CODESIGN_IDENTITY:-}"
if [[ -n "${identity}" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "${identity}" "${app_path}"
else
  codesign --force --deep --sign - "${app_path}"
fi

codesign --verify --deep --strict --verbose=2 "${app_path}"
echo "${app_path}"
