
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

import 'package:flutterapp/model/study_data.dart';
import 'package:flutterapp/model/text_detail_data.dart';


class StudyPage extends StatefulWidget{
  @override
  createState() => new _StudyPageState();
}

var studyPageContext;

class _StudyPageState extends State<StudyPage>{

  // 需要动态改变的状态值得放在build之外
  var textController = TextEditingController();  // 文本输入框相关

  // 获取教材的信息（切换教材）
  void getTextBook(String textBookName) async {
    final response = await http.post('http://120.24.151.180:8080/api/learn/get_textbook_info?userId=' + userId +'&textbookName=' + textBookName);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      Utf8Decoder utf8decoder = Utf8Decoder(); // fix 中文乱码
      var data = json.decode(utf8decoder.convert(response.bodyBytes));
      // 先检查状态
      Map<String, dynamic> status = data;
      if(status['status'] != 200) {
        alert(studyPageContext, "获取教材信息失败，请检查网络");
        return;
      }
      else setState(() {
          sdTextbookDetail = SdTextbookDetail.fromJson(data);
      });
    }
    else alert(studyPageContext, "网络连接失败");
  }

  @override
  void initState(){
    super.initState();
    getTextBook(sdTextbookName);
  }

  @override
  Widget build(BuildContext context) {
    studyPageContext = context;
    return Scaffold(
      // 页面是个大container
      body: WillPopScope(  // 捕捉设备的真实返回键
        onWillPop: () async{  // 只能加大括号啊
          Navigator.of(context).pushReplacementNamed(homePage);
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
            // 子组件放在开始位置
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 返回按钮 + 下拉选择框
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
                      onPressed:()=>Navigator.pushReplacementNamed(context, homePage),
                    ),

                    // 下拉选择框
                    Container(
                      alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                      margin: EdgeInsets.only(right: deviceWidth*0.2),
                      width: deviceWidth*0.6,
                      height: deviceHeight*0.06,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: AppColor.searchBoxBorderColor),
                        color: AppColor.commonBoxFillColor,
                        borderRadius: BorderRadius.all(Radius.circular(deviceHeight*0.03)),
                      ),
                      child: new DropdownButton(
                        value: sdTextbookName,
                        icon: new Icon(
                          Icons.arrow_drop_down,
                          color: AppColor.commonIconColor,
                          size: deviceWidth*0.07,
                        ),
                        items: sdTextbookNames.map((item) =>DropdownMenuItem(
                          child: SizedBox(
                            width: deviceWidth*0.4,
                            child: Text(item,   // 真正显示的东西
                              textAlign: TextAlign.center,
                              style: TextStyle(color: sdTextbookName==item?AppColor.commonTextColor:AppColor.unSelectTextColor),
                            ),
                          ),
                          value: item,
                        )).toList(),
                        onChanged: (param){  // 这个类型是value的类型，为了少一个参数试出来了
                          getTextBook(param);
                          sdTextbookName = param;
                        },
                        underline: Container(),   // 不要下划线
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),

              // 课文字内容(expanded 用于解决搜索框在底部键盘弹起的问题)
              Expanded(
                flex: 1,
                child:Container(
                  alignment: Alignment(-1, 0),  // x/y,-1~+1,(0,0)表示正中
                  margin: EdgeInsets.fromLTRB(0,deviceHeight*0.025,0,0),
                  //height: deviceHeight*0.75,  // 继承父亲的高
                  width: deviceWidth*0.9,
                  decoration: BoxDecoration(
                    color: AppColor.commonBoxFillColor,
                    borderRadius: BorderRadius.all(Radius.circular(deviceWidth*0.015)),
                  ),
                  child:Scrollbar(
                    child:ListView.builder(
                      padding: EdgeInsets.all(0),   // 又有默认值
                      itemCount: sdTextbookDetail.courses.length,
                      itemBuilder: (context, index) {
                        int courseIndex = index + 1;  // 要显示的课文的序号是下标加1
                        // 每一个Container装一个课文，元素包括课文名、收藏图标、已学会的字占比、文字卡片。
                        // 首先计算该Container的高度
                        int wordNum = sdTextbookDetail.allWords[index].length;
                        int wordColumnNum = wordNum ~/ 4 + (wordNum % 4 == 0 ? 0 : 1);
                        return Container(
                          alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                          width: deviceWidth*0.9,
                          height: deviceWidth*wordColumnNum*0.225 + deviceHeight*0.06,
                          child: Column(
                            children:[
                              // 首先是一行 课文名、收藏图标、已学会的字占比
                              Container(
                                alignment: Alignment.center,
                                width: deviceWidth*0.9,
                                height: deviceHeight*0.05,
                                child:Row(
                                  children: [
                                    // 已学会的字占比
                                    Container(
                                      alignment: Alignment.center,
                                      width: deviceWidth*0.25,
                                      height: deviceHeight*0.05,
                                      child:Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "已学: ",
                                              style:TextStyle(
                                                color:AppColor.unSelectTextColor,
                                                fontSize: deviceHeight*0.022,
                                              ),
                                            ),
                                            TextSpan(
                                              text: sdTextbookDetail.allLearntWords[index].length.toString() + ' / ' + sdTextbookDetail.allWords[index].length.toString(),
                                              style:TextStyle(
                                                color: AppColor.studyProgressColor,
                                                fontSize: deviceHeight*0.022,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 课文名
                                    Container(
                                      width: deviceWidth*0.5,
                                      height: deviceHeight*0.05,
                                      alignment: Alignment.center,
                                      child:Text("$courseIndex." + sdTextbookDetail.courses[index],
                                        style: TextStyle(
                                          color: AppColor.commonTextColor,
                                          fontSize: deviceHeight*0.022,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    // 上次学到这里的图标
                                    Container(
                                      width: deviceWidth*0.1,
                                      height: deviceHeight*0.05,
                                      margin: EdgeInsets.only(left:deviceWidth*0.05),
                                      alignment: Alignment.center,
                                      child:sdTextbookDetail.lastLearntCourseName==sdTextbookDetail.courses[index]?Icon(
                                        Icons.star,
                                        color: AppColor.lightYellow,
                                        size: deviceWidth*0.07,
                                      ):null,
                                    ),
                                  ],
                                ),
                              ),

                              // 然后是一波字卡片
                              SizedBox(
                                height: deviceWidth*wordColumnNum*0.225,
                                width: deviceWidth*0.9,
                                child:Wrap(  // 自动换行的流式布局
                                  children: sdTextbookDetail.allWords[index].map<Widget>((item) => Container(
                                    margin: EdgeInsets.all(deviceWidth*0.02),
                                    alignment: Alignment.center,
                                    height: deviceWidth*0.185,
                                    width: deviceWidth*0.185,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(3)),
                                      color: sdTextbookDetail.allLearntWords[index].contains(item)?AppColor.commonBlue:AppColor.lightBlue,
                                    ),
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      child: Text(item,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: deviceWidth*0.1,
                                          color: sdTextbookDetail.allLearntWords[index].contains(item)?AppColor.baseCardTextColor:AppColor.blueCardTextColor,
                                        ),
                                      ),
                                      onPressed: (){
                                        // 传递给下一个页面相关值
                                        tddCurCharacter = item;
                                        tddParentPage = 'studyPage';
                                        tddCurCourseAllCharacter = sdTextbookDetail.allWords[courseIndex-1];
                                        tddCurCourseLearntCharacter = sdTextbookDetail.allLearntWords[courseIndex-1];
                                        tddCharacterIndex = tddCurCourseAllCharacter.indexOf(item);
                                        tddCourseName = sdTextbookDetail.courses[courseIndex-1];
                                        tddTextBookName = sdTextbookName;
                                        Navigator.pushReplacementNamed(context, textDetailPage);
                                      },
                                    ),
                                  )).toList(),
                                ),
                              ),

                              // 最后来个分割线
                              Container(
                                alignment: Alignment(0,0),
                                width: deviceWidth*0.8,
                                height: deviceHeight*0.002,
                                color: AppColor.splitLineColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // 搜索框
              Container(
                alignment: Alignment(0, 0),  // x/y,-1~+1,(0,0)表示正中
                padding: EdgeInsets.symmetric(horizontal: deviceWidth*0.01),
                margin: EdgeInsets.symmetric(vertical: deviceHeight*0.025),
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
                            for (int i = 0; i < sdTextbookDetail.courses.length; ++i) {
                              if (sdTextbookDetail.allWords[i].contains(text)) {
                                // 传递给下一个页面相关值
                                tddCurCharacter = text;
                                tddParentPage = 'studyPage';
                                tddCurCourseAllCharacter = sdTextbookDetail.allWords[i];
                                tddCurCourseLearntCharacter = sdTextbookDetail.allLearntWords[i];
                                tddCharacterIndex = tddCurCourseAllCharacter.indexOf(text);
                                tddCourseName = sdTextbookDetail.courses[i];
                                tddTextBookName = sdTextbookName;
                                Navigator.pushReplacementNamed(context, textDetailPage);
                                return;
                              }
                            }
                            alert(context, "当前课本不存在所查询的字");
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
                      onPressed: (){
                        String text = textController.text;
                        if(text == '') alert(context, "输入为空！");
                        else {
                          for (int i = 0; i < sdTextbookDetail.courses.length; ++i) {
                            if (sdTextbookDetail.allWords[i].contains(text)) {
                              // 传递给下一个页面相关值
                              tddCurCharacter = text;
                              tddParentPage = 'studyPage';
                              tddCurCourseAllCharacter = sdTextbookDetail.allWords[i];
                              tddCurCourseLearntCharacter = sdTextbookDetail.allLearntWords[i];
                              tddCharacterIndex = tddCurCourseAllCharacter.indexOf(text);
                              tddCourseName = sdTextbookDetail.courses[i];
                              tddTextBookName = sdTextbookName;
                              Navigator.pushReplacementNamed(context, textDetailPage);
                              return;
                            }
                          }
                          alert(context, "当前课本不存在所查询的字");
                        }
                      },
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