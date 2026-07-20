# 隐私说明

Codex Usage Strip 的设计原则是本地优先、最小读取。

## 会读取什么

- 通过本机 Codex 进程读取当前账户的总额度信息。
- 只解析每周窗口的使用百分比与刷新时间。
- 读取用户主动选择的本地背景图片和 Codex Usage Strip 配置。

## 不会做什么

- 不读取聊天内容、任务内容、提示词或代码文件。
- 不要求或保存 ChatGPT/Codex 密码、Cookie 或 API Key。
- 不将额度、背景图片、主题或话术上传到 Codex Usage Strip 服务器。
- 不包含分析、广告、遥测或崩溃上报 SDK。

## 网络访问

额度读取由本机 Codex 进程完成。正式发布版还会通过 HTTPS 访问维护者配置的 Sparkle appcast，用于检查更新；更新包会经过 EdDSA 与 Apple Code Signing 校验。

## 本地存储

偏好设置保存在 macOS `UserDefaults`，自定义资源保存在用户的 Application Support 目录。用户可以通过设置导出或导入 `.codexusagestripconfig`，并兼容旧版 `.quotaglowconfig`。
