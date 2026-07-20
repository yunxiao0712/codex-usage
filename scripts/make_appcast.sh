#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
release_dir="${RELEASE_DIR:-${project_dir}/.release}"
updates_dir="${release_dir}/updates"
tool="$(find "${project_dir}/.build" -type f -name generate_appcast -perm +111 -print -quit 2>/dev/null || true)"

if [[ -z "${tool}" ]]; then
  echo "未找到 Sparkle generate_appcast；请先运行 swift package resolve。" >&2
  exit 1
fi

args=(-o "${release_dir}/appcast.xml")
if [[ -n "${SPARKLE_DOWNLOAD_URL_PREFIX:-}" ]]; then
  args+=(--download-url-prefix "${SPARKLE_DOWNLOAD_URL_PREFIX}")
fi
if [[ -n "${SPARKLE_PRIVATE_KEY:-}" ]]; then
  print -rn -- "${SPARKLE_PRIVATE_KEY}" | "${tool}" --ed-key-file - "${args[@]}" "${updates_dir}"
else
  "${tool}" --account "${SPARKLE_KEY_ACCOUNT:-app.codexusagestrip.desktop}" "${args[@]}" "${updates_dir}"
fi
echo "${release_dir}/appcast.xml"
