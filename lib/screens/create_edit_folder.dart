import 'dart:convert';

import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:hive/hive.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter/material.dart';
import 'package:the_big_thing/utils/icon_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;

Future<ui.Image> _loadImage(String url) async {
  final _image = await rootBundle.load(url);
  final bg = await ui.instantiateImageCodec(_image.buffer.asUint8List());
  final frame = await bg.getNextFrame();
  final img = frame.image;
  return img;
}

class CreateEditFolderPage extends StatefulWidget {
  CreateEditFolderPage({Key key}) : super(key: key);

  @override
  CreateEditFolderPageState createState() => CreateEditFolderPageState();
}

class CreateEditFolderPageState extends State<CreateEditFolderPage> {
  ByteData byteData;
  Box<Folder> foldersBox;
  final _formKey = new GlobalKey<FormState>();
  bool isEditMode = false;
  var folder = new Folder('', '', Colors.black.value, 'favorite', 0, false).obs;
  int folderKey = -1;

  @override
  void initState() {
    super.initState();
    foldersBox = Hive.box('folders');
    isEditMode = Get.arguments is Folder;
    if (this.isEditMode) {
      folder.update((f) {
        f.name = Get.arguments.name;
        f.sticky = Get.arguments.sticky;
        f.desc = Get.arguments.desc;
        f.color = Get.arguments.color;
        f.icon = Get.arguments.icon;
      });
      folderKey = Get.arguments.key;
    }
    drawImage();
  }

  void drawImage() async {
    var _sketchFolder = await _loadImage('assets/sketch-folder.jpg');
    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(
        recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(1200, 1477)));
    canvas.drawImage(_sketchFolder, Offset.zero, Paint());

    ui.ParagraphBuilder centerBottomTitlePb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            fontWeight: FontWeight.bold,
            fontSize: 80,
            textAlign: TextAlign.center,
            fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(folder.value.name);
    canvas.drawParagraph(
        centerBottomTitlePb.build()
          ..layout(ui.ParagraphConstraints(width: 1075)),
        Offset(60, 780));

    ui.ParagraphBuilder descPb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 58,
        ellipsis: '...',
        maxLines: 3,
        textAlign: TextAlign.left,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(folder.value.desc);
    canvas.drawParagraph(
        descPb.build()..layout(ui.ParagraphConstraints(width: 1025)),
        Offset(110, 1000));

    ui.ParagraphBuilder bottomRightPb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 42,
        textAlign: TextAlign.left,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText('大事发生');
    canvas.drawParagraph(
        bottomRightPb.build()..layout(ui.ParagraphConstraints(width: 1025)),
        Offset(920, 1340));

    final picture = recorder.endRecording();
    final png = await picture.toImage(1200, 1477);
    final pngBytedata = await png.toByteData(format: ui.ImageByteFormat.png);
    setState(() {
      byteData = pngBytedata;
    });
  }

  void createOrEdit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (isEditMode) {
        // 编辑模式
        Folder currentFolder = foldersBox.get(folderKey);
        if (currentFolder.isInBox) {
          currentFolder.name = folder().name;
          currentFolder.desc = folder().desc;
          currentFolder.sticky = folder().sticky;
          currentFolder.color = folder().color;
          currentFolder.icon = folder().icon;
          await currentFolder.save();
        }
      } else {
        await foldersBox.add(folder());
      }
      _formKey.currentState.reset();
      Get.back();
      showMessage("记事录已${this.isEditMode ? '更新' : '创建'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("${isEditMode ? '编辑' : '新增'}记事录"),
            backgroundColor: Color(folder.value.color)),
        body: VStack([
          Container(
            height: MediaQuery.of(context).size.width * 1.23,
            child: byteData != null
                ? Image.memory(byteData.buffer.asUint8List())
                : null,
          ),
          Form(
              key: _formKey,
              child: VStack([
                ListTile(
                    leading: Icon(Icons.announcement_outlined).py8(),
                    title: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          drawImage();
                        }
                      },
                      child: Obx(() => TextFormField(
                            initialValue: folder().name,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '记事录怎么能没有标题呢';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              folder.update((f) {
                                f.name = value;
                              });
                            },
                            decoration: new InputDecoration(labelText: '给个标题'),
                          )),
                    )),
                ListTile(
                    leading: Icon(Icons.title_outlined).py8(),
                    title: Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            drawImage();
                          }
                        },
                        child: Obx(() => TextFormField(
                              initialValue: folder().desc,
                              onChanged: (value) {
                                folder.update((f) {
                                  f.desc = value;
                                });
                              },
                              decoration:
                                  new InputDecoration(labelText: '写句话呗'),
                            )))),
                Obx(() => SwitchListTile(
                    value: folder().sticky,
                    secondary: Icon(Icons.arrow_upward_outlined).py8(),
                    onChanged: (value) {
                      folder.update((f) {
                        f.sticky = value;
                      });
                    },
                    title: Text('置顶'))),
                ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(''),
                            content: SingleChildScrollView(
                                child: Obx(
                              () => BlockPicker(
                                pickerColor: Color(folder().color),
                                onColorChanged: (Color color) {
                                  folder.update((f) {
                                    f.color = color.value;
                                  });
                                  context.pop();
                                },
                              ),
                            )),
                          );
                        },
                      );
                    },
                    leading: SizedBox()
                        .p12()
                        .backgroundColor(Color(folder.value.color)),
                    title: Text('心情色')),
                Obx(() => IconPicker(
                      initialValue: folder().icon,
                      icon: Icon(Icons.favorite),
                      labelText: '图标',
                      title: '选择图标',
                      cancelBtn: '取消',
                      enableSearch: true,
                      searchHint: '搜索图标',
                      onChanged: (val) {
                        final iconDataJson = jsonDecode(val);
                        folder.update((f) {
                          f.icon = iconDataJson['iconName'];
                        });
                      },
                      onSaved: (val) {
                        final iconDataJson = jsonDecode(val);
                        folder.update((f) {
                          f.icon = iconDataJson['iconName'];
                        });
                      },
                    )),
              ]).px8())
        ]).scrollVertical(),
        floatingActionButton: Obx(() => FloatingActionButton(
              tooltip: '保存',
              onPressed: createOrEdit,
              backgroundColor: Color(folder().color),
              child: Icon(Icons.check).py8(),
            )));
  }
}
