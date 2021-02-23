

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String userId = '000';
FlutterTts tts = FlutterTts();   // 播放声音的东西

// 播放字音
void playSound(String text) async {
  tts.speak(text);
}

// 字音相关属性设置
void setVoice() async {
  await tts.setLanguage("zh-CN");
  await tts.setSpeechRate(0.5);
  await tts.setVolume(1.0);
  await tts.setPitch(0.65);
}


// 弹出警告
void alert(BuildContext context, String text) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(text),
        actions: [
          FlatButton(
            child: Text("确定"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      );
    },
  );
}
