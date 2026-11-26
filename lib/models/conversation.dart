import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_em/models/message.dart';

abstract class SfConversationEm<TMessage extends SfMessageEm> extends SfConversation<SfMessageEm>{
  SfConversationEm(super.data);
  ChatType getChatType() => type==0 ? ChatType.Chat : type==1 ? ChatType.GroupChat : ChatType.ChatRoom;
  EMConversationType getConversationType() => type==0 ? EMConversationType.Chat : type==1 ? EMConversationType.GroupChat : EMConversationType.ChatRoom;
  @override
  Future read() async {
    if(unreadMessagesCount==0) return;
    SfLocatorManager.chatManager.convRead(this);
    return super.read();
  }
}