import 'package:get/route_manager.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  NotFoundPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  NotFoundPageState createState() => NotFoundPageState();
}

class NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('大事发生'),
      ),
      body: VStack([
        Center(child: '无大事发生'.text.gray700.xl6.make()).p24(),
        OutlineButton(
                onPressed: () => Get.offAllNamed('/'),
                child: '返回'.text.gray700.make())
            .centered()
      ]).objectCenter(),
    );
  }
}
