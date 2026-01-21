import 'dart:convert';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_em/models/conversation.dart';

abstract class SfChatManagerEm<TConversation extends SfConversationEm,TMessage extends SfMessage> extends SfChatManager<TConversation,TMessage>{
  String get appKey;
  Map<String, String>? get extSettings => null;
  EMOptions get options => EMOptions.withAppKey(
    appKey,
    autoLogin: false,
    extSettings: extSettings,
  );
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
  Future convRead(TConversation conversation) async {
    var convType = conversation.type==0 ? EMConversationType.Chat : conversation.type==1 ? EMConversationType.GroupChat : EMConversationType.ChatRoom;
    var emConversation = await protectedGetConversation(conversation.convId,type:convType);
    return emConversation.markAllMessagesAsRead();
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
    await EMClient.getInstance.init(options);
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
  TConversation protectedConvertConversation(EMConversation conversation){
    Map map = {
      'convId': conversation.id,
      'dict': {
        '__type': conversation.type==EMConversationType.Chat ? 0 : conversation.type==EMConversationType.GroupChat ? 1 : 2
      },
      'members': conversation.type==EMConversationType.Chat ? [SfLocatorManager.userState.curUserId,conversation.id] : []
    };
    return conversationFactory(map);
  }
  TMessage protectedConvertMessage(EMMessage message){
    var map = {
      'convId': message.conversationId,
      'fromId': message.from,
      'msgId': message.msgId,
      'receiptTimestamp': message.hasDeliverAck ? DateTime.now().millisecondsSinceEpoch : null,
      'status': protectedConvertStatus(message.status),
      'timestamp': message.serverTime,
    };
    if(message.body.type == MessageType.TXT){
      map.addAll(jsonDecode((message.body as EMTextMessageBody).content));
    }
    var data = messageFactory(map);

    if(message.chatType == ChatType.Chat){
      if(data.msgExtra['__cid']!=null) data.convId = data.msgExtra['__cid'];
    }
    else if(message.chatType == ChatType.ChatRoom){
      data.msgExtra['transient'] = true;
    }
    data.msgExtra['transient'] ??= message.deliverOnlineOnly;

    return data;
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
    data.msgId = message.msgId;
    data.status = protectedConvertStatus(message.status);
    saveMessage(data);
  }
  void protectedOnMessagesRecalledInfo(List<RecallMessageInfo> messages){
    for(var message in messages){
      if(message.recallMessage==null) continue;
      onMessageRecalled(protectedConvertMessage(message.recallMessage!));
    }
  }
  void protectedOnMessagesReceived(List<EMMessage> messages){
    var list = messages
      .map((x) => protectedConvertMessage(x))
      .sorted((a,b) => a.timestamp.compareTo(b.timestamp));

    protectedUnreadMessages(list.where((x) => !x.transient));

    for(var message in list){
      onMessageReceived(message);
    }
  }
  Future<EMMessage> protectedSend(EMMessage message,bool transient){
    message.deliverOnlineOnly = transient;
    return EMClient.getInstance.chatManager.sendMessage(message);
  }
  @override
  Future<TMessage> protectedSendMessage(TConversation conversation,String? msg,String msgType,Map msgExtra) async {
    var chatType = conversation.type==0 ? ChatType.Chat : conversation.type==1 ? ChatType.GroupChat : ChatType.ChatRoom;
    var conversationId = conversation.convId;
    if(chatType==ChatType.Chat && conversation.otherId!=conversationId){
      msgExtra['__cid'] = conversationId;
      msgExtra['__cn'] = conversation.name;
      conversationId = conversation.otherId!;
    }

    var message = EMMessage.createTxtSendMessage(
      targetId: conversationId,
      content: jsonEncode({
        'msg': msg,
        'msgType': msgType,
        'msgExtra': msgExtra
      }),
      chatType: chatType
    );
    var result = await protectedSend(message,msgExtra['transient']??false);
    return protectedConvertMessage(result);
  }
  void protectedUnreadMessage(String conversationId,Iterable<TMessage> messages) async {
    var lastMessage = messages.last;
    var conversation = SfLocatorManager.chatState.getConversation(conversationId) ?? conversationFactory(
      lastMessage.msgExtra['__cid']!=null || lastMessage.convId==lastMessage.fromId ? {
        'convId': lastMessage.msgExtra['__cid'] ?? lastMessage.convId,
        'dict': {'__type':0},
        'members': [SfLocatorManager.userState.curUserId,lastMessage.fromId],
        'name': lastMessage.msgExtra['__cn']
      } : {
        'convId': lastMessage.convId,
        'dict': {'__type':1},
      }
    );
    conversation.lastMessage = lastMessage;
    conversation.lastMessageAt = lastMessage.timestamp;
    conversation.unreadMessagesCount += messages.length;
    saveConversation(conversation as TConversation);
    convRead(conversation);
    SfUnreadMessagesCountUpdatedEvent<TConversation>(conversation:conversation).emit();
  }
  void protectedUnreadMessages(Iterable<TMessage> messages){
    var map = messages.fold<Map<String,List<TMessage>>>({},(t,x){
      t[x.convId] ??= [];
      t[x.convId]?.add(x);
      return t;
    });

    for(var item in map.entries){
      protectedUnreadMessage(item.key,item.value);
    }
  }
}