import 'dart:convert';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:social_foundation/social_foundation.dart';
import 'package:social_foundation_em/models/conversation.dart';
import 'package:social_foundation_em/models/message.dart';
import 'package:social_foundation_em/services/event_manager.dart';

abstract class SfChatManagerEm<TCmdMessage extends SfCmdMessageEm,TConversation extends SfConversationEm<TMessage>,TMessage extends SfMessageEm> extends SfChatManager<TConversation,TMessage>{
  String get appKey;
  Map<String, String>? get extSettings => null;
  EMOptions get options => EMOptions.withAppKey(
    appKey,
    autoLogin: false,
    extSettings: extSettings,
  );
  @override
  Future close() => EMClient.getInstance.logout();
  TCmdMessage cmdMessageFactory(Map data);
  TCmdMessage cmdMessageFactory2({required String convId,required String action,Map? msgExtra,Map? attribute,String? fromId,int? timestamp}) => cmdMessageFactory({
    'ownerId': SfLocatorManager.userState.curUserId,
    'convId': convId,
    'action': action,
    'fromId': fromId??SfLocatorManager.userState.curUserId,
    'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    'msgExtra': msgExtra,
    'attribute': attribute,
  });
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
    if(EMClient.getInstance.options?.requireAck==true && convType==EMConversationType.Chat){
      EMClient.getInstance.chatManager.sendConversationReadAck(emConversation.id);
    }
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
        onCmdMessagesReceived: protectedOnCmdMessagesReceived,
        onConversationRead: protectedOnConversationRead,
        onMessagesRecalledInfo: protectedOnMessagesRecalledInfo,
        onMessagesReceived: protectedOnMessagesReceived,
      )
    );
    EMClient.getInstance.chatManager.addMessageEvent(
      appKey,
      ChatMessageEvent(
        onError: (msgId,msg,_)=>protectedOnMessageEvent(msgId,msg),
        onSuccess: (msgId,msg)=>protectedOnMessageEvent(msgId,msg),
      )
    );
  }
  @override
  Future login(String userId,{String? token}) => EMClient.getInstance.loginWithToken(userId,token!);
  void onCmdMessageReceived(TCmdMessage message){
    saveCmdMessage(message,isNew:true);
  }
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
  TMessage protectedConvertMessage<TMessage extends SfMessageBase>(EMMessage message,TMessage Function(Map) converter){
    var map = {
      'convId': message.conversationId,
      'fromId': message.from,
      'readAck': message.hasReadAck?1:0,
      'msgId': message.msgId,
      'receiptTimestamp': message.hasDeliverAck ? DateTime.now().millisecondsSinceEpoch : null,
      'status': protectedConvertStatus(message.status),
      'timestamp': message.serverTime,
    };
    if(message.body.type == MessageType.TXT){
      map.addAll(jsonDecode((message.body as EMTextMessageBody).content));
    }
    else if(message.body.type == MessageType.CMD){
      map['action'] = (message.body as EMCmdMessageBody).action;
    }
    if(message.attributes!=null) map.addAll(message.attributes!);
    var data = converter(map);

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
  (ChatType,String) protectedGetConversationInfo(TConversation conversation,Map msgExtra){
    var chatType = conversation.type==0 ? ChatType.Chat : conversation.type==1 ? ChatType.GroupChat : ChatType.ChatRoom;
    var conversationId = conversation.convId;
    if(chatType==ChatType.Chat && conversation.otherId!=conversationId){
      msgExtra['__cid'] = conversationId;
      msgExtra['__cn'] = conversation.name;
      conversationId = conversation.otherId!;
    }
    return (chatType,conversationId);
  }
  void protectedOnCmdMessagesReceived(List<EMMessage> messages){
    var list = messages
      .map((x) => protectedConvertMessage(x,cmdMessageFactory))
      .sorted((a,b) => a.timestamp.compareTo(b.timestamp));

    for(var message in list){
      onCmdMessageReceived(message);
    }
  }
  void protectedOnConversationRead(String from,String to) async {
    await Future.delayed(const Duration(milliseconds:500));//确保lastMessage保存完成,否则会有两条消息
    var conversation = (await SfLocatorManager.chatState.queryConversation(from)) as TConversation?;
    if(conversation?.lastMessage==null) return;
    var message = conversation!.lastMessage! as TMessage;
    if(message.msgType==SfMessageType.system) return;
    message.readAck = 1;
    saveMessage(message,conversation:conversation,isNew:false);
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
      onMessageRecalled(protectedConvertMessage(message.recallMessage!,messageFactory));
    }
  }
  void protectedOnMessagesReceived(List<EMMessage> messages){
    var list = messages
      .map((x) => protectedConvertMessage(x,messageFactory))
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
  Future<TCmdMessage> protectedSendCmdMessage(TConversation conversation,String action,Map msgExtra) async {
    var (chatType,conversationId) = protectedGetConversationInfo(conversation,msgExtra);
    var message = EMMessage.createCmdSendMessage(
      action: action,
      targetId: conversationId,
      chatType: chatType
    );
    message.attributes = {'msgExtra':msgExtra};
    var result = await protectedSend(message,msgExtra['transient']??false);
    return protectedConvertMessage(result,cmdMessageFactory);
  }
  @override
  Future<TMessage> protectedSendMessage(TConversation conversation,String? msg,String msgType,Map msgExtra) async {
    var (chatType,conversationId) = protectedGetConversationInfo(conversation,msgExtra);
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
    return protectedConvertMessage(result,messageFactory);
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
  void saveCmdMessage(TCmdMessage message,{bool isNew=false}) async {
    if(!message.transient) await message.save();

    SfCmdMessageEvent(message:message,isNew:isNew).emit();
  }
  Future<TCmdMessage> sendCmd({required TConversation conversation,required String action,Map? msgExtra,Map? attribute,bool? transient}){
    var message = cmdMessageFactory2(
      convId:conversation.convId,action:action,msgExtra:msgExtra,attribute:attribute
    );
    if(transient!=null) message.msgExtra['transient'] = transient;
    
    return protectedSendCmdMessage(conversation,action,message.msgExtra);
  }
}