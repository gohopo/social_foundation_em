import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_foundation_em/social_foundation_em_method_channel.dart';

void main() {
  MethodChannelSocialFoundationEm platform = MethodChannelSocialFoundationEm();
  const MethodChannel channel = MethodChannel('social_foundation_em');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
