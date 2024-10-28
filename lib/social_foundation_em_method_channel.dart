import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'social_foundation_em_platform_interface.dart';

/// An implementation of [SocialFoundationEmPlatform] that uses method channels.
class MethodChannelSocialFoundationEm extends SocialFoundationEmPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('social_foundation_em');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  @override
  Future registerPush() => methodChannel.invokeMethod('registerPush');
}
