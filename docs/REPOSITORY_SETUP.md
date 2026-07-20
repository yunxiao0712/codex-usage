# GitHub 仓库设置

## 创建仓库

1. 创建公开仓库 `codex-usage-strip`。
2. 不要让 GitHub 自动生成 README、License 或 `.gitignore`，本地仓库已经包含这些文件。
3. 将本地 `main` 推送到远端。
4. 在 `Settings → Pages` 中把 Source 设为 `GitHub Actions`。
5. 在 `Settings → Actions → General` 中允许 Actions 创建 Release 和部署 Pages。
6. 为 `main` 开启分支保护，要求 `CI / build-and-test` 通过后才能合并。
7. 开启 Dependabot alerts、Secret scanning 与 Private vulnerability reporting。

## Release Secrets

在 `Settings → Secrets and variables → Actions` 中配置：

| Secret | 内容 |
|---|---|
| `SPARKLE_PUBLIC_ED_KEY` | 写入应用的 Sparkle EdDSA 公钥 |
| `SPARKLE_PRIVATE_KEY` | 用于签名更新包的 Sparkle EdDSA 私钥 |

Sparkle 私钥只进入 GitHub Encrypted Secrets，不得写入仓库、Issue、Release notes 或构建日志。该密钥用于验证自动更新包，与付费的 Apple Developer ID 无关。

## 首次发布

1. 确认 `Info.plist` 中版本号，例如 `2.2.0`。
2. 在本地执行 `make test`。
3. 推送与版本一致的 tag：`v2.2.0`。
4. `Release` workflow 会依次完成 ad-hoc 签名构建、ZIP/DMG、Sparkle EdDSA appcast、GitHub Release 与 Pages 部署。
5. 从上一版本执行一次真实自动升级后，再对外宣传下载地址。

免费发布包没有 Apple Developer ID 签名与 notarization。首次启动时，用户需要按照 README 在“系统设置 → 隐私与安全性”中点击“仍要打开”。

发布工作流会自动把更新源设为：

```text
https://<owner>.github.io/<repository>/appcast.xml
```
