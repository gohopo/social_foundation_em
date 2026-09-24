import 'package:social_foundation/social_foundation.dart';

abstract class SfCmdMessageEm extends SfMessageBase{
  late String action;
  SfCmdMessageEm(super.data);
  @override
  void populate(Map data){
    super.populate(data);
    action = data['action']??'';
  }
  @override
  Map<String,dynamic> toJson() => {
    ...super.toJson(),
    'action': action,
  };
  Future save() async {
    if(id!=null) return update(data:toDB(),id:id);
    var count = await update(data:toDB(),msgId:msgId,ownerId:ownerId);
    if(count>0) return;
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    await database.insert('cmdMessage',toDB(),conflictAlgorithm:ConflictAlgorithm.replace);
  }
  static Future<int> update({required Map<String,dynamic> data,int? id,String? msgId,String? ownerId}) async {
    List<String> where=[];List<Object?> whereArgs=[];
    if(id!=null){
      where.add('id=?');
      whereArgs.add(id);
    }
    if(msgId?.isNotEmpty==true){
      where.add('ownerId=?');
      whereArgs.add(ownerId ?? SfLocatorManager.userState.curUserId);
      where.add('msgId=?');
      whereArgs.add(msgId);
    }
    if(where.isEmpty) return 0;
    var database = await GetIt.instance<SfStorageManager>().getDatabase();
    return database.update('cmdMessage',data,where:where.join(' and '),whereArgs:whereArgs);
  }
}

abstract class SfMessageEm extends SfMessage{
  late int readAck;
  SfMessageEm(super.data);
  @override
  void populate(Map data){
    super.populate(data);
    readAck = data['readAck']??0;
  }
  @override
  Map<String,dynamic> toJson(){
    var map = super.toJson();
    map['readAck'] = readAck;
    return map;
  }
  bool get hasReadAck => msgType==SfMessageType.system || readAck>0;
}