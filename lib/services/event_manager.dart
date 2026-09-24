import 'package:social_foundation/services/event_manager.dart';
import 'package:social_foundation_em/models/message.dart';

class SfCmdMessageEvent extends SfEvent<SfCmdMessageEvent>{
  SfCmdMessageEm? message;
  bool isNew;
  SfCmdMessageEvent({this.message,this.isNew=false});
}