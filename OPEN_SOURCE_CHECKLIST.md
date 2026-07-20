# 开源前检查清单

## 已完成

- [x] MIT License。
- [x] README、隐私、安全、贡献、架构和发布文档。
- [x] Swift Package Manager 依赖锁定。
- [x] 本地构建、自检、ZIP、DMG 和 SHA-256 流程。
- [x] Sparkle 自动更新代码与 appcast 工具链。
- [x] GitHub Actions 自动构建 ad-hoc 签名安装包、Release 与 Pages appcast 工作流。
- [x] 源码敏感信息扫描，无个人绝对路径和凭据。
- [x] GitHub 名称初步检索，未发现明显同名 macOS 项目。

## 公开发布前必须完成

- [x] 确定 GitHub owner 与最终仓库 URL：`PengXiaoyi/codex-usage-strip`。
- [ ] 生成并离线备份 Sparkle EdDSA 私钥。
- [ ] 确定 appcast HTTPS 地址并注入正式构建。
- [ ] 从旧版本完成一次真实自动升级。
- [ ] 创建 GitHub Release，上传 DMG、ZIP、SHA256SUMS 和 release notes。
- [ ] 在一台未安装过本应用的 Mac 上验证 README 的“仍要打开”流程。

免费发布包没有 Apple notarization。README 必须持续保留首次启动的系统确认说明，不能引导用户全局关闭 Gatekeeper。
