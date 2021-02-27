import 'package:hive/hive.dart';

part 'thing.g.dart';

@HiveType(typeId: 1)
class Thing extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String content;
  @HiveField(2)
  int color;
  @HiveField(3)
  DateTime dueDate;
  @HiveField(4)
  bool sticky;
  @HiveField(5)
  int folderId;
  @HiveField(6)
  String audioPath;

  factory Thing.fromJson(Map<String, dynamic> parsedJson) {
    return new Thing(
        parsedJson['name'] as String,
        parsedJson['content'] as String,
        parsedJson['color'] as int,
        DateTime.parse(parsedJson['dueDate']),
        parsedJson['sticky'] as bool,
        0);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'content': content,
      'color': color,
      'dueDate': dueDate.toIso8601String(),
      'sticky': sticky,
    };
  }

  Thing(this.name, this.content, this.color, this.dueDate, this.sticky,
      this.folderId,
      {this.audioPath = ''});
}
