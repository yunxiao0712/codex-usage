#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
release_status_code=0

echo "Codex Usage Strip 发布环境"
echo "Swift: $(swift --version | head -n 1)"
if xcodebuild -version >/dev/null 2>&1; then
  echo "Xcode: 已安装"
else
  echo "Xcode: 未安装（本地测试包可构建，正式归档建议安装）"
fi

identity_count="$(security find-identity -v -p codesigning 2>/dev/null | awk '/valid identities found/ {print $1}')"
if [[ "${identity_count:-0}" -gt 0 ]]; then
  echo "Developer ID: 已检测到 ${identity_count} 个签名身份"
else
  echo "Developer ID: 未检测到（只能生成 ad-hoc 本地候选包）"
  release_status_code=2
fi

if xcrun --find notarytool >/dev/null 2>&1; then
  echo "Notary tool: 可用"
else
  echo "Notary tool: 不可用"
  release_status_code=2
fi

if [[ -n "${NOTARY_PROFILE:-}" ]] && xcrun notarytool history --keychain-profile "${NOTARY_PROFILE}" >/dev/null 2>&1; then
  echo "Notary profile: 可用"
else
  echo "Notary profile: 未配置或不可用"
  release_status_code=2
fi

echo "Project: ${project_dir}"
exit "${release_status_code}"
