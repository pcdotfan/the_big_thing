import 'dart:convert';

import 'package:the_big_thing/entities/thing.dart';
import 'package:get/route_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ScanQRCodePage extends StatefulWidget {
  ScanQRCodePage({Key key}) : super(key: key);

  @override
  ScanQRCodePageState createState() => ScanQRCodePageState();
}

class ScanQRCodePageState extends State<ScanQRCodePage> {
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    controller.pauseCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('导入大事记'), backgroundColor: Vx.black),
        body: VStack(
          [Expanded(flex: 4, child: _buildQrView(context))],
        ).hFull(context));
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          Future.microtask(
              () => controller?.updateDimensions(qrKey, scanArea: scanArea));
          return false;
        },
        child: SizeChangedLayoutNotifier(
            key: const Key('qr-size-notifier'),
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 0,
                borderLength: 15,
                borderWidth: 5,
                cutOutSize: scanArea,
              ),
            )));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      try {
        Thing scannedThing = Thing.fromJson(
            jsonDecode(utf8.decode(base64Decode(scanData.code))));
        scannedThing.folderId = int.parse(Get.arguments);
        Get.back<Thing>(result: scannedThing);
      } catch (e) {}
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
