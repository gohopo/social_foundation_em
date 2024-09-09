import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/view_models/chat_model.dart';

abstract class SfChatModelEm<TConversation extends SfConversation,TMessage extends SfMessage> extends SfChatModel<TConversation,TMessage>{
  SfChatModelEm(super.args);
  @override
  void listenMessageEvent() async {
    disposeMessageEvent();
    if(conversation==null) return;
    var messages = list.sublist(0,conversation!.unreadMessagesCount);
    super.listenMessageEvent();
    if(messages.isNotEmpty) onUnreadMessages(messages);
  }
  @override
  void onClientResuming() async {
    listenMessageEvent();
  }
}