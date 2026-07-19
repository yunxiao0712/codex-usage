# 发布说明

## 一次性准备

1. 安装完整 Xcode，并加入 Apple Developer Program。
2. 在钥匙串中安装 `Developer ID Application` 证书。
3. 使用 Sparkle `generate_keys` 生成 EdDSA 密钥，将私钥离线备份。
4. 确定 GitHub 仓库地址和 `appcast.xml` 的 HTTPS 地址。
5. 将公钥写入发布环境变量 `QUOTAGLOW_PUBLIC_ED_KEY`，不要把私钥提交到仓库。
6. 使用 `xcrun notarytool store-credentials` 创建钥匙串 profile。

## 构建正式候选包

```bash
export RELEASE_CHANNEL=stable
export CODESIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export QUOTAGLOW_UPDATE_FEED_URL='https://example.com/appcast.xml'
export QUOTAGLOW_PUBLIC_ED_KEY='base64-public-key'
export NOTARY_PROFILE='quotaglow-notary'

./scripts/check_release_prerequisites.sh
./scripts/package_release.sh
./scripts/notarize_release.sh
```

## 生成更新源

将已签名、已公证的 ZIP 放入 `.release/`，再运行：

```bash
./scripts/make_appcast.sh
```

Sparkle 会从钥匙串读取 EdDSA 私钥并生成 `appcast.xml`。发布 ZIP、DMG、appcast 和 release notes 后，应从上一稳定版执行一次完整自动升级。

CI 也可以通过 `SPARKLE_PRIVATE_KEY` 从标准输入临时提供私钥；脚本不会把密钥写入磁盘。

## 发布门禁

- `make test` 通过。
- `codesign --verify --deep --strict` 通过。
- `spctl --assess --type execute` 通过。
- `xcrun stapler validate` 通过。
- ZIP 和 DMG 的 SHA-256 已记录。
- 从上一稳定版检查更新、下载、安装、重启均成功。
- 仓库中无证书、私钥、Token、用户绝对路径或真实额度响应。
