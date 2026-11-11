// Liquid Glass 适配层（iOS 移植版，docs/ios-port-notes.md）。
//
// 玻璃的渲染引擎按平台分档：
// - iOS（本移植版）：liquid_glass_renderer 的着色器玻璃（折射/霜化/光泽，
//   Impeller + Flutter GPU）。系统层面的键盘、分享面板、上下文菜单由构建时
//   的 iOS 26 SDK 自动获得原生 UIGlassEffect。
// - 其他平台（Android/桌面）：交给既有 GlassSurface 的 BackdropFilter 路径，
//   行为与上游完全一致。
//
// liquid_glass_renderer 不支持的设备/环境会自动降级 FakeGlass，不会崩。

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../platform_caps.dart';

/// iOS 上的 Liquid Glass 渲染开关与构造器。
final class IosGlass {
  IosGlass._();

  static bool? _cached;

  /// iOS 上恒可用：liquid_glass_renderer 自带 FakeGlass 降级，
  /// Flutter GPU 不可用也不会崩。其他平台恒 false。
  static bool get enabled {
    if (!isIosPort) return false;
    return _cached ??= _osMajorVersion() >= 17;
  }

  static int _osMajorVersion() {
    try {
      final match = RegExp(r'(\d+)\.').firstMatch(Platform.operatingSystemVersion);
      return match == null ? 0 : int.parse(match.group(1)!);
    } on Object {
      return 0;
    }
  }

  /// 把 [child] 包进一块 iOS Liquid Glass。调用方（GlassSurface）已经处理过
  /// padding/按压反馈；这里只负责材质本身。
  ///
  /// [shape] 三选一：[circle]、[stadium] 或给 [borderRadius]。
  static Widget surface({
    required Widget child,
    bool circle = false,
    bool stadium = false,
    BorderRadius? borderRadius,
    Brightness brightness = Brightness.light,
  }) {
    final shape = circle
        ? const LiquidOval()
        : LiquidRoundedSuperellipse(
            borderRadius: stadium ? 999 : (borderRadius?.topLeft.x ?? 28),
          );
    return LiquidGlassLayer(
      settings: LiquidGlassSettings.ios27Regular(brightness: brightness),
      child: LiquidGlass(shape: shape, child: child),
    );
  }
}
