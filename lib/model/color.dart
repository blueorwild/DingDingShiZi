import 'package:flutter/material.dart';

// 全局颜色配置

class AppColor{
  static const searchBoxBorderColor = Color.fromRGBO(19, 19, 96, 0.2);   // 所有搜索框的边框色
  static const commonBoxFillColor = Colors.white;   // 一般框的填充色
  static const commonIconColor = Color.fromRGBO(180, 180, 180, 1);   // 一般图标的颜色
  static const commonTextColor = Colors.black;  // 一般文字的颜色
  static const splitLineColor = Color.fromRGBO(180, 180, 180, 0.3);  // 分割线的颜色
  static const pointColor = Color.fromRGBO(220, 220, 220, 1);  // 未选中点的颜色
  static const unSelectTextColor = Color.fromRGBO(180, 180, 180, 1);   // 未选中文字/不突出文字的颜色
  static const studyProgressColor = Color.fromRGBO(19, 19, 96, 1);  // 主页学习进度文字/条颜色
  static const bgColor = Color.fromRGBO(244, 244, 244, 1);   // 主题背景的颜色
  // 对应下面的深蓝色、浅蓝色
  static const darkBlueButton = Color.fromRGBO(127, 200, 254, 1);    // 深蓝色按钮
  //static const lightBlueButton = Color.fromRGBO(236, 247, 255, 1);   // 浅蓝色按钮
  static const lightBlueButton = Color.fromRGBO(199, 240, 252, 1);   // 浅蓝色按钮
  static const darkRedButton = Color.fromRGBO(254, 120, 120, 1);   // 深红色按钮
  //static const darkBlueButton = Color.fromRGBO(188, 226, 254, 1);    // 深蓝色按钮
  //static const lightBlueButton = Color.fromRGBO(236, 247, 255, 1);   // 浅蓝色按钮

  // 按钮相关色
  static const baseCardTextColor = Colors.white;  // 基本卡片文字的颜色
  static const blueCardTextColor = Color.fromRGBO(127, 200, 254, 1);  // 卡片文字蓝色
  //static const darkYellow = Color.fromRGBO(255, 227, 94, 1);    // 深黄色
  static const darkYellow = Color.fromRGBO(255, 181, 1, 1);    // 深黄色
  static const lightYellow = Color.fromRGBO(252, 236, 18, 1);      // 浅黄色
  static const lightGreen = Color.fromRGBO(100, 232, 245, 1);    // 浅绿色
  static const darkGreen = Color.fromRGBO(122, 242, 136, 1);     // 深绿色
  //static const darkRed = Color.fromRGBO(254, 179, 160, 1);     // 深红色
  static const darkRed = Color.fromRGBO(255, 145, 128, 1);       // 深红色(例如主页学习图标)
  static const darkBlue = Color.fromRGBO(74, 146, 255, 1);       // 深蓝色(例如主页练习图标)
  static const commonBlue = Color.fromRGBO(127, 200, 254, 1);    // 中蓝色(例如已学会的字按钮色)
  static const lightBlue = Color.fromRGBO(236, 247, 255, 1);     // 浅蓝色(例如未学会的字按钮色)
    // ZDB:
  static const userBg = Color.fromARGB(100, 222, 252, 252);
  static const lightPink = Color.fromRGBO(254,205,192, 1);     // 淡粉色   记录字界面错字词背景颜色
  // ZDB：删除按钮色 谷歌浏览器的插件<color picker>可以提取颜色，RGB opacity：透明度。
  static const deleteButtonBgColor = Color.fromRGBO(254,217,207,1); // 删除按钮背景色
  static const deleteButtonTextColor = Color.fromRGBO(224, 132, 158, 1); // 删除按钮文字颜色
  static const recordFontColor = Colors.white;
}
