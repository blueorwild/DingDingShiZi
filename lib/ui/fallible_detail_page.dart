
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/fallible_detail_data.dart';


import 'package:http/http.dart' as http;

class FallibleDetailPage extends StatefulWidget{
  @override
  createState() => new _FallibleDetailPageState();
}

var fallibleDetailPageContext;

class _FallibleDetailPageState extends State<FallibleDetailPage> {
  // 需要动态改变的状态值得放在build之外……
  bool isLearnt = false; // 当前文字是否已学会

  // 根据要显示的词或句子的字数，动态调整各部分大小
  int rowNum = 0;   // 展示的文本行数（拼音+文字为一个整体）
  double textBoxWidth = 0; // 装文字的米字格的边长（跟文字+拼音整体的高比值为1:1.4）
  double textFieldHeight = 0;  // 显示整个文本区域的高度（最大是deviceHeight*0.4）
  double textMeaningHeight = 0; // 显示释义的高度（最大是deviceHeight*0.32）

  // 根据要显示的文本的字数设置相应参数
  void setByTextLen(){
    // 按照逗号隔开
    List plainText = fddText.split("，");
    fddSplitText = [];
    // 按照每行最多五个字再隔开
    plainText.forEach((ele) {
      // 每行最多放5个字
      int i = 0, leftLen = ele.length;
      while(leftLen > 6){
        fddSplitText.add(ele.substring(i, i+6));
        leftLen -= 6;
        i += 6;
      }
      fddSplitText.add(ele.substring(i));
    });
    // 计算最长行的字数
    int maxCount = 0;
    fddSplitText.forEach((element) {
      if(element.length > maxCount) maxCount = element.length;
    });
    // 计算最大的textBoxWidth
    rowNum = fddSplitText.length;
    double maxHeight = deviceHeight*(0.38-(rowNum-1)*0.01)/rowNum;  // 上下间隔0.01
    double maxWidth = deviceWidth*(0.9-(maxCount-1)*0.02)/maxCount; // 左右间隔0.05
    if(maxWidth*1.4 > maxHeight) textBoxWidth = maxHeight/1.4;
    else textBoxWidth = maxWidth;
    // 设置两个高
    textFieldHeight = textBoxWidth*1.4*rowNum + deviceHeight*(0.02 + (rowNum-1)*0.01);
    textMeaningHeight = deviceHeight*0.72 - textFieldHeight;
  }

