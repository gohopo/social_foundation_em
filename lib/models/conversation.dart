import 'package:social_foundation/social_foundation.dart';

abstract class SfConversationEm<TMessage extends SfMessage> extends SfConversation<TMessage>{
  SfConversationEm(super.data);
  @override
  Future read() async {
    if(unreadMessagesCount==0) return;
    SfLocatorManager.chatManager.convRead(convId);
    return super.read();
  }
}