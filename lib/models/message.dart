import 'package:social_foundation/social_foundation.dart';

abstract class SfMessageEm extends SfMessage{
  int readAck;
  SfMessageEm(super.data):readAck=data['readAck']??0;
  @override
  Map<String,dynamic> toMap(){
    var map = super.toMap();
    map['readAck'] = readAck;
    return map;
  }
  bool get hasReadAck => msgType==SfMessageType.system || readAck>0;
}