  // 获取文本详情
  void getTextDetail(String text) async{
    String apiAddress;
    if(fddParentPage == 'word') apiAddress = 'http://120.24.151.180:8080/api/column/get_fallible_detailed_word';
    else if(fddParentPage == 'meaning') apiAddress = 'http://120.24.151.180:8080/api/column/get_fallible_detailed_meaning';
    else if(fddParentPage == 'character') apiAddress = 'http://120.24.151.180:8080/api/column/get_fallible_detailed_character';

    final response = await http.post(apiAddress + '?text=' + text);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200){
        setState(() {
          fddText = text;
          setByTextLen();
          isLearnt = fddAllLearnt.contains(fddText);
          fddText = fddText.replaceAll('，', '');
          fddTextDetail = FddTextDetail.fromJson(data);
        });
      }
      else alert(fallibleDetailPageContext, status['msg']);
    }
    else alert(fallibleDetailPageContext, "网络连接失败");
  }

  // 已学会
  void hasLearnt() async{
    String apiAddress;
    if(fddParentPage == 'word') apiAddress = 'http://120.24.151.180:8080/api/column/learn_fallible_word';
    else if(fddParentPage == 'meaning') apiAddress = 'http://120.24.151.180:8080/api/column/learn_fallible_meaning';
    else if(fddParentPage == 'character') apiAddress = 'http://120.24.151.180:8080/api/column/learn_fallible_character';

    final response = await http.post(apiAddress + '?userId=' + userId + '&text=' + fddAllText[fddCurTextIndex]);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200){
        setState(() {
          isLearnt = true;
          fddAllLearnt.add(fddAllText[fddCurTextIndex]);
        });
      }
      else alert(fallibleDetailPageContext, status['msg']);
    }
    else alert(fallibleDetailPageContext, "网络连接失败");
  }

  // 返回上一页
  void back(){
    if(fddParentPage =='character') Navigator.pushReplacementNamed(fallibleDetailPageContext, fallibleCharacterPage);
    else if(fddParentPage =='word') Navigator.pushReplacementNamed(fallibleDetailPageContext, fallibleWordPage);
    else if(fddParentPage =='meaning') Navigator.pushReplacementNamed(fallibleDetailPageContext, fallibleMeaningPage);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setVoice();
    setByTextLen();
    fddTextDetail = FddTextDetail.origin();
    print(fddText);
    print(fddParentPage);
    getTextDetail(fddText);
  }

  @override
  void dispose() {
    super.dispose();
  }


  // --------------------------------展示的界面---------------------------------
  @override
  Widget build(BuildContext context) {
    fallibleDetailPageContext = context;
    return Scaffold(
      // 页面是个大container，个人习惯
      resizeToAvoidBottomInset: false,  // 饮鸩止渴的防止底部键盘弹出挤压页面变形
      body: WillPopScope(
        onWillPop: ()async{
          back();
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
              children:[
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
                        onPressed:()=>back(),
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

                // 第二行 文字信息（字形拼音）
                Container(
                  alignment: Alignment(0,0),
                  padding: EdgeInsets.symmetric(vertical: deviceHeight*0.01, horizontal: deviceWidth*0.05),
                  height: textFieldHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: fddSplitText.map<Widget>((item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: item.split('').map<Widget>((element) => Stack(  // 可堆叠式布局，自由度高，无限堆叠
                        alignment: Alignment.topCenter,
                        children: [
                          // 拼音背景框
                          Container(
                            width: textBoxWidth,
                            height: textBoxWidth*0.3,
                            decoration: BoxDecoration(
                              color: AppColor.commonBoxFillColor,
                              border: Border.all(width: 1.0, color: AppColor.splitLineColor),
                            ),
                            // 两条线
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomPaint(
                                  size: Size(textBoxWidth*0.975,1),
                                  painter: LinePainter(Offset(0, 1), Offset(textBoxWidth*0.975,1)),
                                ),
                                CustomPaint(
                                  size: Size(textBoxWidth*0.975,1),
                                  painter: LinePainter(Offset(0, 1), Offset(textBoxWidth*0.975,1)),
                                ),
                              ],
                            ),
                          ),

                          // 拼音文本
                          Container(
                            alignment: Alignment.center,
                            width: textBoxWidth,
                            height: textBoxWidth*0.3,
                            child:Text(fddTextDetail.pinyin[fddText.indexOf(element)],
                              style: TextStyle(
                                color: AppColor.commonTextColor,
                                fontSize: textBoxWidth*0.19,
                              ),
                            ),
                          ),

                          // 字形背景框
                          Container(
                            margin: EdgeInsets.only(top: textBoxWidth*0.4),
                            width: textBoxWidth,
                            height: textBoxWidth,
                            decoration: BoxDecoration(
                              color: AppColor.commonBoxFillColor,
                              border: Border.all(width: 1.0, color: AppColor.splitLineColor),
                            ),
                            child:CustomPaint(
                              size: Size(textBoxWidth*0.98,textBoxWidth*0.98),
                              painter: MiPainter(Offset(0, 0), Offset(textBoxWidth*0.98,textBoxWidth*0.98)),
                            ),
                          ),

                          // 字形
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: textBoxWidth*0.4),
                            width: textBoxWidth,
                            height: textBoxWidth,
                            child:  Text(element,
                              style: TextStyle(
                                color: AppColor.commonTextColor,
                                fontSize: textBoxWidth*0.6,
                              ),
                            ),
                          ),
                        ],
                      )).toList(),
                    )).toList(),
                  ),
                ),

                // 第三行，一个按钮
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.05,
                  child: IconButton(
                    padding: EdgeInsets.all(0),   // 默认8.0
                    icon: Icon(
                      Icons.volume_up,
                      color: AppColor.darkBlueButton,
                      size: deviceWidth*0.1,
                    ),
                    onPressed:(){
                      // 拼接拼音
                      String pinyin = "";
                      fddTextDetail.pinyin.forEach((e){
                        pinyin = pinyin + e + ' ';
                      });
                      playSound(pinyin);
                    },
                  ),
                ),

                // 第四行 释义内容
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: textMeaningHeight,
                  width: deviceWidth*0.9,
                  decoration: BoxDecoration(
                    color: AppColor.commonBoxFillColor,
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(0.0),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: fddTextDetail.meaning.map<Widget>((item) => Container(
                          margin: EdgeInsets.only(top:deviceHeight*0.01),
                          padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.05),
                          width: deviceWidth*0.9,
                          alignment: Alignment(-1,-1),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: deviceWidth*0.042,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),

                // 第五行 几个按钮
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      // 上一个
                      SizedBox(
                        width: deviceHeight*0.1,
                        height: deviceHeight*0.08,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            children: [
                              Icon(
                                Icons.navigate_before,
                                color: AppColor.darkBlueButton,
                                size: deviceWidth*0.07,
                              ),
                              Text("上一个",
                                style: TextStyle(
                                  color: AppColor.darkBlueButton,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed: (){
                            if(fddCurTextIndex == 0) fddCurTextIndex = fddAllText.length - 1;
                            else --fddCurTextIndex;
                            getTextDetail(fddAllText[fddCurTextIndex]);
                          },
                        ),
                      ),

                      // 已学会
                      if(!isLearnt)SizedBox(
                        width: deviceHeight*0.1,
                        height: deviceHeight*0.08,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            children: [
                              Icon(
                                Icons.check,
                                color: AppColor.darkYellow,
                                size: deviceWidth*0.07,
                              ),
                              Text("已学会",
                                style: TextStyle(
                                  color: AppColor.darkYellow,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed:() => hasLearnt(),
                        ),
                      ),


                      // 下一个
                      SizedBox(
                        width: deviceHeight*0.1,
                        height: deviceHeight*0.08,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            children: [
                              Icon(
                                Icons.navigate_next,
                                color: AppColor.darkBlueButton,
                                size: deviceWidth*0.07,
                              ),
                              Text("下一个",
                                style: TextStyle(
                                  color: AppColor.darkBlueButton,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed: (){
                            if(fddCurTextIndex == fddAllText.length - 1) fddCurTextIndex = 0;
                            else ++fddCurTextIndex;
                            getTextDetail(fddAllText[fddCurTextIndex]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]
          ),

        ),
      )
    );
  }
}

// ---------------------------------辅助功能-----------------------------------

// 画线（flutter没有直接画线的）
class LinePainter extends CustomPainter {
  Offset _start, _end;  // 线的起点终点偏移
  LinePainter(Offset start, Offset end){
    _start = start;
    _end = end;
  }

  // 定义画笔
  Paint _paint = Paint()
    ..color = AppColor.splitLineColor //画笔颜色
    ..strokeCap = StrokeCap.round //画笔笔触类型
    ..isAntiAlias = true //是否启动抗锯齿
    ..strokeWidth = 1.0; //画笔的宽度

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(_start, _end, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// 画米字格
class MiPainter extends CustomPainter{
  Offset _leftUp, _rightDown;  // 米字格的矩形的左上角/右下角的位置
  MiPainter(Offset leftUp, Offset rightDown){
    _leftUp = leftUp;
    _rightDown = rightDown;
  }

  // 定义画笔
  Paint _paint = Paint()
    ..color = AppColor.splitLineColor //画笔颜色
    ..strokeCap = StrokeCap.round //画笔笔触类型
    ..isAntiAlias = true //是否启动抗锯齿
    ..strokeWidth = 1.0; //画笔的宽度

  @override
  void paint(Canvas canvas, Size size) {
    Offset leftDown = Offset(_leftUp.dx, _rightDown.dy);
    Offset rightUp = Offset(_rightDown.dx, _leftUp.dy);
    Offset midUp = Offset((_leftUp.dx + _rightDown.dx)/2, _leftUp.dy);
    Offset midDown = Offset((_leftUp.dx + _rightDown.dx)/2, _rightDown.dy);
    Offset midLeft = Offset(_leftUp.dx, (_leftUp.dy + _rightDown.dy)/2);
    Offset midRight = Offset(_rightDown.dx, (_leftUp.dy + _rightDown.dy)/2);

    canvas.drawLine(_leftUp, _rightDown, _paint);  // \
    canvas.drawLine(leftDown, rightUp, _paint);    // /
    canvas.drawLine(midLeft, midRight, _paint);    // -
    canvas.drawLine(midUp, midDown, _paint);       // |
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}