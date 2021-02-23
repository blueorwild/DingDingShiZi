
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/dictate_data.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/select_word_data.dart';

class SelectWordPage extends StatefulWidget{
  @override
  createState() => new _SelectWordPageState();
}

var selectWordPageContext;

class _SelectWordPageState extends State<SelectWordPage>{

  List curSelectedWord = swdCourseDetail.unPracticedWords;    // 当前选中的词
  bool isAllSelected = false;   // 是否按下全选按钮
  bool isErrorSelected = false;   // 是否按下错误按钮
  bool isUnlearntSelected = true;   // 是否按下未练按钮

  // 获取课文词语
  void getTextWord() async{
    final response = await http.post('http://120.24.151.180:8080/api/record/get_course_info?userId=' + userId +
        '&textbookName=' + swdTextbookName + '&courseName=' + swdCourseName);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) setState(() {
        swdCourseDetail = SwdCourseDetail.fromJson(data);
      });
      else alert(selectWordPageContext, status['msg']);
    }
    else alert(selectWordPageContext, "网络连接失败");

  }

  // 开始听写
  void startDictate(){
    if(curSelectedWord.isEmpty) alert(selectWordPageContext, '请选择要听写的词语！');
    else {
      ddAllWord = curSelectedWord;
      ddTextName = [];
      ddTextbookName = [];
      for(int i = 0; i < ddAllWord.length; ++i){
        ddTextName.add(swdCourseName);
        ddTextbookName.add(swdTextbookName);
      }
      ddParentPage = 'textOrder';
      Navigator.pushReplacementNamed(selectWordPageContext, dictatePage);
    }
  }

  @override
  void initState(){
    super.initState();
    swdCourseDetail = SwdCourseDetail.origin();
    getTextWord();
  }

  @override
  Widget build(BuildContext context) {
    selectWordPageContext = context;
    return Scaffold(
      // 页面是个大container
      body: WillPopScope(
        onWillPop: ()async{
          Navigator.pushReplacementNamed(context, textOrderPage);
          return true;
        },
        child:Container(
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
              // 返回按钮+主页按钮
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
                      onPressed:()=>Navigator.pushReplacementNamed(context, textOrderPage),
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

              // 几种选择方式
              Container(
                alignment: Alignment(0,0),
                height: deviceHeight*0.04,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 全选
                    Container(
                      alignment: Alignment(-1,0),
                      width: deviceWidth*0.18,
                      child: Stack(  // Icon和文字离的有点远
                        children: [
                          // 文字
                          Container(
                            alignment: Alignment(0,0),
                            width: deviceWidth*0.1,
                            child:Text('全选',
                              style: TextStyle(
                                fontSize: deviceWidth*0.035,
                                color: AppColor.commonTextColor,
                              ),
                            ),
                          ),

                          // 按钮
                          Container(
                            alignment: Alignment(0,0),
                            margin: EdgeInsets.only(left: deviceWidth*0.07),
                            width: deviceWidth*0.1,
                            child:IconButton(
                              padding: EdgeInsets.all(0),   // 默认8.0
                              icon: Icon(
                                Icons.check_circle,
                                color: isAllSelected ? AppColor.darkBlue : AppColor.commonIconColor,
                                size: deviceWidth*0.05,
                              ),
                              onPressed:() => setState(() {
                                curSelectedWord.clear();
                                if(isAllSelected) {
                                  isErrorSelected = false;
                                  isUnlearntSelected = false;
                                }
                                else {
                                  swdCourseDetail.words.forEach((element) { // 不要直接赋值。是赋的地址
                                    curSelectedWord.add(element);
                                  });
                                  isErrorSelected = true;
                                  isUnlearntSelected = true;
                                }
                                isAllSelected = !isAllSelected;

                              }),
                            ),
                          ),

                        ],
                      ),
                    ),

                    // 错误项
                    Container(
                      alignment: Alignment(-1,0),
                      width: deviceWidth*0.18,
                      child: Stack(  // Icon和文字离的有点远
                        children: [
                          // 文字
                          Container(
                            alignment: Alignment(0,0),
                            width: deviceWidth*0.1,
                            child:Text('错误',
                              style: TextStyle(
                                fontSize: deviceWidth*0.035,
                                color: AppColor.commonTextColor,
                              ),
                            ),
                          ),


                          // 按钮
                          Container(
                            alignment: Alignment(0,0),
                            margin: EdgeInsets.only(left: deviceWidth*0.07),
                            width: deviceWidth*0.1,
                            child:IconButton(
                              padding: EdgeInsets.all(0),   // 默认8.0
                              icon: Icon(
                                Icons.check_circle,
                                color: isErrorSelected ? AppColor.darkBlue : AppColor.commonIconColor,
                                size: deviceWidth*0.05,
                              ),
                              onPressed:() => setState(() {
                                // 先删除
                                swdCourseDetail.mistakenWords.forEach((element) {
                                  curSelectedWord.remove(element);
                                });
                                if(!isErrorSelected) swdCourseDetail.mistakenWords.forEach((element) {
                                  curSelectedWord.add(element);
                                });
                                isErrorSelected = !isErrorSelected;
                              }),
                            ),
                          ),

                        ],
                      ),
                    ),

                    // 未学
                    Container(
                      alignment: Alignment(-1,0),
                      width: deviceWidth*0.18,
                      child: Stack(  // Icon和文字离的有点远
                        children: [
                          // 文字
                          Container(
                            alignment: Alignment(0,0),
                            width: deviceWidth*0.1,
                            child:Text('未练',
                              style: TextStyle(
                                fontSize: deviceWidth*0.035,
                                color: AppColor.commonTextColor,
                              ),
                            ),
                          ),

                          // 按钮
                          Container(
                            alignment: Alignment(0,0),
                            margin: EdgeInsets.only(left: deviceWidth*0.07),
                            width: deviceWidth*0.1,
                            child:IconButton(
                              padding: EdgeInsets.all(0),   // 默认8.0
                              icon: Icon(
                                Icons.check_circle,
                                color: isUnlearntSelected ? AppColor.darkBlue : AppColor.commonIconColor,
                                size: deviceWidth*0.05,
                              ),
                              onPressed:() => setState(() {
                                // 先删除
                                swdCourseDetail.unPracticedWords.forEach((element) {
                                  curSelectedWord.remove(element);
                                });
                                if(!isUnlearntSelected) swdCourseDetail.unPracticedWords.forEach((element) {
                                  curSelectedWord.add(element);
                                });
                                isUnlearntSelected = !isUnlearntSelected;
                              }),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 词语内容
              Container(
                alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
                padding: EdgeInsets.symmetric(vertical: deviceHeight*0.015),
                height: deviceHeight*0.75,
                width: deviceWidth*0.9,
                decoration: BoxDecoration(
                  color: AppColor.commonBoxFillColor,
                  borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.015)),
                ),
                child:Scrollbar(
                  child: SingleChildScrollView(
                    //reverse: false,
                    padding: EdgeInsets.all(0.0),
                    physics: BouncingScrollPhysics(),
                    child:Wrap(  // 自动换行的流式布局
                      alignment: WrapAlignment.spaceBetween,
                      children:swdCourseDetail.words.map<Widget>((item) => Container(
                        margin: EdgeInsets.all(deviceWidth*0.01),
                        height: deviceWidth*0.12,
                        width: deviceWidth*0.095*item.length,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: swdCourseDetail.mistakenWords.contains(item) ? AppColor.darkRed:swdCourseDetail.unPracticedWords.contains(item)
                              ? AppColor.lightBlue:AppColor.commonBlue,
                        ),
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child: Stack(  // Stack 里面最好放Container包裹起来的保证位置正确
                            children: [
                              // 词语文字
                              Container(
                                alignment: Alignment.center,
                                child:Text(item,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: deviceWidth*0.06,
                                    color: swdCourseDetail.unPracticedWords.contains(item) ? AppColor.blueCardTextColor:AppColor.baseCardTextColor,
                                  ),
                                ),
                              ),

                              // 选中按钮
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: deviceWidth*(0.095*item.length - 0.05)),
                                height: deviceWidth * 0.05,
                                width: deviceWidth * 0.05,
                                child:IconButton(
                                  padding: EdgeInsets.all(0),   // 默认8.0
                                  icon:curSelectedWord.contains(item)? Icon(
                                    Icons.check_circle,
                                    color: AppColor.darkBlue,
                                    size: deviceWidth*0.04,
                                  ):Icon(
                                    Icons.brightness_1,
                                    color: AppColor.pointColor,
                                    size: deviceWidth*0.03,
                                  ),
                                  onPressed:null,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => setState((){
                            if(curSelectedWord.contains(item)) curSelectedWord.remove(item);
                            else curSelectedWord.add(item);
                          }),
                        ),

                      )).toList(),
                    ),
                  ),
                ),
              ),

              // 开始按钮
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: deviceHeight * 0.015),
                height: deviceHeight*0.056,
                width: deviceWidth*0.3,
                decoration: BoxDecoration(
                  color: AppColor.commonBlue,
                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                ),
                child:FlatButton(
                  padding: EdgeInsets.all(0),   // 默认值
                  child:Text('开始',
                    style: TextStyle(
                      color: AppColor.baseCardTextColor,
                      fontSize: deviceWidth*0.05,
                    ),
                  ),
                  onPressed: () => startDictate(),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}