import 'dart:convert';
import 'dart:io';

import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/entities/thing.dart';
import 'package:the_big_thing/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/route_manager.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qr_flutter/qr_flutter.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ThingDetailPage extends StatefulWidget {
  ThingDetailPage({Key key}) : super(key: key);

  @override
  ThingDetailPageState createState() => ThingDetailPageState();
}

class ThingDetailPageState extends State<ThingDetailPage> {
  Box<Thing> thingsBox;
  Box<Folder> foldersBox;
  ByteData byteData;
  Thing thing = Thing('', '', Colors.black.value, DateTime.now(), false, 0);
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _player = AudioPlayer();
  String leftTop1, leftTop2, rightTop1, rightTop2;

  void playNotificationAudio() async {
    if (!thing.audioPath.isEmptyOrNull) {
      await _player.setFilePath(thing.audioPath);
      await _player.setClip(
          start: Duration(seconds: 0), end: Duration(seconds: 20));
      _player.play();
    }
  }

  @override
  void initState() {
    super.initState();
    thingsBox = Hive.box('things');
    foldersBox = Hive.box('folders');
    thing = thingsBox.get(int.parse(Get.parameters['id']));

    if (thing == null) {
      Get.offAllNamed('/not-found');
    } else {
      if (thing.dueDate.difference(DateTime.now()).inSeconds < 0) {
        playNotificationAudio(); // 过期则销毁提醒
        flutterLocalNotificationsPlugin.cancel(int.parse(Get.parameters['id']));
      }
      setCalendarDay(new DateFormat('yyyy-M-D').format(thing.dueDate))
          .then((value) {
        renderImage();
      });
    }
  }

  Future<void> setCalendarDay(String date) async {
    try {
      Response response = await Dio().get(
          "http://v.juhe.cn/calendar/day?date=$date&key=4708f21049366ef4c6872aa9b0a80799");
      final data = response.data;
      if (data['reason'] == 'Success') {
        final calendarData = data['result']['data'];
        setState(() {
          leftTop1 = calendarData['weekday'];
          leftTop2 = calendarData['holiday'].toString().isEmptyOrNull
              ? '普通一天'
              : calendarData['holiday'];
          rightTop1 = "农历 ${calendarData['lunar']}";
          rightTop2 = calendarData['lunarYear'];
        });
      }
    } catch (e) {
      showMessage('该功能需要网络连接才能正常使用。', success: false);
    }
  }

  Future<ui.Image> _loadImage(String url) async {
    final _image = await rootBundle.load(url);
    final bg = await ui.instantiateImageCodec(_image.buffer.asUint8List());
    final frame = await bg.getNextFrame();
    final img = frame.image;
    return img;
  }

