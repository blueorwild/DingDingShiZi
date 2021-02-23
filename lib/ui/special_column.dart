import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/color.dart';

class SpecialColumnPage extends StatefulWidget{
  @override
  createState() => new _SpecialColumnPageState();
}

var specialColumnPageContext;

class _SpecialColumnPageState extends State<SpecialColumnPage>{


  // 获取易错字音
  void getFallibleCharacter(){
    Navigator.pushNamed(specialColumnPageContext, fallibleCharacterPage);
  }
  // 获取易错词音
  void getFallibleWord() {
    Navigator.pushNamed(specialColumnPageContext, fallibleWordPage);
  }

  // 获取易错语义
  void getFallibleMeaning() {
    Navigator.pushNamed(specialColumnPageContext, fallibleMeaningPage);
  }

  @override
  void initState(){
    super.initState();
  }

  //  ---------------------------------展示的界面-------------------------------
  @override
  Widget build(BuildContext context) {
    specialColumnPageContext = context;

    return new Scaffold(
      // 页面是个大container，个人习惯
      body: Container(
        alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
        decoration: BoxDecoration(
          color: AppColor.bgColor,
        ),
        width: deviceWidth,   // 其实是默认的
        height: deviceHeight,
        child: new Column(
          // 子组件放在开始位置
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 返回按钮
            Container(
              alignment: Alignment(-1, 0),  // x/y,-1~+1,(0,0)表示正中
              margin: EdgeInsets.only(top: deviceHeight*(devicePaddingTopRate + 0.02)),
              height: deviceHeight*0.06,
              // 返回按钮
              child: IconButton(
                padding: EdgeInsets.all(0),   // 默认8.0
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColor.commonIconColor,
                  size: deviceWidth*0.07,
                ),
                onPressed:()=>Navigator.pop(context),
              ),
            ),

            // 第二行 跳转功能按钮
            Container(
              height: deviceHeight*0.42,   // 目前有两行，每行高0.21
              width: deviceWidth*0.8,
              //color: Color.fromRGBO(19, 19, 96, 1),
              child: Table(  // 行高默认元素高度，列宽默认均分
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      children: [
                        // 生僻字+生僻词按钮
                        getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.format_color_text, AppColor.darkRed, '易错字音', getFallibleCharacter),
                        getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.restaurant_menu, AppColor.lightGreen, '易错词音', getFallibleWord),
                      ]
                  ),
                  TableRow(
                      children: [
                        // 生僻俗语按钮
                        getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.palette, AppColor.darkBlue, '易错语义', getFallibleMeaning),
                        Container(
                          width: deviceWidth*0.3,
                          height: deviceHeight*0.17,
                          margin: EdgeInsets.symmetric(vertical: deviceHeight*0.02),
                        ),
                      ]
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 获取一个图片按钮（为了省代码）
Widget getPictureButton(double width, double height, IconData icon, Color iconColor, String text, void func()){
  return Container(
    alignment: Alignment(0,0),
    margin: EdgeInsets.symmetric(vertical: height*0.13, horizontal: width*0.25),
    width: width,   // 貌似没用
    height: height,
    decoration: BoxDecoration(
      color: AppColor.commonBoxFillColor,
      borderRadius: new BorderRadius.all(new Radius.circular(3)),
    ),
    child: FlatButton(
      padding: EdgeInsets.all(0),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[
          Icon(icon,
            color: iconColor,
            size: width*0.6,
          ),
          Text(text,
            style: TextStyle(
              color: AppColor.commonTextColor,
              fontSize: width*0.15,
            ),
          ),
        ],
      ),
      onPressed:() => func(),
    ),
  );
}