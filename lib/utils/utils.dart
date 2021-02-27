import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:velocity_x/velocity_x.dart';

// class AudioPlayerTask extends BackgroundAudioTask {
//   final _player = AudioPlayer();

//   onStart(Map<String, dynamic> params) async {

//   }

//   onPlay() => _player.play();
//   onPause() => _player.pause();
//   onSetSpeed(double speed) => _player.setSpeed(speed);
// }

void showMessage(String message, {bool success = true}) {
  Get.snackbar(success ? '成功' : '失败', message, // title
      icon: Icon(
        success ? Icons.check : Icons.error_outline,
        color: Vx.white,
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
      duration: Duration(milliseconds: 1200),
      backgroundColor: Vx.gray900,
      colorText: Vx.white);
}
