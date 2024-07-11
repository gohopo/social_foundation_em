import 'dart:convert';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:social_foundation/social_foundation.dart';

abstract class SfChatManagerEm<TConversation extends SfConversation,TMessage extends SfMessage> extends SfChatManager<TConversation,TMessage>{
  String get appKey;
  @override
  Future close() => EMClient.getInstance.logout();
  @override
  Future<TConversation> convJoin(String conversationId) async {
    await EMClient.getInstance.chatRoomManager.joinChatRoom(conversationId);
    return protectedConvertConversation(await protectedGetConversation(conversationId,type:EMConversationType.ChatRoom));
  }
  @override
  Future convQuit(String conversationId) => EMClient.getInstance.chatRoomManager.leaveChatRoom(conversationId);
  @override
  Future convRead(String conversationId) async {
    var conversation = await protectedGetConversation(conversationId);
    return conversation.markAllMessagesAsRead();
  }
  @override
  Future convRecall(String messageID,{String? conversationId,int? timestamp}) => EMClient.getInstance.chatManager.recallMessage(messageID);
  @override
  Future<TConversation> getConversation(String conversationId) async {
    var conversation = await protectedGetConversation(conversationId);
    return protectedConvertConversation(conversation);
  }
  @override
  Future init() async {
    await EMClient.getInstance.init(EMOptions(
        appKey: appKey,
        autoLogin: false,
    ));
    await EMClient.getInstance.startCallback();

    EMClient.getInstance.addConnectionEventHandler(
      appKey,
      EMConnectionEventHandler(
        onConnected: onClientResuming,
        onDisconnected: onClientDisconnected
      )
    );
    EMClient.getInstance.chatManager.addEventHandler(
      appKey,
      EMChatEventHandler(
        onMessagesReceived: protectedOnMessagesReceived,
        onMessagesRecalledInfo: protectedOnMessagesRecalledInfo
      )
    );
    EMClient.getInstance.chatManager.addMessageEvent(
      appKey,
      ChatMessageEvent(
        onSuccess: (msgId,msg)=>protectedOnMessageEvent(msgId,msg),
        onError: (msgId,msg,_)=>protectedOnMessageEvent(msgId,msg),
      )
    );
  }
  @override
  Future login(String userId,{String? token}) => EMClient.getInstance.loginWithToken(userId,token!);
  Future<TConversation> protectedConvertConversation(EMConversation conversation) async {
    var lastMessage = await conversation.latestMessage();
    var map = {};
    map['ownerId'] = SfLocatorManager.userState.curUserId;
    map['convId'] = conversation.id;
    map['name'] = 'chat';
    map['creator'] = SfLocatorManager.userState.curUserId;
    map['members'] = conversation.type==EMConversationType.Chat?[SfLocatorManager.userState.curUserId,conversation.id]:[];
    map['unreadMessagesCount'] = await conversation.unreadCount();
    map['lastMessage'] = protectedConvertMessage(lastMessage);
    map['lastMessageAt'] = lastMessage?.localTime;
    return conversationFactory(map);
  }
  TMessage? protectedConvertMessage(EMMessage? message){
    if(message==null) return null;
    var map = {};
    map['ownerId'] = SfLocatorManager.userState.curUserId;
    map['msgId'] = message.msgId;
    map['convId'] = message.conversationId;
    map['fromId'] = message.from;
    map['timestamp'] = message.serverTime;
    map['status'] = protectedConvertStatus(message.status);
    map['receiptTimestamp'] = message.hasDeliverAck ? DateTime.now().millisecondsSinceEpoch : null;
    if(message.body.type == MessageType.TXT){
      map.addAll(jsonDecode((message.body as EMTextMessageBody).content));
    }
    return messageFactory(map);
  }
  int protectedConvertStatus(MessageStatus status){
    switch(status){
      case MessageStatus.FAIL: return SfMessageStatus.failed;
      case MessageStatus.PROGRESS: return SfMessageStatus.sending;
      case MessageStatus.SUCCESS: return SfMessageStatus.sent;
      default: return SfMessageStatus.none;
    }
  }
  Future<EMConversation> protectedGetConversation(String conversationId,{EMConversationType? type}) async {
    var conversation = await EMClient.getInstance.chatManager.getConversation(conversationId,type:type??EMConversationType.Chat);
    if(conversation==null) throw '未查询到会话';
    return conversation;
  }
  void protectedOnMessageEvent(String msgId,EMMessage message) async {
    var data = await getMessage(msgId:msgId);
    if(data==null) return;
    data.status = protectedConvertStatus(message.status);
    saveMessage(data);
  }
  void protectedOnMessagesRecalledInfo(List<RecallMessageInfo> messages){
    for(var message in messages){
      onMessageRecalled(protectedConvertMessage(message.recallMessage)!);
    }
  }
  void protectedOnMessagesReceived(List<EMMessage> messages){
    for(var message in messages){
      onMessageReceived(protectedConvertMessage(message)!);
    }
  }
  Future<EMMessage> protectedSend(EMMessage message,bool transient){
    message.deliverOnlineOnly = transient;
    return EMClient.getInstance.chatManager.sendMessage(message);
  }
  @override
  Future<TMessage> protectedSendMessage(String conversationId,String? msg,String msgType,Map msgExtra) async {
    var message = EMMessage.createTxtSendMessage(
      targetId: conversationId,
      content: jsonEncode({
        'msg': msg,
        'msgType': msgType,
        'msgExtra': msgExtra
      })
    );
    var result = await protectedSend(message,msgExtra['transient']??false);
    return protectedConvertMessage(result)!;
  }
}