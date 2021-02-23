
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

import 'package:flutterapp/model/practice_data.dart';
import 'package:flutterapp/model/dictate_data.dart';
import 'package:flutterapp/model/text_order_data.dart';
import 'package:flutterapp/model/multi_text_random_data.dart';
import 'package:flutterapp/model/single_select_word_data.dart';
import 'package:flutterapp/model/single_select_pinyin_data.dart';



class PracticePage extends StatefulWidget{
  @override
  createState() => new _PracticePageState();
}

var practicePageContext;

class _PracticePageState extends State<PracticePage>{

  // 获取课文顺序
  void getTextOrder(){
    todTextbookName = pdCurrentTextbookName;
    Navigator.pushReplacementNamed(practicePageContext, textOrderPage);
  }

  // 获取多课随机
  void getMultiTextRandom(){
    mtrdTextbookName = pdCurrentTextbookName;
    Navigator.pushReplacementNamed(practicePageContext, multiTextRandomPage);
  }

  // 获取记录随机
  void getRecordRandom() async {
    final response = await http.post('http://120.24.151.180:8080/api/record/get_dictation_words2?userId=' + userId);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) {
        var words = PdWord.fromJson(data);
        if(words.words.length == 0) {
          alert(practicePageContext, "当前记录中没有词，请添加错误或收藏后再来");
          return;
        }
        ddAllWord = [];  // 此批听写的所有词
        ddTextName = [];  // 课文名字(对应每个词的)
        ddTextbookName = []; // 教材名字(对应每个词的)
        for(int i = 0; i<words.words.length; ++i){
          ddAllWord.add(words.words[i]['text']);
          ddTextName.add(words.words[i]['courseName']);
          ddTextbookName.add(words.words[i]['textbookName']);
        }
        ddParentPage = 'recordRandom';
        Navigator.pushReplacementNamed(practicePageContext, dictatePage);
      }
      else alert(practicePageContext, status['msg']);
    }
    else alert(practicePageContext, "网络连接失败");
  }

  // 获取听音选词
  void getSelectWordBySound() async {
    final response = await http.post('http://120.24.151.180:8080/api/common/get_dictation_word_content?userId=' + userId);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200){
        sswdSelectDetail = SswdSelectDetail.fromJson(data);
        if(sswdSelectDetail.option == null || sswdSelectDetail.pinyin == null || sswdSelectDetail.word == null){
          print(sswdSelectDetail.word);
          alert(practicePageContext, "当前题库为空");
          return;
        }
        Navigator.pushReplacementNamed(practicePageContext, singleSelectWordPage);
      }
      else alert(practicePageContext, status['msg']);
    }
    else alert(practicePageContext, "网络连接失败");

  }

  // 获取看字选音
  void getSelectSoundByWord() async {
    final response = await http.post('http://120.24.151.180:8080/api/common/get_word_pinyin_ops?userId=' + userId);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200){
        sspdSelectDetail = SspdSelectDetail.fromJson(data);
        if(sspdSelectDetail.option == null || sspdSelectDetail.pinyin == null || sspdSelectDetail.word == null){
          alert(practicePageContext, "当前题库为空");
          return;
        }
        Navigator.pushNamed(practicePageContext, singleSelectPinyinPage);
      }
      else alert(practicePageContext, status['msg']);
    }
    else alert(practicePageContext, "网络连接失败");
  }

  @override
  void initState(){
    super.initState();
  }

  //  ---------------------------------展示的界面-------------------------------
  @override
  Widget build(BuildContext context) {
    practicePageContext = context;

    return new Scaffold(
      // 页面是个大container，个人习惯
      body: WillPopScope(
        onWillPop: () async{
          Navigator.pushReplacementNamed(context, homePage);
          return true;
        },
        child: Container(
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
                  onPressed:()=>Navigator.pushReplacementNamed(context, homePage),
                ),
              ),

              // 第二行 听写文字
              Container(
                alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                height: deviceHeight*0.05,
                //color: AppColor.commonBoxFillColor,
                // 文字
                child: Text("听写",
                  style: TextStyle(
                    color: AppColor.commonTextColor,
                    fontSize: deviceWidth*0.05,
                  ),
                ),
              ),

              // 第三行 分割线
              Container(
                alignment: Alignment(0,0),
                width: deviceWidth*0.8,
                height: deviceHeight*0.002,
                color: AppColor.splitLineColor,
              ),

              // 第四行 跳转功能按钮
              Container(
                height: deviceHeight*0.42,   // 目前有两行，每行高0.21
                width: deviceWidth*0.8,
                //color: Color.fromRGBO(19, 19, 96, 1),
                child: Table(  // 行高默认元素高度，列宽默认均分
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        children: [
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.chrome_reader_mode, AppColor.darkRed, '课文顺序', getTextOrder),
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.burst_mode, AppColor.lightGreen, '多课随机', getMultiTextRandom),
                        ]
                    ),
                    TableRow(
                        children: [
                          // 生僻俗语按钮
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.toys, AppColor.darkBlue, '记录随机', getRecordRandom),
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

              // 第五行 单选文字
              Container(
                alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                margin: EdgeInsets.only(top:deviceHeight*0.02),
                height: deviceHeight*0.05,
                //color: AppColor.commonBoxFillColor,
                // 文字
                child: Text("单选",
                  style: TextStyle(
                    color: AppColor.commonTextColor,
                    fontSize: deviceWidth*0.05,
                  ),
                ),
              ),

              // 第六行 分割线
              Container(
                alignment: Alignment(0,0),
                width: deviceWidth*0.8,
                height: deviceHeight*0.002,
                color: AppColor.splitLineColor,
              ),

              // 第七行 跳转功能按钮
              Container(
                height: deviceHeight*0.21,   // 目前有两行，每行高0.21
                width: deviceWidth*0.8,
                child: Table(  // 行高默认元素高度，列宽默认均分
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        children: [
                          // 生僻字+生僻词按钮
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.headset, AppColor.darkYellow, '听音选词', getSelectWordBySound),
                          getPictureButton(deviceWidth*0.3, deviceHeight*0.17, Icons.remove_red_eye, AppColor.commonBlue, '看字选音', getSelectSoundByWord),
                        ]
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
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