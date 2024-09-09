// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'social_foundation_em_platform_interface.dart';

export 'package:im_flutter_sdk/im_flutter_sdk.dart' hide MessageType;
export 'package:social_foundation/social_foundation.dart';
//models
export './models/conversation.dart';
//services
export './services/chat_manager.dart';
//viewmodels
export './view_models/chat_model.dart';

class SocialFoundationEm {
  Future<String?> getPlatformVersion() {
    return SocialFoundationEmPlatform.instance.getPlatformVersion();
  }
}
