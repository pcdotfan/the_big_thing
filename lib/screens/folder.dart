import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/entities/thing.dart';
import 'package:the_big_thing/ui/thing_list_card.dart';
import 'package:the_big_thing/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter/material.dart';

class FolderThings extends StatefulWidget {
  FolderThings({Key key}) : super(key: key);

  @override
  FolderThingsState createState() => FolderThingsState();
}

class FolderThingsState extends State<FolderThings> {
  Box<Folder> foldersBox;
  Box<Thing> thingsBox;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  Folder folder = Folder('', '', Vx.black.value, 'favorite', 0, false);

  @override
  void initState() {
    super.initState();
    foldersBox = Hive.box('folders');
    thingsBox = Hive.box('things');
    folder = foldersBox.get(int.parse(Get.parameters['id']));
    if (folder == null) Get.offAllNamed('/not-found');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(folder.color),
        title: Text("${folder.name}记事录"),
        actions: [
          IconButton(
              icon: Icon(
                Icons.qr_code_scanner_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                final scannedThing = await Get.toNamed('/scan',
                    arguments: folder.key.toString());
                if (scannedThing is Thing) {
                  final id = await thingsBox.add(scannedThing);
                  folder.count += 1;
                  folder.save();
                  Get.toNamed('/things/' + id.toString());
                  showMessage('已导入 1 项大事记');
                } else {
                  showMessage('导入失败', success: false);
                }
              }),
          IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                await Get.toNamed('/folders/create-edit', arguments: folder);
                setState(() {});
              }),
          IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () async {
                AlertDialog alert = AlertDialog(
                  title: Text("确认删除"),
                  content: Text("此操作不可逆，是否继续？"),
                  actions: [
                    FlatButton(
                      child: Text("取消"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("确定",
                          style: TextStyle(color: Color(folder.color))),
                      onPressed: () async {
                        final things = thingsBox.values
                            .where((thing) =>
                                thing.folderId ==
                                int.parse(Get.parameters['id']))
                            .toList();
                        thingsBox.deleteAll(things);
                        foldersBox.delete(int.parse(Get.parameters['id']));
                        things.forEach((thing) {
                          flutterLocalNotificationsPlugin
                              .cancel(int.parse(thing.key));
                        });
                        Navigator.pop(context);
                        Get.offAllNamed('/');
                        showMessage('记事录已删除');
                      },
                    ),
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: '新增',
          onPressed: () =>
              Get.toNamed('/things/create-edit', arguments: folder),
          backgroundColor: Color(folder.color),
          child: Icon(Icons.add)),
      body: VStack([
        ValueListenableBuilder(
            valueListenable: Hive.box<Thing>('things').listenable(),
            builder: (context, Box<Thing> box, _) {
              final things = box.values
                  .where((thing) => thing.folderId == folder.key)
                  .toList();
              things.sort((a, b) =>
                  (b.sticky == true ? 1 : 0) - (a.sticky == true ? 1 : 0));
              if (box.values.isEmpty)
                return Center(child: '无大事发生'.text.gray700.xl6.make()).p12();

              return VStack(things
                  .map((thing) => GestureDetector(
                        onTap: () =>
                            Get.toNamed('/things/' + thing.key.toString()),
                        child: ThingListCard(
                          dueDate: thing.dueDate.toIso8601String(),
                          name: thing.name,
                          sticky: thing.sticky,
                          content: thing.content,
                          color: Color(thing.color),
                        ),
                      ).py4())
                  .toList());
            }),
        Center(child: folder.desc.text.xl.center.gray600.make().p12()),
      ]).p8().scrollVertical(),
    );
  }
}
