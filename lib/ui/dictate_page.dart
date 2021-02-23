
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/common_func.dart';
import 'package:flutterapp/model/dictate_data.dart';

import 'package:http/http.dart' as http;

class DictatePage extends StatefulWidget{
  @override
  createState() => new _DictatePageState();
}

var dictatePageContext;

class _DictatePageState extends State<DictatePage> {

  // 需要动态改变的状态值得放在build之外……
  bool isSave = false;    // 当前词是否收藏
  bool isError = false;    // 当前词是否错误
  bool isVisible = false;   // 当前是否显示文字(点击按钮且网络数据获取完成)
  int curWordId = 0;    // 当前正在听写的词语id(数组下标)

  // 获取拼音
  void getPinyin() async{
    final response = await http.post('http://120.24.151.180:8080/api/common/get_word_info?userId=' + userId + '&text=' + ddAllWord[curWordId]);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) setState(() {
          ddWordDetail = DdWordDetail.fromJson(data);
      });
      else alert(dictatePageContext, status['msg']);
    }
    else alert(dictatePageContext, "网络连接失败");
  }

  // 收藏/取消收藏
  void saveOrCancel() async {
    final response = await http.post('http://120.24.151.180:8080/api/record/collect_word?userId=' + userId +
        '&text=' + ddAllWord[curWordId] + '&textbookName=' + ddTextbookName[curWordId] +
        '&courseName='+ ddTextName[curWordId] + '&collect=' + (!isSave).toString());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) setState(() {isSave = !isSave;});
      else alert(dictatePageContext, status['msg']);
    }
    else alert(dictatePageContext, "网络连接失败");
  }

  // 错误
  void setError()async{
    final response = await http.post('http://120.24.151.180:8080/api/record/put_mistaken_word?userId=' + userId +
        '&text=' + ddAllWord[curWordId] + '&textbookName=' + ddTextbookName[curWordId] + '&courseName=' + ddTextName[curWordId]);
    if (response.statusCode == 200) setState(() {isError = true;});
    else alert(dictatePageContext, "网络连接失败");
  }

  // 已练（就是点击下一个而没有点错误）
  void hasLearnt()async{
    final response = await http.post('http://120.24.151.180:8080/api/record/put_practiced_word?userId=' + userId +
        '&text=' + ddAllWord[curWordId] + '&textbookName=' + ddTextbookName[curWordId] + '&courseName=' + ddTextName[curWordId]);
    if (response.statusCode != 200) alert(dictatePageContext, "网络连接失败");
  }

  // 返回上一页
  void back(){
    if(ddParentPage == 'textOrder') Navigator.pushReplacementNamed(context, selectWordPage);
    else if(ddParentPage == 'mutliTextRandom') Navigator.pushReplacementNamed(context, multiTextRandomPage);
    else if(ddParentPage == 'recordRandom') Navigator.pushReplacementNamed(context, practicePage);
  }

  // 根据要显示的词或句子的字数，动态调整大小
  double textBoxWidth = 0; // 装文字的米字格的边长（跟文字+拼音整体的高比值为1:1.4）

  // 根据要显示的文本的字数设置相应参数
  void setByTextLen(){
    int len = ddAllWord[curWordId].length;

    // 计算最大宽度
    double maxHeight = deviceHeight*0.3;  // 上下间隔0.01
    double maxWidth = deviceWidth*(0.9-(len-1)*0.02)/len; // 左右间隔0.02
    if(maxWidth*1.4 > maxHeight) textBoxWidth = maxHeight/1.4;
    else textBoxWidth = maxWidth;
  }

  @override
  void initState() {
    super.initState();
    setByTextLen();
    getPinyin();
  }

  @override
  void dispose() {
    super.dispose();
  }


  // --------------------------------展示的界面---------------------------------
  @override
  Widget build(BuildContext context) {
    dictatePageContext = context;
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
                        onPressed:() =>back(),
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

                // 课文名
                Container(
                  alignment: Alignment.center,
                  height: deviceHeight * 0.06,
                  color: AppColor.commonBlue,
                  child:Text(ddTextName[curWordId],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.baseCardTextColor,
                      fontSize: deviceWidth*0.05,
                    ),
                  ),
                ),

                // 进度条
                Container(
                  alignment: Alignment(-1, -1),
                  height: deviceHeight * 0.04,
                  child:Stack(
                    children: [
                      // 背景灰色条
                      Container(
                        height: deviceHeight*0.004,
                        width: deviceWidth * 0.8,
                        margin: EdgeInsets.only(left:deviceWidth * 0.1, top: deviceHeight*0.018),
                        color: AppColor.splitLineColor,
                      ),

                      // 蓝色进度条
                      Container(
                        height: deviceHeight*0.004,
                        width: deviceWidth * 0.8 * (curWordId + 1) / ddAllWord.length,
                        margin: EdgeInsets.only(left:deviceWidth * 0.1, top: deviceHeight*0.018),
                        color: AppColor.commonBlue,
                      ),

                      // 进度头部
                      Container(
                        height: deviceHeight*0.016,
                        width: deviceWidth * 0.05,
                        margin: EdgeInsets.only(left:deviceWidth * ( 0.8 * (curWordId + 1) / ddAllWord.length + 0.1), top: deviceHeight*0.012),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: AppColor.commonBlue),
                          color: AppColor.commonBoxFillColor,
                          borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.008)),
                        ),
                      ),
                    ],
                  ),
                ),

                // 进度文本
                Container(
                  height: deviceHeight * 0.04,
                  child:Text((curWordId+1).toString() + ' / ' + ddAllWord.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: AppColor.commonBlue,
                      fontSize: deviceWidth*0.04,
                    ),
                  ),
                ),

                // 听写主要内容
                Container(
                  alignment: Alignment(0,-1),
                  height: deviceHeight * 0.64,
                  width: deviceWidth * 0.9,
                  decoration: BoxDecoration(
                    color: AppColor.commonBoxFillColor,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 文字信息（字形拼音）
                      Container(
                        alignment: Alignment(0,0),
                        //padding: EdgeInsets.symmetric(vertical: deviceHeight*0.01, horizontal: deviceWidth*0.05),
                        height: deviceHeight*0.32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ddAllWord[curWordId].split('').map<Widget>((element) => Stack(  // 可堆叠式布局，自由度高，无限堆叠
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
                                      size: Size(textBoxWidth*0.99,1),
                                      painter: LinePainter(Offset(0, 1), Offset(textBoxWidth*0.99,1)),
                                    ),
                                    CustomPaint(
                                      size: Size(textBoxWidth*0.99,1),
                                      painter: LinePainter(Offset(0, 1), Offset(textBoxWidth*0.99,1)),
                                    ),
                                  ],
                                ),
                              ),

                              // 拼音文本
                              if(isVisible)Container(
                                alignment: Alignment.center,
                                width: textBoxWidth,
                                height: textBoxWidth*0.3,
                                child:Text(ddWordDetail.pinyins[ddWordDetail.tokens.indexOf(element)],
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
                                  size: Size(textBoxWidth*0.99,textBoxWidth*0.99),
                                  painter: MiPainter(Offset(0, 0), Offset(textBoxWidth*0.99,textBoxWidth*0.99)),
                                ),
                              ),

                              // 字形
                              if(isVisible)Container(
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
                        ),
                      ),

                      // 显示答案按钮
                      Container(
                        height: deviceHeight*0.05,
                        width: deviceWidth * 0.3,
                        margin: EdgeInsets.symmetric(vertical: deviceHeight*0.05),
                        decoration: BoxDecoration(
                          color: AppColor.commonBlue,
                          borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.025)),
                        ),
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Text("显示答案",
                            style: TextStyle(
                              color: AppColor.baseCardTextColor,
                              fontSize: deviceWidth*0.04,
                            ),
                          ),
                          onPressed: () => setState(() {
                            isVisible = true;
                            isSave = ddWordDetail.collected;
                          }),
                        ),
                      ),

                      // 播放
                      Container(
                        height: deviceHeight*0.16,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_filled,
                                color: AppColor.commonBlue,
                                size: deviceWidth*0.12,
                              ),
                              Text("播放",
                                style: TextStyle(
                                  color: AppColor.commonBlue,
                                  fontSize: deviceWidth*0.04,
                                ),
                              ),
                            ],
                          ),
                          onPressed: (){
                            // 拼接拼音
                            String pinyin = "";
                            ddWordDetail.pinyins.forEach((e){
                              pinyin = pinyin + e + ' ';
                            });
                            playSound(pinyin);
                          },
                        ),
                      ),

                    ],
                  ),
                ),

                // 几个按钮
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      // 收藏/取消收藏
                      if(isVisible)SizedBox(
                        width: deviceHeight*0.1,
                        height: deviceHeight*0.08,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            children: [
                              Icon(
                                !isSave?Icons.save_alt:Icons.open_in_new,
                                color: isSave?AppColor.darkRed:AppColor.lightGreen,
                                size: deviceWidth*0.07,
                              ),
                              Text(isSave?"取消收藏":"收藏",
                                style: TextStyle(
                                  color: isSave?AppColor.darkRed:AppColor.lightGreen,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed:()=>saveOrCancel(),
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
                          onPressed:() => setState(() {
                            if(!isError) hasLearnt();
                            if(curWordId == ddAllWord.length - 1) alert(context, "已经是最后一个词啦");
                            else{
                              ++curWordId;
                              isSave = false;
                              isError = false;
                              isVisible = false;
                              setByTextLen();
                              getPinyin();
                            }
                          }),
                        ),
                      ),

                      // 错误
                      if(isVisible && !isError)SizedBox(
                        width: deviceHeight*0.1,
                        height: deviceHeight*0.08,
                        child:FlatButton(
                          padding: EdgeInsets.all(0),
                          child:Column(
                            children: [
                              Icon(
                                Icons.clear,
                                color: AppColor.darkRed,
                                size: deviceWidth*0.07,
                              ),
                              Text("错误",
                                style: TextStyle(
                                  color: AppColor.darkRed,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed:()=> setError(),
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