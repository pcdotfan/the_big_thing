import 'package:hive/hive.dart';

part 'folder.g.dart';

@HiveType(typeId: 0)
class Folder extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String desc;

  @HiveField(2)
  int color;

  @HiveField(3)
  String icon;

  @HiveField(4)
  int count;

  @HiveField(5)
  bool sticky;

  @HiveField(6)
  DateTime createTime;

  Folder(this.name, this.desc, this.color, this.icon, this.count, this.sticky,
      {DateTime createTime})
      : this.createTime = createTime ?? DateTime.now();
}
