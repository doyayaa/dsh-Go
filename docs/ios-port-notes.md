# DSH Go · iOS 移植版说明

本分支（`ios-port`）把 DSH Go 从 Android 客户端移植为可构建、可安装的 iOS 应用。
构建在 GitHub Actions 的 macOS runner 上完成（Flutter 官方只支持 macOS 构建 iOS），
产物是**无签名 ipa**，用 Sideloadly / AltStore / xtool 以 Apple ID 现场签名安装
（免费账号签名 7 天有效，过期重签）。

## 产品形态：纯远程客户端

Android 版的「内置 Linux 环境」（APK 内置 Ubuntu rootfs + Termux proot + Node.js
DSH 引擎）在 iOS 上**不可移植**：

- **技术**：iOS 沙盒禁止 `ptrace`（proot 的实现基础）、禁止 exec 沙盒内生成的或
  下载的机器码（proot/Node/ELF 全部出局），且没有 jniLibs 式的可执行载荷机制；
- **许可**：proot 为 GPL-2.0、libtalloc 为 LGPL-3.0+，与 iOS 分发机制直接冲突
  （见 THIRD_PARTY_NOTICES.md）。

因此 iOS 版 = **遥控你电脑上的 DSH**：SSH 主机（dartssh2 + 端口转发）与
DSH Remote（relay + WebRTC DataChannel，Noise_IK 端到端加密）两条链路都是纯
Dart，原样可用；xterm 终端、聊天、分享体系、多语言 UI 同样原样可用。

## 平台能力对照

| Android 版能力 | iOS 版处理 |
|---|---|
| 本机引擎（proot + rootfs） | ❌ 移除入口（`lib/platform_caps.dart` 门控），主机默认引导添加远程主机 |
| 手机操控（无障碍 + Shizuku/ADB/Root） | ❌ 移除入口 |
| App 外悬浮宠物（SYSTEM_ALERT_WINDOW） | ❌ App 内宠物舞台保留；overlay 设置项隐藏 |
| APK 自更新 | ❌ 移除（升级 = 重装 ipa；TestFlight/App Store 是后续路线） |
| 桌面小部件（AppWidget）/ 图标别名 / 快捷磁贴 | ❌ 移除（WidgetKit 需付费开发者账号的 App Group，Phase 2） |
| 前台服务保活 / 后台保活引导 | ❌ 无等价物（`dsh/app` 通道的保活调用为 no-op） |
| 系统输入法取证（SystemIme） | ❌ 不实现（诊断走 `unsupported` 证据路径） |
| 通知（ChatNotifier） | ✅ UNUserNotificationCenter：status/show/cancel/cancelAll/openSettings + 点击路由（`dsh/notify/taps`） |
| 实时活动（Android 模拟 LiveActivity） | ⏸ 暂缓（iOS 原生 Live Activity 需付费账号 + Widget 扩展） |
| 保存图片/视频到相册 | ✅ PHPhotoLibrary（仅「添加」权限） |
| 诊断信息 | ✅ 部分 section（app/device），缺省键 Dart 端全兜底 |
| 时区 | ✅ `dsh/app.getTimeZoneId` 返回真实 IANA id |
| 语音输入 / 语音播报 / 文件选择 / 分享接收 | ⏸ Phase 2（SFSpeech、AVSpeechSynthesizer、UIDocumentPicker、Share Extension） |

所有门控集中在 `app/lib/platform_caps.dart` 的 `isIosPort`，入口级开关；
Dart 封装层既有的 MissingPluginException 降级路径原样保留。

## Liquid Glass

- 玻璃枢纽 `lib/ui/theme/glass.dart`（`GlassSurface`）在 iOS 上整体切换到
  `liquid_glass_renderer` 1.0 的着色器玻璃（折射/霜化/光泽，Impeller + Flutter
  GPU，`FLTEnableFlutterGPU`）；不支持的设备自动降级 FakeGlass，不崩。
- 其他平台（Android/桌面）走的仍是上游 BackdropFilter 路径，行为不变。
- 系统级表面（键盘、分享面板、上下文菜单）由 CI 用 iOS 26 SDK 构建自动获得
  原生 Liquid Glass。
- 「减少透明效果」等无障碍开关仍然生效（`blurEnabled=false` 时不走玻璃路径）。

## 工程

- 最低 iOS 16.0（xcodeproj `IPHONEOS_DEPLOYMENT_TARGET`）；真机 arm64。
- Bundle ID `io.github.ccch1mneyyy.dsh`。
- 构建：`.github/workflows/ios.yml` → macOS runner → `flutter build ios
  --release --no-codesign` → `DSH-Go-iOS-unsigned.ipa` artifact。
