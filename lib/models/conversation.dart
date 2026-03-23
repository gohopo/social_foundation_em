import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_em/models/message.dart';

abstract class SfConversationEm<TMessage extends SfMessageEm> extends SfConversation<SfMessageEm>{
  SfConversationEm(super.data);
  @override
  Future read() async {
    if(unreadMessagesCount==0) return;
    SfLocatorManager.chatManager.convRead(this);
    return super.read();
  }
}