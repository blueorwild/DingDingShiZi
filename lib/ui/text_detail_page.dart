
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/text_detail_data.dart';
import 'package:http/http.dart' as http;

class TextDetailPage extends StatefulWidget{
  @override
  createState() => new _TextDetailPageState();
}

var textDetailPageContext;

class _TextDetailPageState extends State<TextDetailPage>
    with TickerProviderStateMixin{
  // 需要动态改变的状态值得放在build之外……
  var isHanziMeaningView = true;     // 当前子视图是否是文字详情（false则为视频）
  int currentPinyinIndex = 0;    // 当前显示的拼音索引
  SvgPainter currentHanziSvg;   // 当前显示的字形（动画）
  var isPlayAnimation = false;  // 是否播放动画（未播放则没有建立动画对象，考虑析构问题）

  // 获取查询的字的信息
  void getText(String text) async {
    final response = await http.post('http://120.24.151.180:8080/api/common/get_character_info?userId=' + userId +'&text=' + text);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200)setState(() {
        // 拼音索引要归零
        currentPinyinIndex = 0;
        tddTextDetail = TddWordInfo.fromJson(data);
        currentHanziSvg = SvgPainter(tddTextDetail.strokeAnim[tddTextDetail.strokeAnim.length-1]);
        for(int i = 0; i < tddTextDetail.strokeAnim.length; ++i)
          tddTextDetail.strokeAnim[i] = SvgPainter(tddTextDetail.strokeAnim[i]);
      });
      else alert(textDetailPageContext, status['msg']);
    }
    else alert(textDetailPageContext, '网络连接失败');
  }

  // 收藏/取消收藏
  void saveOrCancel(String text, bool flag) async {

    final response = await http.post('http://120.24.151.180:8080/api/record/collect_character?userId=' + userId +
        '&text=' + text + '&textbookName=' + tddTextBookName + '&courseName='+ tddCourseName + '&collect=' + (!flag).toString());
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) setState(() {
        tddTextDetail.collected = !tddTextDetail.collected;
      });
      else alert(textDetailPageContext, status['msg']);
    }
    else alert(textDetailPageContext, '网络连接失败');
  }

  // 已学会
  void hasLearnt(String text)async{
    final response = await http.post('http://120.24.151.180:8080/api/learn/learn_character?userId=' + userId +'&textbookName='
        + tddTextBookName + '&courseName='+ tddCourseName + '&text=' + text );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200)setState(() {
        tddCurCourseLearntCharacter.add(text);
      });
      else alert(textDetailPageContext, status['msg']);
    }
    else alert(textDetailPageContext, "网络连接失败");
  }

  // 返回上一页
  void back(){
    if(tddParentPage == 'studyPage') Navigator.pushReplacementNamed(context, studyPage);
    else if (tddParentPage == 'homePage') Navigator.pushReplacementNamed(context, homePage);
    //else if (tddParentPage == 'collectedCharacterPage') Navigator.pushReplacementNamed(context, collectedCharacterPage);
  }


  @override
  void initState() {
    super.initState();
    setVoice();
    tddTextDetail = TddWordInfo.origin();
    getText(tddCurCharacter);
  }

  @override
  void dispose() {
    // 动画使用完成后必需要销毁
    if(isPlayAnimation) animationController.dispose();
    super.dispose();
  }

  // ---------------------------------动画相关----------------------------------
  AnimationController animationController;
  Animation<int> animation;

  // 为了实现点击按钮的重复动画，每次都要新建一个动画
  void startHanziAnimation(int seconds, int begin, int end) {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: seconds)); // 动画间隔
    animation = IntTween(begin: begin,end: end).animate(animationController);   // 血坑，用Tween<int>编译不报错但是运行不行
    isPlayAnimation = true;
    animationController.addListener(() {
      setState(() {
        currentHanziSvg = tddTextDetail.strokeAnim[animation.value];  // 必须提出来设置，不能在原地使用自动修改（不知为何）
      });
    });
    if (mounted) animationController.forward();
  }

  // --------------------------------展示的界面---------------------------------
  @override
  Widget build(BuildContext context) {
    textDetailPageContext = context;
    return Scaffold(
      // 页面是个大container，个人习惯
      resizeToAvoidBottomInset: false,  // 饮鸩止渴的防止底部键盘弹出挤压页面变形
      body:WillPopScope(  // 捕捉设备的真实返回键
        onWillPop: () async{  // 只能加大括号啊
          back();
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
                        onPressed: () =>back(),
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

                // 第二行 文字信息（字形拼音按钮笔画等）
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  height: deviceHeight*0.27,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      // 声音视频按钮+笔画部首等信息
                      Container(
                        width: deviceWidth*0.3,
                        height: deviceHeight*0.23,
                        margin: EdgeInsets.only(left: deviceWidth*0.06),
                        decoration: BoxDecoration(
                          color: AppColor.commonBoxFillColor,
                          borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.006)),
                        ),
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 声音视频按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // 声音按钮
                                IconButton(
                                  padding: EdgeInsets.all(0),   // 默认8.0
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: AppColor.darkBlueButton,
                                    size: deviceWidth*0.07,
                                  ),
                                  onPressed:() => playSound(tddTextDetail.pinyins[currentPinyinIndex]),
                                ),

                                // 动画按钮
                                IconButton(
                                  padding: EdgeInsets.all(0),   // 默认8.0
                                  icon: Icon(
                                    Icons.play_circle_filled,
                                    color: AppColor.darkBlueButton,
                                    size: deviceWidth*0.07,
                                  ),
                                  onPressed: () => startHanziAnimation(tddTextDetail.strokeAnim.length, 0, tddTextDetail.strokeAnim.length-1), //启动动画,
                                ),
                              ],
                            ),

                            // 笔画部首等信息
                            Text.rich(
                              new TextSpan(
                                children:[
                                  getTextSpan('笔画: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan(tddTextDetail.numStroke.toString() + '\n', AppColor.commonTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan("部首: ", AppColor.unSelectTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan(tddTextDetail.radical +'\n', AppColor.commonTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan("结构: ", AppColor.unSelectTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan(tddTextDetail.struct +'\n', AppColor.commonTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan("笔顺: ", AppColor.unSelectTextColor, "Roboto", deviceWidth*0.04),
                                  getTextSpan('见下', AppColor.commonTextColor, "Roboto", deviceWidth*0.04),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 拼音和文字详情
                      Container(
                        alignment: Alignment(0,-1),
                        width: deviceWidth*0.36,
                        height: deviceHeight*0.27,
                        child:Stack(  // 可堆叠式布局，自由度高，无限堆叠
                          alignment: Alignment.topCenter,
                          children: [
                            // 拼音背景框
                            Container(
                              width: deviceWidth*0.36,
                              height: deviceHeight*0.05,
                              decoration: BoxDecoration(
                                color: AppColor.commonBoxFillColor,
                                border: Border.all(width: 1.0, color: AppColor.splitLineColor),
                              ),
                              // 两条线
                              child:Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomPaint(
                                    size: Size(deviceWidth*0.355,1),
                                    painter: LinePainter(Offset(0, 1), Offset(deviceWidth*0.355,1)),
                                  ),
                                  CustomPaint(
                                    size: Size(deviceWidth*0.355,1),
                                    painter: LinePainter(Offset(0, 1), Offset(deviceWidth*0.355,1)),
                                  ),
                                ],
                              ),
                            ),

                            // 拼音文本
                            Container(
                              alignment: Alignment.center,
                              width: deviceWidth*0.36,
                              height: deviceHeight*0.05,
                              child:Text(tddTextDetail.pinyins[currentPinyinIndex],
                                style: TextStyle(
                                  color: AppColor.commonTextColor,
                                  fontSize: deviceWidth*0.06,
                                ),
                              ),
                            ),

                            // 字形背景框
                            Container(
                              margin: EdgeInsets.only(top: deviceHeight*0.27 - deviceWidth*0.36),
                              width: deviceWidth*0.36,
                              height: deviceWidth*0.36,
                              decoration: BoxDecoration(
                                color: AppColor.commonBoxFillColor,
                                border: Border.all(width: 1.0, color: AppColor.splitLineColor),
                              ),
                              child:CustomPaint(
                                size: Size(deviceWidth*0.355,deviceWidth*0.355),
                                painter: MiPainter(Offset(0, 0), Offset(deviceWidth*0.355,deviceWidth*0.355)),
                              ),
                            ),

                            // 字形
                            Container(
                              margin: EdgeInsets.only(top: deviceHeight*0.27 - deviceWidth*0.36),
                              padding: EdgeInsets.all(0),
                              width: deviceWidth*0.36,
                              height: deviceWidth*0.36,
                              child: CustomPaint(
                                size: Size(deviceHeight*0.36,deviceHeight*0.36),
                                painter: currentHanziSvg,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 可能存在的多音字按钮
                      Container(
                        alignment: Alignment(-1,0),
                        width: deviceWidth*0.15,
                        height: deviceHeight*0.23,
                        // 一列按钮
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // 无法搞定半圆角矩形，只能Stack堆叠一个圆形和矩形
                          children: tddTextDetail.pinyins.map<Widget>((item) => Stack(
                            alignment: Alignment(-1,0),
                            children:[
                              // 圆
                              Container(
                                width: deviceWidth*0.08,
                                height: deviceWidth*0.08,
                                decoration: BoxDecoration(
                                  color: tddTextDetail.pinyins[currentPinyinIndex] == item?AppColor.darkBlueButton:AppColor.lightBlueButton,
                                  borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.04)),
                                ),
                              ),

                              // 矩形
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left:deviceWidth*0.04),
                                height: deviceWidth*0.08,
                                width: deviceWidth*0.23,
                                color: tddTextDetail.pinyins[currentPinyinIndex] == item?AppColor.darkBlueButton:AppColor.lightBlueButton,
                                child:FlatButton(
                                  padding: EdgeInsets.all(0),   // 默认值
                                  child:Text(item,
                                    style: TextStyle(
                                      color: tddTextDetail.pinyins[currentPinyinIndex] == item?AppColor.baseCardTextColor:AppColor.blueCardTextColor,
                                      fontSize: deviceWidth*0.03,
                                    ),
                                  ),
                                  onPressed: () => setState(() {
                                    currentPinyinIndex = tddTextDetail.pinyins.indexOf(item);
                                  }),
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // 第三行 文字笔顺
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.02),
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.1,
                  width: deviceWidth*0.9,
                  decoration: BoxDecoration(
                    color: AppColor.commonBoxFillColor,
                  ),
                  child:Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      //reverse: false,
                      padding: EdgeInsets.all(0.0),
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        children: tddTextDetail.strokeAnim.map<Widget>((item) => Container(
                          alignment: Alignment.center,
                          width: deviceHeight*0.09,
                          height: deviceHeight*0.09,
                          margin: EdgeInsets.only(left: deviceWidth*0.03),
                          decoration: BoxDecoration(
                            color: AppColor.lightBlue,
                          ),
                          child:CustomPaint(
                            size: Size(deviceHeight*0.09,deviceHeight*0.09),
                            painter: item,
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ),

                // 第四行，两个按钮
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.3),
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.05,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 释义按钮
                      IconButton(
                        padding: EdgeInsets.all(0),   // 默认8.0
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: isHanziMeaningView?AppColor.darkBlueButton:AppColor.commonIconColor,
                          size: deviceWidth*0.1,
                        ),
                        onPressed: () => setState(() {isHanziMeaningView = true;}),
                      ),

                      // 视频按钮
                      IconButton(
                        padding: EdgeInsets.all(0),   // 默认8.0真是难受到我了
                        icon: Icon(
                          Icons.ondemand_video,
                          color: isHanziMeaningView?AppColor.commonIconColor:AppColor.darkBlueButton,
                          size: deviceWidth*0.1,
                        ),
                        onPressed: () => setState(() {isHanziMeaningView = false;}),
                      ),
                    ],
                  ),
                ),

                // 第五行 释义内容
                Container(
                  alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.35,
                  width: deviceWidth*0.9,
                  color: AppColor.commonBoxFillColor,
                  child: Row(  // 貌似不能child用if
                    children: [
                      if(isHanziMeaningView)Scrollbar(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 以文字形式展示的条目
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: tddTextDetail.explanationItems.map<Widget>((item) => Container(
                                  margin: EdgeInsets.only(top:deviceHeight*0.01),
                                  padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.05),
                                  width: deviceWidth*0.9,
                                  alignment: Alignment(-1,-1),
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // item,形如 释义、组词、成语
                                      SizedBox(width: deviceWidth*0.8,
                                        child:Text(item,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: deviceWidth*0.045,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // item的具体内容
                                      Text(tddTextDetail.explanation[tddTextDetail.explanationItems.indexOf(item)][currentPinyinIndex],
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: deviceWidth*0.042,
                                        ),
                                      ),

                                      // 分割线
                                      Container(
                                        width: deviceWidth*0.6,
                                        margin: EdgeInsets.fromLTRB(deviceWidth*0.1,deviceHeight*0.01,0,0),
                                        height:1,
                                        color: AppColor.splitLineColor,
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                              // 额外添加的字形演变条目
                              Container(
                                margin: EdgeInsets.only(top:deviceHeight*0.01),
                                padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.05),
                                width: deviceWidth*0.9,
                                alignment: Alignment(-1,-1),
                                child:Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 字形演变标题
                                    SizedBox(width: deviceWidth*0.8,
                                      child:Text("字形演变(部分缺失)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: deviceWidth*0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // 字形演变内容
                                    Text.rich(
                                      TextSpan(
                                        children:[
                                          getTextSpan('甲骨: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "JiaGuWen", deviceWidth*0.11),
                                          getTextSpan('金: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "JinWen", deviceWidth*0.11),
                                          getTextSpan('篆: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "XiaoZhuan", deviceWidth*0.11),
                                          getTextSpan('隶: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "LiShu", deviceWidth*0.11),
                                          getTextSpan('\n楷: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "KaiShu", deviceWidth*0.11),
                                          getTextSpan('行: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "XingShu", deviceWidth*0.11),
                                          getTextSpan('草: ', AppColor.unSelectTextColor, "Roboto", deviceWidth*0.045),
                                          getTextSpan(tddCurCharacter, AppColor.commonTextColor, "CaoShu", deviceWidth*0.11),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      else Container(
                        width: deviceWidth*0.8,
                        alignment: Alignment.center,
                        child:Text("待放视频",),
                      ),
                    ],
                  ),
                ),

                // 第六行 几个按钮
                Container(
                  alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.only(top: deviceHeight*0.01),
                  height: deviceHeight*0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      // 上一个
                      if(tddParentPage == "studyPage")SizedBox(
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
                          onPressed: () => setState(() {
                            if(tddCharacterIndex == 0) tddCharacterIndex = tddCurCourseAllCharacter.length - 1;
                            else --tddCharacterIndex;
                            tddCurCharacter = tddCurCourseAllCharacter[tddCharacterIndex];
                            getText(tddCurCharacter);
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
                                !tddTextDetail.collected?Icons.save_alt:Icons.open_in_new,
                                color: tddTextDetail.collected?AppColor.darkRed:AppColor.lightGreen,
                                size: deviceWidth*0.07,
                              ),
                              Text(tddTextDetail.collected?"取消收藏":"收藏",
                                style: TextStyle(
                                  color: tddTextDetail.collected?AppColor.darkRed:AppColor.lightGreen,
                                  fontSize: deviceWidth*0.03,
                                ),
                              ),
                            ],
                          ),
                          onPressed:()=>saveOrCancel(tddCurCharacter, tddTextDetail.collected),
                        ),
                      ),

                      // 已学会
                      if(tddParentPage == "studyPage" && !tddCurCourseLearntCharacter.contains(tddCurCharacter))SizedBox(
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
                          onPressed:()=> hasLearnt(tddCurCharacter),
                        ),
                      ),

                      // 下一个
                      if(tddParentPage == "studyPage")SizedBox(
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
                          onPressed: () => setState(() {
                            if(tddCharacterIndex == tddCurCourseAllCharacter.length - 1) tddCharacterIndex = 0;
                            else ++tddCharacterIndex;
                            tddCurCharacter = tddCurCourseAllCharacter[tddCharacterIndex];
                            getText(tddCurCharacter);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
          ),

        ),
      ),

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

// 画SVG（来自网络字符串而不是本地svg文件）
class SvgPainter extends CustomPainter {
  String _svgCode;  // svg源码
  DrawableRoot svgRoot;
  SvgPainter(String svgCode){
    _svgCode = svgCode;
    loadAsset();
  }

  void loadAsset() async {
    this.svgRoot = await svg.fromSvgString(_svgCode, _svgCode);
  }

  // 定义画笔
  Paint _paint = Paint()
    ..color = AppColor.commonTextColor //画笔颜色
    ..strokeCap = StrokeCap.round //画笔笔触类型
    ..isAntiAlias = true //是否启动抗锯齿
    ..strokeWidth = 1.0; //画笔的宽度

  @override
  void paint(Canvas canvas, Size size) {
    if (this.svgRoot != null) {
      svgRoot.scaleCanvasToViewBox(canvas, size);
      svgRoot.clipCanvasToViewBox(canvas);
      svgRoot.draw(canvas, Rect.fromLTRB(0, 0, size.width, size.height));
    }
  }

  @override
  bool shouldRepaint(SvgPainter oldDelegate){
    return _svgCode != oldDelegate._svgCode;
  }
}

// 为了省代码。
TextSpan getTextSpan(String text, Color color, String font, double fontSize){
  if(text.length > 4) fontSize = fontSize / text.length * 4;
  return TextSpan(
    text: text,
    style:TextStyle(
      fontFamily: font,
      color:color,
      fontSize: fontSize,
    ),
  );
}
