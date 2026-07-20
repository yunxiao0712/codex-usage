# 发布说明

GitHub 自动发布的仓库配置与 Secrets 见 [REPOSITORY_SETUP.md](REPOSITORY_SETUP.md)。本页保留本机手动发布流程。

## 一次性准备

1. 使用 Sparkle `generate_keys --account app.codexusagestrip.desktop` 生成 EdDSA 密钥，将私钥离线备份。
2. 确定 GitHub 仓库地址和 `appcast.xml` 的 HTTPS 地址。
3. 将公钥写入发布环境变量 `CODEX_USAGE_STRIP_PUBLIC_ED_KEY`，不要把私钥提交到仓库。

当前项目采用免费发布方式，不依赖 Apple Developer Program。生成的应用使用 ad-hoc 签名，更新压缩包使用独立的 Sparkle EdDSA 签名。

## 构建正式候选包

```bash
export RELEASE_CHANNEL=stable
export CODEX_USAGE_STRIP_UPDATE_FEED_URL='https://example.com/appcast.xml'
export CODEX_USAGE_STRIP_PUBLIC_ED_KEY='base64-public-key'

./scripts/package_release.sh
```

## 生成更新源

将已完成 ad-hoc 签名的 ZIP 放入 `.release/`，再运行：

```bash
./scripts/make_appcast.sh
```

Sparkle 会从钥匙串读取 EdDSA 私钥并生成 `appcast.xml`。发布 ZIP、DMG、appcast 和 release notes 后，应从上一稳定版执行一次完整自动升级。

CI 也可以通过 `SPARKLE_PRIVATE_KEY` 从标准输入临时提供私钥；脚本不会把密钥写入磁盘。

## 发布门禁

- `make test` 通过。
- `codesign --verify --deep --strict` 通过。
- ZIP 和 DMG 的 SHA-256 已记录。
- 从上一稳定版检查更新、下载、安装、重启均成功。
- 仓库中无证书、私钥、Token、用户绝对路径或真实额度响应。
- 在一台未安装过本应用的 Mac 上验证 README 的“仍要打开”流程。