- 本机开发（Linux）：`flutter analyze` 可跑；widget 测试需 ≥2 GB 内存编译，
  小内存机器以 CI 为准。packages 的 `dart test` 不受此限。

## 安装（无签名 ipa）

产物：Actions → ios workflow → 最新 run → artifact `DSH-Go-iOS-unsigned`
（命令行：`gh run download <run-id> -n DSH-Go-iOS-unsigned`）。

真机准备（一次性）：iOS 16+ 打开「设置 → 隐私与安全性 → 开发者模式」并重启；
安装后在「设置 → 通用 → VPN 与设备管理」信任自己的 Apple ID 证书。

**Sideloadly（Windows/macOS）**：

1. 装 Sideloadly（sideloadly.io），USB 连接 iPhone 并信任电脑；
2. 把 `DSH-Go-iOS-unsigned.ipa` 拖进 Sideloadly，填 Apple ID（免费账号即可）；
3. Start → 现场签名并安装；7 天过期后用同一 Apple ID 重拖一次即可
   （覆盖安装，沙盒内聊天记录不丢）。

**xtool（Linux，本机已装 1.24.0）**：

```bash
xtool auth login                 # 一次性：Apple ID + 2FA（免费账号可用）
xtool devices                    # 确认 USB 设备在列
xtool install DSH-Go-iOS-unsigned.ipa   # 签名 + 直装
```

AltStore / SideStore 同理：把 ipa 交给它用 Apple ID 重签。

## 冒烟清单（装到真机后逐项过）

- [ ] 启动进远程空态，**不出现**本机引擎安装引导；设置里无「本机引擎 /
  手机操控 / 后台保活 / 无障碍引导 / 自更新 / 图标别名 / App 外宠物」入口
- [ ] 添加远程主机（SSH 或 DSH Remote）→ 连接成功 → 会话列表同步
- [ ] 发一条消息：流式回复正常；xterm 终端可打开
- [ ] 通知：首次弹权限请求；引擎完成事件能收到通知；点通知路由到对应会话
  （含冷启动点击）；通知快捷按钮不可用属已知限制
- [ ] 对话里保存图片到相册：弹「仅添加」权限，相册可见
- [ ] Liquid Glass：iOS 26 设备有折射/霜化玻璃；旧设备自动降级不崩；
  「减少透明效果」开启后玻璃关闭
- [ ] 诊断页：app/device 信息有值；SystemIme 取证走 unsupported 路径不报错
- [ ] 日程编辑的时区显示真实 IANA id（如 Asia/Shanghai）
- [ ] 嵌入 DSH Web（SSH 转发 127.0.0.1）能打开（ATS 本地明文已放行）

## 通道契约（iOS 实现 ↔ Dart 期望）

| 通道 | 方法（iOS 实现的） | 说明 |
|---|---|---|
| `dsh/app` | getTimeZoneId / setRefreshRateMode / setFrameActive / bringToFront | 后三个 no-op |
| `dsh/notify` | status / show / cancel / cancelGroup / cancelAll / openSettings / actionResult | `live`/`liveStatus`/`openLiveSettings` 回 not-implemented → Dart 按 unavailable 降级 |
| `dsh/notify/taps` | EventChannel | userInfo 携带 sessionId/host/kind/eventId；冷启动 tap 先持有、listen 补发 |
| `dsh/media` | saveImage(bytes,name,mime) / saveVideoFile(path,name) / openSettings | 错误码对齐 Android：invalid/permission/failed |
| `dsh/diagnostics` | info / engineLog / cancelSystemIme | info 永不抛错；collectSystemIme 回 not-implemented |

## 合规

- 本移植是 AGPL-3.0 衍生作品，沿用上游许可证；NOTICE 见仓库根目录。
- **未替换素材**：按 ASSETS.md，DSH Go 标识与吉祥物（Deepy/鲸娘）可用于
  构建与测试本仓库；**对外分发本移植版前必须整套替换品牌与宠物素材**，并
  不得暗示与上游/DeepSeek 的关联。

## 已知限制（诚实清单）

- 默认主机解析为「本机」时，iOS 版一律走远程空态引导添加主机；直接对本机
  发起连接不会发生（无原生运行时）。
- 嵌入的 DSH Web（WKWebView）指向 SSH 转发的 `http://127.0.0.1`，已放行
  ATS 本地明文（`NSAllowsLocalNetworking`）。
- 通知 actions 按钮未实现（`dsh/notify/actions` 空流）：能收通知、能点开
  对话，但通知上的快捷按钮不可用。
- 免费签名安装的 app 7 天过期；过期前用同一 Apple ID 重签重装即可，聊天记录
  在应用沙盒内，重装（覆盖安装）不丢。
