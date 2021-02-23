
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/common_func.dart';
import 'package:flutterapp/model/single_select_word_data.dart';

import 'package:http/http.dart' as http;


class SingleSelectWordPage extends StatefulWidget{
  @override
  createState() => new _SingleSelectWordPageState();
}

var singleSelectWordPageContext;

class _SingleSelectWordPageState extends State<SingleSelectWordPage> {

  // 需要动态改变的状态值得放在build之外……
  bool isSave;  // 当前文字是否已收藏
  bool isVisible = false;   // 当前是否显示文字(已作出选择)
  String curSelectedWord = '';  // 当前已选中的词
  int curWordIndex = 0;   // 当前选择题的词的在此批词里的索引

  // 根据要显示的词或句子的字数，动态调整大小
  double textBoxWidth = 0; // 装文字的米字格的边长（跟文字+拼音整体的高比值为1:1.4）

  // 根据要显示的文本的字数设置相应参数
  void setByTextLen(){
    int len = sswdSelectDetail.word[curWordIndex].length;

    // 计算最大宽度
    double maxHeight = deviceHeight*0.3;  // 上下间隔0.01
    double maxWidth = deviceWidth*(0.8-(len-1)*0.02)/len; // 左右间隔0.02
    if(maxWidth*1.4 > maxHeight) textBoxWidth = maxHeight/1.4;
    else textBoxWidth = maxWidth;
  }

  // 收藏/取消收藏
  void saveOrCancel() async {
    final response = await http.post('http://120.24.151.180:8080/api/record/collect_word?userId=' + userId +
        '&text=' + sswdSelectDetail.word[curWordIndex] + '&textbookName=' + sswdSelectDetail.textbookName[curWordIndex] +
        '&courseName='+ sswdSelectDetail.courseName[curWordIndex] + '&collect=' + (!isSave).toString());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) setState(() {isSave = !isSave;});
      else alert(context, status['msg']);
    }
    else alert(singleSelectWordPageContext, "网络连接失败");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setVoice();
    setByTextLen();
    isSave = sswdSelectDetail.isSave[curWordIndex];
  }

  @override
  void dispose() {
    super.dispose();
  }


  // --------------------------------展示的界面---------------------------------
  @override
  Widget build(BuildContext context) {
    singleSelectWordPageContext = context;
    return Scaffold(
      // 页面是个大container，个人习惯
      resizeToAvoidBottomInset: false,  // 饮鸩止渴的防止底部键盘弹出挤压页面变形
      body:WillPopScope(
        onWillPop: ()async{
          Navigator.pushReplacementNamed(context, practicePage);
          return true;
        },
        child: Container(
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
                        onPressed:()=>Navigator.pushReplacementNamed(context, practicePage),
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

                // 单选主要内容
                Container(
                  alignment: Alignment(0,-1),
                  margin: EdgeInsets.only(top: deviceHeight * 0.015),
                  height: deviceHeight * 0.77,
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
                        padding: EdgeInsets.symmetric(vertical: deviceHeight*0.01, horizontal: deviceWidth*0.05),
                        height: deviceHeight*0.32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: sswdSelectDetail.word[curWordIndex].split('').map<Widget>((element) => Stack(  // 可堆叠式布局，自由度高，无限堆叠
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
                              Container(
                                alignment: Alignment.center,
                                width: textBoxWidth,
                                height: textBoxWidth*0.3,
                                child:Text(sswdSelectDetail.pinyin[curWordIndex][sswdSelectDetail.word[curWordIndex].split('').indexOf(element)],
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

                      // 选项
                      Container(
                        height: deviceHeight*0.29,
                        padding: EdgeInsets.symmetric(vertical: deviceHeight*0.02),
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: sswdSelectDetail.option[curWordIndex].map<Widget>((e) => Container(
                            alignment: Alignment(-1,-1),
                            width: deviceWidth * 0.5,
                            height: deviceHeight*0.055,
                            decoration: BoxDecoration(
                              color: isVisible ? (curSelectedWord == e ? (e == sswdSelectDetail.word[curWordIndex] ?
                              AppColor.darkGreen : AppColor.darkRed ): AppColor.lightBlue) : AppColor.lightBlue,
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child:FlatButton(
                              padding: EdgeInsets.all(0),
                              child: Container(
                                alignment: Alignment.center,
                                child:Text(e,
                                  style: TextStyle(
                                    fontSize: deviceWidth*0.05,
                                    color: isVisible ? (curSelectedWord == e ? AppColor.baseCardTextColor :
                                    AppColor.commonBlue) : AppColor.commonBlue,
                                  ),
                                ),
                              ),
                              onPressed: () => setState(() {
                                if(!isVisible) {
                                  curSelectedWord = e;
                                  isVisible = true;
                                }
                              }),
                            ),
                          )).toList(),
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
                            // 拼接拼音字符串
                            String pinyin = "";
                            sswdSelectDetail.pinyin[curWordIndex].forEach((e){
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
                  height: deviceHeight*0.1,
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
                          onPressed:()=> setState(() {
                            if(curWordIndex == 0){
                              alert(context, "已经是本批第一个词啦");
                              return;
                            }
                            --curWordIndex;
                            isSave = sswdSelectDetail.isSave[curWordIndex];
                            setByTextLen();
                          }),
                        ),
                      ),

                      // 收藏/取消收藏
                      SizedBox(
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
                          onPressed:()=> saveOrCancel(),
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
                          onPressed:()=> setState(() {
                            if(curWordIndex == sswdSelectDetail.word.length - 1){
                              alert(context, "本批词语已经练习完，若想继续，请返回重进");
                              return;
                            }
                            ++curWordIndex;
                            isSave = sswdSelectDetail.isSave[curWordIndex];
                            setByTextLen();
                          }),
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