  Future<void> renderImage() async {
    ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: 1200);
    final img = await _loadImage('assets/sketch.jpg');
    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(
        recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(1200, 1800)));
    canvas.drawImage(img, Offset.zero, Paint());

    // 日期
    ui.ParagraphBuilder leftTopDatePb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.bold,
        fontSize: 100,
        ellipsis: '...',
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(DateFormat('MM.dd').format(thing.dueDate).toString());
    canvas.drawParagraph(leftTopDatePb.build()..layout(pc), Offset(60, 105));

    // 日期上
    ui.ParagraphBuilder topLeftLunar1Pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 38,
        ellipsis: '...',
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(leftTop1);
    canvas.drawParagraph(topLeftLunar1Pb.build()..layout(pc), Offset(340, 130));

    // 日期下
    ui.ParagraphBuilder topLeftLunar2Pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 38,
        ellipsis: '...',
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(leftTop2);
    canvas.drawParagraph(topLeftLunar2Pb.build()..layout(pc), Offset(340, 180));

    // 日期上
    ui.ParagraphBuilder topRightLunar1Pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            fontWeight: FontWeight.normal,
            textAlign: TextAlign.right,
            ellipsis: '...',
            fontSize: 38,
            fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(rightTop1);
    canvas.drawParagraph(
        topRightLunar1Pb.build()..layout(pc), Offset(-60, 130));

    // 日期上
    ui.ParagraphBuilder topRightLunar2Pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            fontWeight: FontWeight.normal,
            textAlign: TextAlign.right,
            ellipsis: '...',
            fontSize: 38,
            fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(rightTop2);
    canvas.drawParagraph(
        topRightLunar2Pb.build()..layout(pc), Offset(-60, 180));

    ui.ParagraphBuilder centerTitlePb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.bold,
        ellipsis: '...',
        fontSize: 550,
        textAlign: TextAlign.center,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(thing.dueDate.difference(DateTime.now()).inDays.toString());
    canvas.drawParagraph(
        centerTitlePb.build()..layout(ui.ParagraphConstraints(width: 1075)),
        Offset(60, 300));

    ui.ParagraphBuilder centerBottomTitlePb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
            fontWeight: FontWeight.bold,
            ellipsis: '...',
            fontSize: 80,
            textAlign: TextAlign.center,
            fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(thing.name);
    canvas.drawParagraph(
        centerBottomTitlePb.build()
          ..layout(ui.ParagraphConstraints(width: 1075)),
        Offset(60, 1000));

    ui.ParagraphBuilder descPb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 58,
        ellipsis: '...',
        maxLines: 3,
        textAlign: TextAlign.left,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(thing.content);
    canvas.drawParagraph(
        descPb.build()..layout(ui.ParagraphConstraints(width: 1025)),
        Offset(110, 1220));

    ui.ParagraphBuilder bottomRightPb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 42,
        textAlign: TextAlign.left,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText('大事发生');
    canvas.drawParagraph(
        bottomRightPb.build()..layout(ui.ParagraphConstraints(width: 1025)),
        Offset(920, 1580));

    ui.ParagraphBuilder bottomLeftPb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontWeight: FontWeight.normal,
        fontSize: 42,
        textAlign: TextAlign.left,
        fontFamily: 'SourceHanSerifCN'))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText('工作');
    canvas.drawParagraph(
        bottomLeftPb.build()..layout(ui.ParagraphConstraints(width: 1025)),
        Offset(110, 1580));

    final picture = recorder.endRecording();
    final png = await picture.toImage(1200, 1800);
    ByteData data = await png.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      byteData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('大事发生'),
        backgroundColor: Color(thing.color),
        actions: [
          IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                final backThing =
                    await Get.toNamed('/things/create-edit', arguments: thing);
                thing = backThing;
                renderImage();
              }),
          IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                AlertDialog alert = AlertDialog(
                  title: Text("确认删除"),
                  content: Text("此操作不可逆，是否继续？"),
                  actions: [
                    FlatButton(
                      child: Text("取消"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("确定",
                          style: TextStyle(color: Color(thing.color))),
                      onPressed: () async {
                        final folder = foldersBox.get(thing.folderId);
                        folder.count -= 1;
                        folder.save();
                        thingsBox.delete(int.parse(Get.parameters['id']));
                        flutterLocalNotificationsPlugin
                            .cancel(int.parse(Get.parameters['id']));
                        Navigator.pop(context);
                        Get.offNamed('/folders/' + thing.folderId.toString());
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
              })
        ],
      ),
      body: VStack(
        [
          Center(
              child: byteData != null
                  ? Image.memory(byteData.buffer.asUint8List())
                  : CircularProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation(Colors.blueGrey))
                      .py24()),
          HStack([
            QrImage(
              data: base64Encode(utf8.encode(jsonEncode(thing.toJson()))),
              version: QrVersions.auto,
              backgroundColor: Vx.white,
              size: 100.0,
              gapless: true,
            ),
            HStack([
              FlatButton(
                      color: Vx.black,
                      onPressed: () async {
                        final directory =
                            (await getExternalStorageDirectory()).path;
                        File imgFile =
                            File("$directory/bit_things_${thing.key}.png");
                        imgFile.writeAsBytesSync(byteData.buffer.asUint8List());
                        showMessage('海报已成功保存到本地');
                      },
                      child: '保存海报'.text.white.make())
                  .px12(),
              OutlineButton(
                  onPressed: () async {
                    final byteData = await QrPainter(
                      data:
                          base64Encode(utf8.encode(jsonEncode(thing.toJson()))),
                      version: QrVersions.auto,
                      gapless: true,
                    ).toImageData(100);
                    final directory =
                        (await getExternalStorageDirectory()).path;
                    File imgFile =
                        File("$directory/bit_things_${thing.key}_qrcode.png");
                    imgFile.writeAsBytesSync(byteData.buffer.asUint8List());
                    showMessage('二维码已成功保存到本地');
                  },
                  child: '下载二维码'.text.gray700.make())
            ]).px12(),
          ], alignment: MainAxisAlignment.spaceBetween)
              .wFull(context)
              .p12()
        ],
      ).hFull(context).p8().backgroundColor(Colors.white),
    );
  }
}
