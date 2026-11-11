// iOS 移植版的门控回归：测试宿主（Linux/Android）上门控必须恒 false，
// 既有平台行为不受移植影响（docs/ios-port-notes.md）。
import 'package:flutter_test/flutter_test.dart';

import 'package:dsh_app/platform_caps.dart';
import 'package:dsh_app/ui/glass/ios_glass.dart';

void main() {
  test('iOS port gating stays off on non-iOS hosts', () {
    expect(isIosPort, isFalse);
    expect(IosGlass.enabled, isFalse);
  });
}