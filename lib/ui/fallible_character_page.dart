
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/fallible_character_data.dart';
import 'package:flutterapp/model/fallible_detail_data.dart';



class FallibleCharacterPage extends StatefulWidget{
  @override
  createState() => new _FallibleCharacterPageState();
}

var fallibleCharacterPageContext;

class _FallibleCharacterPageState extends State<FallibleCharacterPage>{

  // 根据每行放的字数计算字卡片的宽度
  static int numPerCol = 4;
  double textCardWidth = deviceWidth*((0.9-numPerCol*2*0.02) / numPerCol);

  int curView = 0;  // 0:显示所有  1:显示已会 2:显示未学
  List curText = fcdCharacterDetail.all;  // 当前显示的字内容

  // 获取易错字
  void getFallibleCharacter() async {
    final response = await http.post('http://120.24.151.180:8080/api/column/get_fallible_characters?userId=' + userId);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200)setState(() {
        fcdCharacterDetail = FcdCharacterDetail.fromJson(data);
        curText = fcdCharacterDetail.all;
      });
      else alert(context, status['msg']);
    }
    else alert(fallibleCharacterPageContext, "网络连接失败");
  }

  // 跳转到文本详情页
  void getTextDetail(String text) {
    if(curView == 0) fddAllText = fcdCharacterDetail.all;
    else if(curView == 1) fddAllText = fcdCharacterDetail.learnt;
    else fddAllText = fcdCharacterDetail.unLearnt;

    fddText = text;
    fddCurTextIndex = fddAllText.indexOf(text);
    fddAllLearnt = fcdCharacterDetail.learnt;
    fddParentPage = "character";
    Navigator.pushReplacementNamed(fallibleCharacterPageContext, fallibleDetailPage);
  }

  @override
  void initState(){
    super.initState();
    getFallibleCharacter();
  }

  @override
  Widget build(BuildContext context) {
    fallibleCharacterPageContext = context;
    return Scaffold(
      // 页面是个大container
      body: Container(
        alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
        decoration: BoxDecoration(
          color: AppColor.bgColor,
        ),
        width: deviceWidth,   // 其实是默认的
        height: deviceHeight,
        child: Column(
          // 子组件放在开始位置
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 第一行，返回按钮+主页按钮
            Container(
              margin: EdgeInsets.only(top: deviceHeight*(devicePaddingTopRate + 0.01)),
              height: deviceHeight*0.06,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  // 返回按钮
                  IconButton(
                    padding: EdgeInsets.all(0),   // 默认8.0
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColor.commonIconColor,
                      size: deviceWidth*0.07,
                      textDirection: TextDirection.ltr,
                    ),
                    onPressed:()=>Navigator.pop(context),
                  ),
                  // 主页按钮
                  IconButton(
                    padding: EdgeInsets.all(0),   // 默认8.0
                    icon: Icon(
                      Icons.home,
                      color: AppColor.commonIconColor,
                      size: deviceWidth*0.07,
                    ),
                    onPressed:() => Navigator.pushNamedAndRemoveUntil(context, homePage, (Route<dynamic> route) => false),
                  ),
                ],
              ),
            ),

            // 第二行 易错文字内容
            Container(
              alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
              margin: EdgeInsets.only(top:deviceHeight*0.015),
              padding: EdgeInsets.symmetric(vertical: deviceHeight*0.015),
              height: deviceHeight*0.75,
              width: deviceWidth*0.9,
              decoration: BoxDecoration(
                color: AppColor.commonBoxFillColor,
                borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.015)),
              ),
              child:Scrollbar(  // 滑动条
                child: SingleChildScrollView( // 单个滑动窗口
                  //reverse: false,
                  padding: EdgeInsets.all(0.0),
                  physics: BouncingScrollPhysics(),
                  child:Wrap(  // 自动换行的流式布局
                    children:curText.map<Widget>((item) => Container(
                      margin: EdgeInsets.all(deviceWidth*0.02),
                      alignment: Alignment.center,
                      height: textCardWidth,
                      width: textCardWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: fcdCharacterDetail.learnt.contains(item)?AppColor.commonBlue:AppColor.lightBlue,
                      ),
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        child: Text(item,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: deviceWidth*0.1,
                            color: fcdCharacterDetail.learnt.contains(item)?AppColor.baseCardTextColor:AppColor.blueCardTextColor,
                          ),
                        ),
                        onPressed: () => getTextDetail(item),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),

            // 第三行 两个按钮
            Container(
              margin:EdgeInsets.only(top: deviceHeight*0.01),
              height: deviceHeight*0.1,
              width: deviceWidth*0.9,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  // 未学会按钮
                  Container(
                    alignment: Alignment.center,
                    height: deviceHeight*0.056,
                    width: deviceWidth*0.3,
                    decoration: BoxDecoration(
                      color: AppColor.darkBlueButton,
                      borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                    ),
                    child:FlatButton(
                      padding: EdgeInsets.all(0),   // 默认值
                      child:Text(curView == 2?"显示所有":"显示未学会",
                        style: TextStyle(
                          color: AppColor.baseCardTextColor,
                          fontSize: deviceWidth*0.04,
                        ),
                      ),
                      onPressed: () => setState(() {
                        if(curView == 2){
                          curView = 0;
                          curText = fcdCharacterDetail.all;
                        }
                        else{
                          curView = 2;
                          curText = fcdCharacterDetail.unLearnt;
                        }
                      }),
                    ),
                  ),

                  // 已学会按钮
                  Container(
                    alignment: Alignment.center,
                    height: deviceHeight*0.056,
                    width: deviceWidth*0.3,
                    decoration: BoxDecoration(
                      color: AppColor.darkBlueButton,
                      borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                    ),
                    child:FlatButton(
                      padding: EdgeInsets.all(0),   // 默认值
                      child:Text(curView == 1?"显示所有":"显示已学会",
                        style: TextStyle(
                          color: AppColor.baseCardTextColor,
                          fontSize: deviceWidth*0.04,
                        ),
                      ),
                      onPressed: () => setState(() {
                        if(curView == 1){
                          curView = 0;
                          curText = fcdCharacterDetail.all;
                        }
                        else{
                          curView = 1;
                          curText = fcdCharacterDetail.learnt;
                        }
                      }),
                    ),
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
