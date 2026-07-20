# Changelog

## [Unreleased]

### Changed

- 项目与应用正式更名为 Codex Usage Strip。
- 应用包、Bundle ID、配置扩展名、发布产物和自动更新变量已统一使用新名称。
- 首次启动会迁移旧版 QuotaGlow 的偏好设置、自定义资源与开机启动项。

### Planned

- 完成首个 Developer ID 签名与 notarization 发布。
- 配置正式 Sparkle appcast 与 EdDSA 公钥。

## [2.2.0] - 2026-07-19

### Added

- Swift Package Manager 工程与可复现构建脚本。
- Sparkle 2.9.2 自动更新集成。
- ZIP、DMG、签名、公证与 appcast 发布脚本。
- 开源所需的隐私、安全、贡献和架构文档。

### Changed

- 功能冻结，版本进入开源候选阶段。

## [2.1.0] - 2026-07-19

### Added

- 关于页、配置迁移与版本检查。
- 四角等比缩放和拖拽光标反馈。

### Fixed

- 只读取 Codex 总额度，忽略模型独立额度。
