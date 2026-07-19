# 架构说明

QuotaGlow 是单进程 AppKit 应用，没有业务后端。

```text
UsageStripView / SettingsWindow / AboutWindow
                    │
                    ▼
              AppDelegate
          ┌─────────┼──────────┐
          ▼         ▼          ▼
 CodexQuotaService  AppPreferences  AppUpdateController
          │         ThemeStore          │
          ▼                             ▼
 local codex app-server           Sparkle appcast
```

## 关键边界

- `CodexQuotaService` 只启动本机 `codex app-server --stdio`，调用 `account/rateLimits/read`。
- 解析器优先选择 `limitId=codex` 的总额度，并从 `primary`/`secondary` 中选择周窗口。
- `UsageStripView` 负责绘制、拖动、四角缩放与鼠标反馈，不持有额度读取逻辑。
- `AppPreferences`、`ThemeStore` 和 `ConfigurationStore` 管理本地偏好与可移植配置。
- `AppUpdateController` 仅在 `SUFeedURL` 与 `SUPublicEDKey` 同时存在时启动 Sparkle。
- 本地构建不注入更新密钥，不会产生无效网络请求。
