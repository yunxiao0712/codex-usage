#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
release_status_code=0

echo "Codex Usage Strip 免费发布环境"
echo "Swift: $(swift --version | head -n 1)"
if xcodebuild -version >/dev/null 2>&1; then
  echo "Xcode: 已安装"
else
  echo "Xcode: 未安装（使用 Command Line Tools 构建）"
fi

if find "${project_dir}/.build" -type f -name generate_appcast -perm +111 -print -quit 2>/dev/null | grep -q .; then
  echo "Sparkle appcast 工具: 可用"
else
  echo "Sparkle appcast 工具: 未找到，请先运行 swift package resolve"
  release_status_code=2
fi

if security find-generic-password -a app.codexusagestrip.desktop -s https://sparkle-project.org >/dev/null 2>&1; then
  echo "Sparkle EdDSA 私钥: 已保存到钥匙串"
else
  echo "Sparkle EdDSA 私钥: 未找到，请先运行 generate_keys --account app.codexusagestrip.desktop"
  release_status_code=2
fi

echo "Developer ID / notarization: 免费发布模式不需要"
echo "Project: ${project_dir}"
exit "${release_status_code}"
