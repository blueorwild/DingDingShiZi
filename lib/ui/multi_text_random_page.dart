
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/dictate_data.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/common_func.dart';
import 'package:flutterapp/model/multi_text_random_data.dart';

import 'package:http/http.dart' as http;

class MultiTextRandomPage extends StatefulWidget{
  @override
  createState() => new _MultiTextRandomPageState();
}

var multiTextRandomPageContext;

class _MultiTextRandomPageState extends State<MultiTextRandomPage>{

  // 需要动态改变的状态值得放在build之外
  List curSelectedText = [];    // 当前选中的课文
  int curModel = 1;  // 当前模式 自动/手动
  int curRepeatTimeId = 0;   // 当前自动模式重复次数按钮的选中Id
  int curIntervalTimeId = 0;  // 当前自动模式间隔时间按钮的选中Id

  // 获取教材的信息（切换教材）
  void getTextBook(String textBookName) async {
    final response = await http.post('http://120.24.151.180:8080/api/record/get_textbook_info?userId=' + userId +'&textbookName=' + textBookName);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if (status['status'] == 200) setState(() {
        mtrdTextbookDetail = MtrdTextbookDetail.fromJson(data);

      });
      else alert(multiTextRandomPageContext, status['msg']);
    }
    else alert(multiTextRandomPageContext,"网络连接失败");
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
        alert(multiTextRandomPageContext, status['msg']);
        return;
      }
      else setState(() {
        mtrdTextbookNames = MtrdTextbookName.fromJson(data).names;
        if(mtrdTextbookName == '无') mtrdTextbookName = mtrdTextbookNames[0];
        getTextBook(mtrdTextbookName);
      });
    }
    else alert(multiTextRandomPageContext, "网络连接失败");
  }

  // 获取词语
  void getWord() async {
    // 拼接课文名
    String textNames = "";
    if(curSelectedText.isEmpty) {
      alert(multiTextRandomPageContext, '请选择要听写的课文！');
      return;
    }
    curSelectedText.forEach((element) {
      textNames += element;
      textNames += ',';
    });
    textNames = textNames.substring(0, textNames.length-1);  // 去除末尾的逗号

    final response = await http.post('http://120.24.151.180:8080/api/record/get_dictation_words?userId=' + userId +
        '&textbookName=' + mtrdTextbookName + '&courseNames=' + textNames);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] == 200) {
        var words = MtrdWord.fromJson(data);
        ddAllWord = [];  // 此批听写的所有词
        ddTextName = [];  // 课文名字(对应每个词的)
        ddTextbookName = []; // 教材名字(对应每个词的)
        for(int i = 0; i<words.words.length; ++i){
          ddAllWord.add(words.words[i]['text']);
          ddTextName.add(words.words[i]['courseName']);
          ddTextbookName.add(words.words[i]['textbookName']);
        }
        ddParentPage = 'mutliTextRandom';
        Navigator.pushReplacementNamed(multiTextRandomPageContext, dictatePage);
      }
      else alert(multiTextRandomPageContext, status['msg']);
    }
    else alert(multiTextRandomPageContext, "网络连接失败");
  }

  @override
  void initState(){
    super.initState();
    mtrdTextbookDetail = MtrdTextbookDetail.origin();
    mtrdTextbookNames = MtrdTextbookName.origin().names;
    getTextbookName();
  }

  @override
  Widget build(BuildContext context) {
    multiTextRandomPageContext = context;
    return Scaffold(
      // 页面是个大container
      body: WillPopScope(
        onWillPop: ()async{
          Navigator.pushReplacementNamed(context, practicePage);
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
              // 返回按钮 + 下拉选择框 + 主页按钮
              Container(
                alignment: Alignment(-1, 0),  // x/y,-1~+1,(0,0)表示正中
                margin: EdgeInsets.only(top: deviceHeight*(devicePaddingTopRate + 0.02)),
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
                      ),
                      onPressed:()=>Navigator.pushReplacementNamed(context, practicePage),
                    ),

                    // 下拉选择框
                    Container(
                      alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                      width: deviceWidth*0.6,
                      height: deviceHeight*0.06,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: AppColor.searchBoxBorderColor),
                        color: AppColor.commonBoxFillColor,
                        borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.03)),
                      ),
                      child: new DropdownButton(
                        value: mtrdTextbookName,
                        icon: new Icon(
                          Icons.arrow_drop_down,
                          color: AppColor.commonIconColor,
                          size: deviceWidth*0.07,
                        ),
                        items: mtrdTextbookNames.map((item) =>DropdownMenuItem(
                          child: SizedBox(
                            width: deviceWidth*0.4,
                            child: Text(item,   // 真正显示的东西
                              textAlign: TextAlign.center,
                              style: TextStyle(color: mtrdTextbookName == item ? AppColor.commonTextColor:AppColor.unSelectTextColor),
                            ),
                          ),
                          value: item,
                        )).toList(),
                        onChanged: (param){  // 这个类型是value的类型，为了少一个参数试出来了
                          getTextBook(param);
                          mtrdTextbookName = param;
                        },
                        underline: Container(),   // 不要下划线
                        isDense: true,
                      ),
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

              // 课文 + 开始按钮
              Container(
                alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
                margin: EdgeInsets.fromLTRB(0,deviceHeight*0.025,0,0),
                padding: EdgeInsets.symmetric(vertical: deviceHeight*0.01, horizontal: deviceWidth*0.02),
                height: deviceHeight*0.85,
                width: deviceWidth*0.9,
                decoration: BoxDecoration(
                  color: AppColor.commonBoxFillColor,
                  borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.015)),
                ),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 课文条目
                    Container(
                      alignment: Alignment(0, -1),  // x/y,-1~+1,(0,0)表示正中
                      height: deviceHeight*0.75,
                      child: Scrollbar(
                        child:ListView.builder(
                          padding: EdgeInsets.all(0),   // 又有默认值
                          itemCount: mtrdTextbookDetail.courses.length,
                          itemBuilder: (context, index) {
                            int courseIndex = index + 1;  // 要显示的课文的序号是下标加1

                            return Container(
                              alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                              margin: EdgeInsets.only(top: deviceHeight*0.015),
                              height: deviceHeight*0.06,
                              decoration: BoxDecoration(
                                color: AppColor.lightBlue,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              child: FlatButton(
                                padding: EdgeInsets.all(0),   // 默认值
                                child: Stack(
                                  alignment: Alignment(-1,0),
                                  children:[
                                    // 代表进度的背景矩形
                                    Container(
                                      width: mtrdTextbookDetail.numWords[index] == 0 ? 0 :
                                      deviceWidth * 0.86 * mtrdTextbookDetail.numPracticedWords[index] / mtrdTextbookDetail.numWords[index],
                                      decoration: BoxDecoration(
                                        color: AppColor.commonBlue,
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                      ),
                                    ),

                                    // 文本
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.08),
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(courseIndex.toString() + '.' + mtrdTextbookDetail.courses[index],
                                            style: TextStyle(
                                              color: AppColor.commonTextColor,
                                              fontSize: deviceWidth*0.05,
                                            ),
                                          ),
                                          Text(mtrdTextbookDetail.numPracticedWords[index].toString() + '/' + mtrdTextbookDetail.numWords[index].toString(),
                                            style: TextStyle(
                                              color: AppColor.studyProgressColor,
                                              fontSize: deviceWidth*0.04,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 选中按钮
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: deviceWidth*0.8),
                                      height: deviceWidth * 0.06,
                                      width: deviceWidth * 0.06,
                                      child:IconButton(
                                        padding: EdgeInsets.all(0),   // 默认8.0
                                        icon:curSelectedText.contains(mtrdTextbookDetail.courses[index])? Icon(
                                          Icons.check_circle,
                                          color: AppColor.darkBlue,
                                          size: deviceWidth*0.05,
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
                                  String text = mtrdTextbookDetail.courses[index];
                                  if(curSelectedText.contains(text)) curSelectedText.remove(text);
                                  else curSelectedText.add(text);
                                }),
                              ),
                            );
                          },
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
                        onPressed: () => getWord(),
                      ),
                    ),
                  ],
                ),
              ),

              /*
            // 两个模式按钮
            Container(
              margin:EdgeInsets.only(top: deviceHeight*0.01),
              height: deviceHeight*0.1,
              width: deviceWidth*0.9,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  // 自动模式按钮
                  Container(
                    alignment: Alignment.center,
                    height: deviceHeight*0.056,
                    width: deviceWidth*0.3,
                    decoration: BoxDecoration(
                      color: curModel == 0 ? AppColor.commonBlue : AppColor.lightBlueButton,
                      borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                    ),
                    child:FlatButton(
                      padding: EdgeInsets.all(0),   // 默认值
                      child:Text('自动模式',
                        style: TextStyle(
                          color: curModel == 0 ? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                          fontSize: deviceWidth*0.04,
                        ),
                      ),
                      onPressed: () {
                        setState(() { curModel = 0;});
                        showModalBottomSheet<int>(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: deviceHeight*0.36,
                              child:Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  // 标题+确定按钮
                                  Container(
                                    width: deviceWidth,
                                    height: deviceHeight * 0.07,
                                    child:Stack(
                                      children: [
                                        Center(
                                          child:Text("自动模式设置",
                                            style: TextStyle(
                                              color: AppColor.unSelectTextColor,
                                              fontSize: deviceWidth*0.05,
                                            ),
                                          ),
                                        ),

                                        // 确定按钮
                                        Container(
                                          width: deviceWidth*0.2,
                                          margin: EdgeInsets.only(left: deviceWidth*0.8),
                                          child:IconButton(
                                            padding: EdgeInsets.all(0),   // 默认8.0
                                            icon: Icon(
                                              Icons.check,
                                              color: AppColor.commonBlue,
                                              size: deviceWidth*0.08,
                                            ),
                                            onPressed:()=>Navigator.pop(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 分割线
                                  Container(
                                    alignment: Alignment(0,0),
                                    height: deviceHeight*0.002,
                                    color: AppColor.splitLineColor,
                                  ),

                                  // 重复次数（builder 是为了在此子窗口能够即时改变状态）
                                  Builder(
                                    builder: (BuildContext repeatTimeContext) {
                                      return Container(
                                          height: deviceHeight * 0.12,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              // 文字
                                              Text("重复次数",
                                                style: TextStyle(
                                                  color: AppColor.commonTextColor,
                                                  fontSize: deviceWidth * 0.05,
                                                ),
                                              ),

                                              // 两个按钮
                                              Container(
                                                height: deviceHeight*0.056,
                                                width: deviceWidth*0.2,
                                                decoration: BoxDecoration(
                                                  color: curRepeatTimeId == 0? AppColor.commonBlue : AppColor.lightBlue,
                                                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                                                ),
                                                child:FlatButton(
                                                  padding: EdgeInsets.all(0),   // 默认值
                                                  child:Text('2次',
                                                    style: TextStyle(
                                                      color: curRepeatTimeId == 0? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                                                      fontSize: deviceWidth*0.045,
                                                    ),
                                                  ),
                                                  onPressed: (){
                                                    curRepeatTimeId = 0;
                                                    (repeatTimeContext as Element).markNeedsBuild();
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: deviceHeight*0.056,
                                                width: deviceWidth*0.2,
                                                decoration: BoxDecoration(
                                                  color: curRepeatTimeId == 1? AppColor.commonBlue : AppColor.lightBlue,
                                                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                                                ),
                                                child:FlatButton(
                                                  padding: EdgeInsets.all(0),   // 默认值
                                                  child:Text('3次',
                                                    style: TextStyle(
                                                      color: curRepeatTimeId == 1? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                                                      fontSize: deviceWidth*0.045,
                                                    ),
                                                  ),
                                                  onPressed: (){
                                                    curRepeatTimeId = 1;
                                                    (repeatTimeContext as Element).markNeedsBuild();
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                      );
                                    },
                                  ),

                                  // 分割线
                                  Container(
                                    alignment: Alignment(0,0),
                                    width: deviceWidth*0.8,
                                    height: deviceHeight*0.002,
                                    color: AppColor.splitLineColor,
                                  ),

                                  // 间隔时间
                                  Builder(
                                    builder: (BuildContext intervalTimeContext) {
                                      return Container(
                                          height: deviceHeight * 0.12,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              // 文字
                                              Text("间隔时间",
                                                style: TextStyle(
                                                  color: AppColor.commonTextColor,
                                                  fontSize: deviceWidth * 0.05,
                                                ),
                                              ),

                                              // 两个按钮
                                              Container(
                                                height: deviceHeight*0.056,
                                                width: deviceWidth*0.2,
                                                decoration: BoxDecoration(
                                                  color: curIntervalTimeId == 0? AppColor.commonBlue : AppColor.lightBlue,
                                                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                                                ),
                                                child:FlatButton(
                                                  padding: EdgeInsets.all(0),   // 默认值
                                                  child:Text('5s',
                                                    style: TextStyle(
                                                      color: curIntervalTimeId == 0? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                                                      fontSize: deviceWidth*0.045,
                                                    ),
                                                  ),
                                                  onPressed: (){
                                                    curIntervalTimeId = 0;
                                                    (intervalTimeContext as Element).markNeedsBuild();
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: deviceHeight*0.056,
                                                width: deviceWidth*0.2,
                                                decoration: BoxDecoration(
                                                  color: curIntervalTimeId == 1? AppColor.commonBlue : AppColor.lightBlue,
                                                  borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                                                ),
                                                child:FlatButton(
                                                  padding: EdgeInsets.all(0),   // 默认值
                                                  child:Text('3s',
                                                    style: TextStyle(
                                                      color: curIntervalTimeId == 1? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                                                      fontSize: deviceWidth*0.045,
                                                    ),
                                                  ),
                                                  onPressed: (){
                                                    curIntervalTimeId = 1;
                                                    (intervalTimeContext as Element).markNeedsBuild();
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                      );
                                    },
                                  ),
                                ],
                              )
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // 手动模式按钮
                  Container(
                    alignment: Alignment.center,
                    height: deviceHeight*0.056,
                    width: deviceWidth*0.3,
                    decoration: BoxDecoration(
                      color: curModel == 1 ? AppColor.commonBlue : AppColor.lightBlueButton,
                      borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.028)),
                    ),
                    child:FlatButton(
                      padding: EdgeInsets.all(0),   // 默认值
                      child:Text('手动模式',
                        style: TextStyle(
                          color: curModel == 1 ? AppColor.baseCardTextColor : AppColor.blueCardTextColor,
                          fontSize: deviceWidth*0.04,
                        ),
                      ),
                      onPressed: () => setState(() { curModel = 1;}),
                    ),
                  ),
                ],
              ),
            ),

             */
            ],
          ),
        ),
      )

    );
  }

}
