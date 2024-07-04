import 'package:flutter_test/flutter_test.dart';
import 'package:social_foundation_em/social_foundation_em.dart';
import 'package:social_foundation_em/social_foundation_em_platform_interface.dart';
import 'package:social_foundation_em/social_foundation_em_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSocialFoundationEmPlatform
    with MockPlatformInterfaceMixin
    implements SocialFoundationEmPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SocialFoundationEmPlatform initialPlatform = SocialFoundationEmPlatform.instance;

  test('$MethodChannelSocialFoundationEm is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSocialFoundationEm>());
  });

  test('getPlatformVersion', () async {
    SocialFoundationEm socialFoundationEmPlugin = SocialFoundationEm();
    MockSocialFoundationEmPlatform fakePlatform = MockSocialFoundationEmPlatform();
    SocialFoundationEmPlatform.instance = fakePlatform;

    expect(await socialFoundationEmPlugin.getPlatformVersion(), '42');
  });
}
