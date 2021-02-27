import 'dart:io';

import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/entities/thing.dart';
import 'package:the_big_thing/utils/material_icons.dart';
import 'package:the_big_thing/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PageController extends GetxController {
  final notifyDate = DateTime.now().obs;
  final thing =
      Thing('', '', Colors.black.value, DateTime.now(), false, -1).obs;
  final notifyMethod = '一次'.obs;
}

class CreateEditThingPage extends StatefulWidget {
  CreateEditThingPage({Key key}) : super(key: key);

  @override
  CreateEditThingPageState createState() => CreateEditThingPageState();
}

class CreateEditThingPageState extends State<CreateEditThingPage> {
  CalendarController _calendarController;
  bool isEditMode = false;
  int thingKey = -1;
  final PageController controller = Get.put(PageController());
  File audioFile;
  final _formKey = new GlobalKey<FormState>();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final notifyMethodsObj = {
    '一次': RepeatInterval.values,
    '每天': RepeatInterval.daily,
    '每周': RepeatInterval.weekly,
    '每分钟': RepeatInterval.everyMinute,
    '每小时': RepeatInterval.hourly,
  };
  Box<Thing> thingsBox;
  Box<Folder> foldersBox;

  Future<void> createSchedule(int id) async {
    final inDays = controller.thing().dueDate.difference(DateTime.now()).inDays;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      "THE_the_big_thing",
      'The Big Things',
      'A Big Thing is willing to happen.',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ticker: 'ticker',
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    if (controller.notifyMethod.value == '一次') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          '大事发生',
          "${controller.thing().name} 就是今天！",
          controller.thing().dueDate.difference(DateTime.now()).inDays == 0
              ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5))
              : tz.TZDateTime.from(controller.thing().dueDate, tz.local),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          payload: id.toString(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          '大事发生',
          "${controller.thing().name} ${inDays == 0 ? '就是今天！' : "还有 $inDays 天！"} ",
          notifyMethodsObj[controller.notifyMethod.value],
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          payload: id.toString());
    }
  }

  void createOrEdit() async {
    if (_formKey.currentState.validate()) {
      Folder _folder = foldersBox.get(controller.thing().folderId);
      if (isEditMode) {
        // 编辑模式
        Thing currentThing = thingsBox.get(thingKey);
        if (currentThing.isInBox) {
          // 处理计数逻辑
          if (currentThing.folderId != controller.thing().folderId) {
            Folder _oldFolder = foldersBox.get(currentThing.folderId);
            _oldFolder.count -= 1;
            _folder.count += 1;
            _oldFolder.save();
            _folder.save();
            currentThing.folderId = controller.thing().folderId;
          }

          currentThing.name = controller.thing().name;
          currentThing.color = controller.thing().color;
          currentThing.content = controller.thing().content;
          currentThing.sticky = controller.thing().sticky;
          currentThing.dueDate = controller.thing().dueDate;

          await currentThing.save();
          Get.back(result: currentThing);
        }
      } else {
        final id = await thingsBox.add(controller.thing());
        _folder.count += 1;
        _folder.save();
        // schedule
        await createSchedule(id);
        Get.back(result: controller.thing());
      }
      _formKey.currentState.reset();
      showMessage("${this.isEditMode ? '记事录已更新' : '大事即将发生'}");
    }
  }

  @override
  void initState() {
    super.initState();
    thingsBox = Hive.box('things');
    foldersBox = Hive.box('folders');
    _calendarController = CalendarController();
    isEditMode = Get.arguments is Thing;
    if (isEditMode) {
      thingKey = Get.arguments.key;
      controller.thing.update((t) {
        t.name = Get.arguments.name;
        t.sticky = Get.arguments.sticky;
        t.content = Get.arguments.content;
        t.color = Get.arguments.color;
        t.folderId = Get.arguments.folderId;
        t.audioPath = Get.arguments.audioPath;
      });
    } else {
      controller.thing.update((t) {
        t.folderId = Get.arguments.key;
      });
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(controller.thing().color),
          title: Text("${isEditMode ? '编辑' : '新增'}大事记"),
        ),
        body: VStack([
          VxBlock(
            children: [
              TableCalendar(
                locale: 'zh_CN',
                calendarController: _calendarController,
                headerStyle: HeaderStyle(formatButtonVisible: false),
                onDaySelected: (day, events, holidays) {
                  controller.notifyDate.value = day;
                  controller.thing.value.dueDate = day;
                },
              )
            ],
          ),
          Form(
              key: _formKey,
              child: VStack([
                Builder(builder: (context) {
                  if (!isEditMode) return SizedBox();
                  return ListTile(
                    leading: Icon(Icons.folder_open_outlined).py8(),
                    title: Text('记事本'),
                    trailing: Obx(() => DropdownButton<String>(
                          hint: Text('选择一本记事本'),
                          value: controller.thing().folderId.toString(),
                          onChanged: (folderId) {
                            controller.thing().folderId = int.parse(folderId);
                            setState(() {});
                          },
                          items: foldersBox.values
                              .map((folder) => DropdownMenuItem<String>(
                                    child: [
                                      Icon(MaterialIcons.mIcons[folder.icon])
                                          .px8(),
                                      Text(folder.name)
                                    ].hStack(),
                                    value: folder.key.toString(),
                                  ))
                              .toList(),
                        )),
                  );
                }),
                Builder(builder: (context) {
                  if (isEditMode || controller.notifyMethod.value != '一次')
                    return SizedBox();
                  return [
                    ListTile(
                      leading: Icon(Icons.alarm_add_outlined).py8(),
                      title: Text('提醒方式'),
                      trailing: Obx(() => DropdownButton(
                            hint: Text('选择提醒方式'),
                            value: controller.notifyMethod.value,
                            onChanged: (method) {
                              controller.notifyMethod.value = method;
                            },
                            items: notifyMethodsObj.entries
                                .map((method) => DropdownMenuItem(
                                    child: Text(method.key), value: method.key))
                                .toList(),
                          )),
                    ),
                    Obx(() => controller.notifyMethod.value == '一次'
                        ? [
                            ListTile(
                                leading: Icon(Icons.alarm).py8(),
                                title: Text('提醒时间'),
                                subtitle: Text(DateFormat.yMd()
                                    .format(controller.notifyDate.value)
                                    .toString()),
                                onTap: () async {
                                  final date = await showDatePicker(
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2099),
                                      context: context,
                                      initialDate: controller.thing().dueDate);
                                  controller.notifyDate.value = date;
                                }),
                            ListTile(
                                onTap: () {
                                  FilePicker.platform
                                      .pickFiles(
                                    type: FileType.audio,
                                  )
                                      .then((value) {
                                    controller.thing.update((thing) {
                                      thing.audioPath = value.files.single.path;
                                    });
                                  });
                                },
                                leading: Icon(Icons.music_note_outlined),
                                title: Text(
                                    controller.thing().audioPath.isEmptyOrNull
                                        ? '无提醒音乐'
                                        : controller
                                            .thing()
                                            .audioPath
                                            .split('/')
                                            .last))
                          ].vStack()
                        : SizedBox()),
                  ].vStack();
                }),
                ListTile(
                  leading: Icon(Icons.announcement_outlined).py8(),
                  title: Obx(() => TextFormField(
                        initialValue: controller.thing().name,
                        decoration: new InputDecoration(labelText: '大事标题'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return '怎么能没有标题呢';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          controller.thing().name = value;
                        },
                      )),
                ),
                ListTile(
                  leading: Icon(Icons.title_outlined).py8(),
                  title: Obx(() => TextFormField(
                        initialValue: controller.thing().content,
                        decoration: new InputDecoration(labelText: '大事内容'),
                        onChanged: (value) {
                          controller.thing.update((t) {
                            t.content = value;
                          });
                        },
                      )),
                ),
                Obx(() => SwitchListTile(
                    value: controller.thing().sticky,
                    secondary: Icon(Icons.arrow_upward_outlined).py8(),
                    onChanged: (value) {
                      controller.thing.update((t) {
                        t.sticky = value;
                      });
                    },
                    title: Text('置顶'))),
                ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('选择心情色'),
                            content: SingleChildScrollView(
                              child: Obx(() => BlockPicker(
                                    pickerColor:
                                        Color(controller.thing().color),
                                    onColorChanged: (Color color) {
                                      controller.thing.update((t) {
                                        t.color = color.value;
                                      });
                                      context.pop();
                                    },
                                  )),
                            ),
                          );
                        },
                      );
                    },
                    leading: Obx(() => SizedBox()
                        .p12()
                        .backgroundColor(Color(controller.thing().color))),
                    title: Text('心情色')),
              ]).px8())
        ]).scrollVertical(),
        floatingActionButton: Obx(() => FloatingActionButton(
              tooltip: '保存',
              onPressed: createOrEdit,
              backgroundColor: Color(controller.thing().color),
              child: Icon(Icons.check),
            )));
  }
}
