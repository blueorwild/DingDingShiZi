
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/home_data.dart';

import 'package:flutterapp/model/text_detail_data.dart';
import 'package:flutterapp/model/study_data.dart';
import 'package:flutterapp/model/practice_data.dart';



class HomePage extends StatefulWidget{
  @override
  createState() => new _HomePageState();
}

BuildContext homePageContext;
class _HomePageState extends State<HomePage>{

  var textController = TextEditingController();  // 文本输入框相关

  // 获取学习进度信息
  void getStudyProgress() async {
    final response = await http.post('http://120.24.151.180:8080/api/learn/get_study_progress?userId=' + userId);
    if (response.statusCode == 200) {

      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data ;
      if(status['status'] != 200){
        alert(homePageContext, status['msg']);
        return;
      }
      setState(() {
        hdCurrentTextbookName = StudyProgress.fromJson(data).currentTextbookName;
        hdNumLearntWords = StudyProgress.fromJson(data).numLearntWords;
        hdNumTotalWords = StudyProgress.fromJson(data).numTotalWords;
        if(hdCurrentTextbookName == null) hdCurrentTextbookName = "无";
      });
    }
    else alert(homePageContext, "网络连接失败");
  }

  // 获取所有教材的名字
  void getTextbookName() async{
    final response = await http.post('http://120.24.151.180:8080/api/common/get_textbook_names');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] != 200){
        alert(homePageContext, status['msg']);
        return;
      }
      else setState(() {
        hdAllTextbookName = HdTextbookName.fromJson(data).names;
      });
    }
    else alert(homePageContext, "网络连接失败");
  }

  // 获取学习界面的数据
  void getStudy(){
    if(hdAllTextbookName.length == 0){
      alert(homePageContext, "获取教材信息失败");
      return;
    }
    else if(hdCurrentTextbookName == '无' || hdCurrentTextbookName == null)
      sdTextbookName = hdAllTextbookName[0];
    else sdTextbookName = hdCurrentTextbookName;
    sdTextbookNames = hdAllTextbookName;
    Navigator.pushReplacementNamed(homePageContext, studyPage);
  }

  // 获取练习界面的数据
  void getPractice(){
    pdCurrentTextbookName = hdCurrentTextbookName;
    Navigator.pushReplacementNamed(homePageContext, practicePage);
  }

  @override
  void initState(){
    super.initState();
    getStudyProgress();
    getTextbookName();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  //  ---------------------------------展示的界面-------------------------------
  @override
  Widget build(BuildContext context) {
    homePageContext = context;
    // 获取设备尺寸(只在首页赋值一次)
    var device = MediaQuery.of(context);
    deviceWidth = device.size.width;
    deviceHeight = device.size.height;
    devicePaddingTopRate = device.padding.top / device.size.height;
    devicePaddingBottomRate = device.padding.bottom / device.size.height;

    return new Scaffold(
      // 页面是个大container，个人习惯
      resizeToAvoidBottomInset: false,  // 防止底部键盘弹出挤压页面变形
      body:WillPopScope(  // 捕捉设备的真实返回键
        onWillPop: () async => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确定要退出程序吗？'),
            actions: <Widget>[
              RaisedButton(
                child: Text('退出'),
                onPressed: () => Navigator.of(context).pop(true)),
              RaisedButton(
                child: Text('取消'),
                onPressed: () => Navigator.of(context).pop(false)),
           ],
          ),
        ),
        child: Container(
          alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('assets/images/bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          width: deviceWidth,   // 其实是默认的
          height: deviceHeight,
          child: new Column(
            // 子组件放在开始位置
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 第一行 搜索框
              Container(
                alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.01),
                margin: EdgeInsets.fromLTRB(0, deviceHeight*(devicePaddingTopRate + 0.02), 0, 0),
                width: deviceWidth*0.8,
                height: deviceHeight*0.06,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: AppColor.searchBoxBorderColor),
                  color: AppColor.commonBoxFillColor,
                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.03)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    // 放大镜图标
                    Icon(
                      Icons.search,
                      color: AppColor.commonIconColor,
                      size: deviceWidth*0.07,
                    ),

                    // 文本输入域
                    Container(
                      alignment: Alignment.center,
                      width: deviceWidth*0.5,
                      height: deviceHeight*0.06,
                      child: TextField(
                        controller: textController,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColor.commonTextColor,
                          fontSize: deviceWidth*0.04,
                        ),
                        decoration: InputDecoration(
                          hintText: "请输入你要查询的字",
                          hintStyle: TextStyle(
                            color: AppColor.unSelectTextColor,
                          ),
                          border:InputBorder.none,
                          contentPadding: EdgeInsets.all(0),
                          // 为了使提示文本居中
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        onSubmitted: (String text){
                          if(text == '') alert(context, "输入为空！");
                          else {
                            tddParentPage = 'homePage';
                            tddCurCharacter = text;
                            Navigator.pushReplacementNamed(homePageContext, textDetailPage);
                          }
                        },
                      ),
                    ),

                    // 搜索按钮
                    IconButton(
                      padding: EdgeInsets.all(0),   // 默认8.0
                      icon: new Icon(
                        Icons.arrow_forward,
                        color: AppColor.commonIconColor,
                        size: deviceWidth*0.07,
                        textDirection: TextDirection.ltr,
                      ),
                      onPressed:() {
                        String text = textController.text;
                        if(text == '') alert(context, "输入为空！");
                        else {
                          tddParentPage = 'homePage';
                          tddCurCharacter = text;
                          Navigator.pushReplacementNamed(homePageContext, textDetailPage);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // 第二行 学习进度文本
              Container(
                alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                margin: EdgeInsets.fromLTRB(0, deviceHeight*0.01, 0, 0),
                height: deviceHeight*0.06,
                child: Text.rich(
                  TextSpan(
                    children:[
                      TextSpan(
                        text: "学习进度 ",
                        style:TextStyle(
                          color:AppColor.commonTextColor,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: hdNumLearntWords.toString() + ' / ' + hdNumTotalWords.toString(),
                        style:TextStyle(
                          color: AppColor.studyProgressColor,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: " 字（" + hdCurrentTextbookName + "）",
                        style:TextStyle(
                          color:AppColor.commonTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 第三行 学习进度条
              Container(
                //----------------------------------------------条条应该在的位置------头部----前面内容的高度---本身高度的一半----
                margin: EdgeInsets.only(top:deviceHeight*(156/812 - devicePaddingTopRate - 0.15 - 0.003)),
                height: deviceHeight*0.006,
                width: deviceWidth * hdNumLearntWords / (hdNumTotalWords == 0?1:hdNumTotalWords),
                color: AppColor.studyProgressColor,
              ),

              // 第四行 跳转功能按钮
              Container(
                height: deviceHeight*0.63,   // 目前有三行，每行高0.21
                width: deviceWidth,
                //color: Color.fromRGBO(19, 19, 96, 1),
                child: Table(  // 行高默认元素高度，列宽默认均分
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        children: [
                          // 学习+记录按钮
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.import_contacts, AppColor.darkRed, '学  习',getStudy),
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.collections, AppColor.lightGreen, '记  录',null),
                        ]
                    ),
                    TableRow(
                        children: [
                          // 练习+专栏按钮
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.edit, AppColor.darkBlue, '练  习',getPractice),
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.wb_incandescent, AppColor.darkYellow, '专  栏',
                                  ()=> Navigator.pushNamed(context, specialColumnPage)),
                        ]
                    ),
                    TableRow(
                        children: [
                          Container(
                            width: deviceWidth*0.3,
                            height: deviceHeight*0.17,
                            margin: EdgeInsets.symmetric(vertical: deviceHeight*0.02),
                          ),
                          // 用户按钮
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.account_circle, AppColor.darkGreen, '用  户',null),
                        ]
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 获取一个图片按钮（为了省代码）
Widget getPictureButton(double width, double height, IconData icon, Color iconColor, String text, void func()){
  return Container(
    alignment: Alignment(0,0),
    margin: EdgeInsets.symmetric(vertical: height*0.13, horizontal: width*0.42),
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

