import 'package:social_foundation/social_foundation.dart';

abstract class SfConversationEm<TMessage extends SfMessage> extends SfConversation<TMessage>{
  SfConversationEm(super.data);
}