import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// iOS 移植版的平台能力开关（见 docs/ios-port-notes.md）。
///
/// iOS 版是纯远程客户端：本机引擎、手机操控、App 外悬浮宠物等 Android
/// 专属能力没有对应的原生插件，与其让它们在运行时静默失败，不如在
/// 入口层关掉。所有 UI 门控都引用这里，不要在界面上直接写 `Platform.isIOS`。
///
/// 测试与桌面宿主上恒为 false：门控不影响 golden 测试与既有行为。
final bool isIosPort = !kIsWeb && Platform.isIOS;
