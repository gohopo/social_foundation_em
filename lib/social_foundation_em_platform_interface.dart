import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'social_foundation_em_method_channel.dart';

abstract class SocialFoundationEmPlatform extends PlatformInterface {
  /// Constructs a SocialFoundationEmPlatform.
  SocialFoundationEmPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocialFoundationEmPlatform _instance = MethodChannelSocialFoundationEm();

  /// The default instance of [SocialFoundationEmPlatform] to use.
  ///
  /// Defaults to [MethodChannelSocialFoundationEm].
  static SocialFoundationEmPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SocialFoundationEmPlatform] when
  /// they register themselves.
  static set instance(SocialFoundationEmPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future registerPush();
}
