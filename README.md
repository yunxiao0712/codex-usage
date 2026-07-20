# Codex Usage Strip

<p align="center"><img src="docs/images/AppIcon.png" width="128" alt="Codex Usage Strip 图标"></p>

Codex Usage Strip 是一个常驻 macOS 桌面的 Codex 每周额度组件。它只显示剩余额度、进度条和刷新倒计时，不承担聊天或任务执行。

![Codex Usage Strip 桌面效果](docs/images/Codex-Usage-Strip-live.png)

## 核心能力

- 只读取 Codex 总额度中的每周窗口，忽略模型独立额度。
- 同时显示剩余百分比、进度条、重置时间和倒计时。
- 支持浮在所有窗口之上，或贴近桌面层显示。
- 四角等比缩放，拖拽区域带明确光标反馈。
- 6 套内置皮肤、3 种显示形态、5 种背景图片布局。
- 自定义背景图、背景透明度和整体透明度。
- 自定义状态话术，支持 `{remaining}`、`{used}`、`{countdown}`、`{resetTime}`、`{pace}`、`{updatedAt}`。
- 开机启动、额度提醒、配置导入导出。
- 通过 Sparkle 提供 EdDSA 校验的安全自动更新。

## 运行要求

- macOS 14 或更高版本。
- 本机已安装并登录 ChatGPT/Codex，或已安装可执行的 Codex CLI。
- 当前版本优先读取 `/Applications/ChatGPT.app/Contents/Resources/codex`，也支持 `CODEX_PATH` 指定路径。

Codex Usage Strip 使用本机 Codex 的 `account/rateLimits/read` 接口读取额度。该接口不是稳定的公开兼容承诺；上游格式变化时，Codex Usage Strip 可能需要同步更新。

## 从源码构建

```bash
git clone https://github.com/PengXiaoyi/codex-usage-strip.git
cd codex-usage-strip
make build
open ".artifacts/Codex Usage Strip.app"
```

首次构建会通过 Swift Package Manager 获取 Sparkle 2.9.2。执行自检：

```bash
make test
```

生成本地 ZIP 和 DMG 候选包：

```bash
make package
```

本地候选包使用 ad-hoc 签名，仅用于开发测试。面向公众发布前必须完成 Developer ID 签名、公证和 Sparkle 更新签名，详见 [发布说明](docs/RELEASING.md) 与 [GitHub 仓库设置](docs/REPOSITORY_SETUP.md)。

## 皮肤与背景

| 纸感白 | 樱花粉 | 终端绿 |
|---|---|---|
| ![](docs/images/skins/paper.png) | ![](docs/images/skins/sakura.png) | ![](docs/images/skins/terminal.png) |

| 石墨黑 | 赛博紫 | 交通灯 |
|---|---|---|
| ![](docs/images/skins/graphite.png) | ![](docs/images/skins/cyber.png) | ![](docs/images/skins/traffic.png) |

用户可以在设置中直接选择 PNG、JPEG、WebP 或 HEIC 图片作为背景，并分别调整背景图片透明度与整个组件透明度。皮肤也可以通过 `.quotatheme` 文件导入导出。

## 隐私

Codex Usage Strip 不要求账号密码，不上传额度、背景图片或配置。额度请求由本机 Codex 进程完成。完整边界见 [PRIVACY.md](PRIVACY.md)。

## 项目状态

当前开源候选版本为 `2.2.0 (5)`。功能已经冻结，后续变更优先处理兼容性、安全性和可维护性。

## 参与贡献

提交问题前请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [SECURITY.md](SECURITY.md)。

## 许可

[MIT License](LICENSE)。Codex Usage Strip 是独立社区项目，与 OpenAI 无隶属或官方背书关系；Codex、ChatGPT 及相关商标归其权利人所有。
