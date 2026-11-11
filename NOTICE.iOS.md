# NOTICE — iOS 移植版

本仓库的 `ios-port` 分支是 DSH Go（https://github.com/ccch1mneyyy/dsh-Go，AGPL-3.0）
的 iOS 平台移植。

- 许可证：AGPL-3.0，与上游一致；本移植不改不减上游许可，分发修改版时须依
  AGPL-3.0 提供对应源码。
- 上游署名：DSH Go 及其作者（ccch1mneyyy）；上游协作请求见 README.md。
- 素材：按上游 ASSETS.md，DSH Go 标识与吉祥物（Deepy/鲸娘）仅限用于构建、
  测试、运行本仓库；**对外分发本移植版前必须替换**，且不得用于暗示与上游或
  DeepSeek 的关联。
- 第三方组件的许可义务见上游 THIRD_PARTY_NOTICES.md；iOS 版未携带上游的
  GPL/LGPL 原生组件（proot、libtalloc、Node.js rootfs），相应义务不随包分发。
- 本移植新增代码：
  - `app/ios/`（Runner 配置与 DshPlugins.swift 等）
  - `app/lib/platform_caps.dart`、`app/lib/ui/glass/ios_glass.dart`
  - 门控改动：`app/lib/ui/shell/root_gate.dart`、`app/lib/ui/shell/sessions_drawer.dart`、
    `app/lib/ui/settings/*`、`app/lib/ui/features/feature_catalog.dart`、
    `app/lib/ui/update/update_launch_check.dart`、`app/lib/ui/pets/pet_settings_page.dart`
  - `.github/workflows/ios.yml`、`docs/ios-port-notes.md`
