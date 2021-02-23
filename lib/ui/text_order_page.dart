
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutterapp/model/device_size.dart';
import 'package:flutterapp/model/routes.dart';
import 'package:flutterapp/model/color.dart';
import 'package:flutterapp/model/common_func.dart';

import 'package:flutterapp/model/text_order_data.dart';
import 'package:flutterapp/model/select_word_data.dart';



class TextOrderPage extends StatefulWidget{
  @override
  createState() => new _TextOrderPageState();
}

var textOrderPageContext;

class _TextOrderPageState extends State<TextOrderPage>{

  // 需要动态改变的状态值得放在build之外
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
        todTextbookDetail = TodTextbookDetail.fromJson(data);
      });
      else alert(textOrderPageContext, status['msg']);
    }
    else alert(textOrderPageContext,"网络连接失败");
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
        alert(textOrderPageContext, status['msg']);
        return;
      }
      else setState(() {
        todTextbookNames = TodTextbookName.fromJson(data).names;
        if(todTextbookName == '无') todTextbookName = todTextbookNames[0];
        getTextBook(todTextbookName);
      });
    }
    else alert(textOrderPageContext, "网络连接失败");
  }

  // 获取选词页面
  void getSelectWord(String courseName){
    swdCourseName = courseName;
    swdTextbookName = todTextbookName;
    Navigator.pushReplacementNamed(textOrderPageContext, selectWordPage);
  }

  @override
  void initState(){
    super.initState();
    todTextbookDetail = TodTextbookDetail.origin();
    todTextbookNames = TodTextbookName.origin().names;
    getTextbookName();
  }

  @override
  Widget build(BuildContext context) {
    textOrderPageContext = context;
    return Scaffold(
      // 页面是个大container
      body: WillPopScope(
        onWillPop: () async{
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
                        value: todTextbookName,
                        icon: new Icon(
                          Icons.arrow_drop_down,
                          color: AppColor.commonIconColor,
                          size: deviceWidth*0.07,
                        ),
                        items: todTextbookNames.map((item) =>DropdownMenuItem(
                          child: SizedBox(
                            width: deviceWidth*0.4,
                            child: Text(item,   // 真正显示的东西
                              textAlign: TextAlign.center,
                              style: TextStyle(color: todTextbookName == item ? AppColor.commonTextColor:AppColor.unSelectTextColor),
                            ),
                          ),
                          value: item,
                        )).toList(),
                        onChanged: (param){  // 这个类型是value的类型，为了少一个参数试出来了
                          getTextBook(param);
                          todTextbookName = param;
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

              // 课文
              Container(
                alignment: Alignment(-1, 0),  // x/y,-1~+1,(0,0)表示正中
                margin: EdgeInsets.fromLTRB(0,deviceHeight*0.025,0,0),
                padding: EdgeInsets.symmetric(vertical: deviceHeight*0.01, horizontal: deviceWidth*0.02),
                height: deviceHeight*0.85,
                width: deviceWidth*0.9,
                decoration: BoxDecoration(
                  color: AppColor.commonBoxFillColor,
                  borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.015)),
                ),
                child:Scrollbar(
                  child:ListView.builder(
                    padding: EdgeInsets.all(0),   // 又有默认值
                    itemCount: todTextbookDetail.courses.length,
                    itemBuilder: (context, index) {
                      int courseIndex = index + 1;  // 要显示的课文的序号是下标加1

                      return Container(
                        alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                        margin: EdgeInsets.only(top: deviceHeight*0.015),
                        height: deviceHeight*0.07,
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
                                width: todTextbookDetail.numWords[index] == 0 ? 0 :
                                deviceWidth * 0.86 * todTextbookDetail.numPracticedWords[index] / todTextbookDetail.numWords[index],
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
                                    Text(courseIndex.toString() + '.' + todTextbookDetail.courses[index],
                                      style: TextStyle(
                                        color: AppColor.commonTextColor,
                                        fontSize: deviceWidth*0.05,
                                      ),
                                    ),
                                    Text(todTextbookDetail.numPracticedWords[index].toString() + '/' + todTextbookDetail.numWords[index].toString(),
                                      style: TextStyle(
                                        color: AppColor.studyProgressColor,
                                        fontSize: deviceWidth*0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => getSelectWord(todTextbookDetail.courses[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /*
            // 两个按钮
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