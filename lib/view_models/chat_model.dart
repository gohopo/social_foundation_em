import 'package:social_foundation/models/conversation.dart';
import 'package:social_foundation/models/message.dart';
import 'package:social_foundation/view_models/chat_model.dart';

abstract class SfChatModelEm<TConversation extends SfConversation,TMessage extends SfMessage> extends SfChatModel<TConversation,TMessage>{
  SfChatModelEm(super.args);
  @override
  Future listenMessageEvent() async {
    disposeMessageEvent();
    if(conversation==null) return;
    await queryUnreadMessages();
    return super.listenMessageEvent();
  }
  @override
  void onClientResuming() async {
    listenMessageEvent();
  }
  Future queryUnreadMessages() async {
    var messages = list.take(conversation!.unreadMessagesCount).toList();
    if(messages.isNotEmpty) await onUnreadMessages(messages);
  }
}