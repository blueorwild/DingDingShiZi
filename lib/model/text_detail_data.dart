

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 tdd


// 本地变量，方便页面跳转的传参
var tddTextDetail = TddWordInfo.origin();       // 进入本页应该显示的字的所有内容
String tddParentPage;    // 进入本页的父页面名字，不同页面跳转进来显示的内容有所区别
List tddCurCourseAllCharacter;  // 当前课文的所有字
List tddCurCourseLearntCharacter;  // 当前课文已学过的字
int tddCharacterIndex;   // 当前文字在当前课文的所有字的索引
String tddCourseName;  // 字属于的课文名
String tddTextBookName;  // 字属于的教材名
String tddCurCharacter;

// 数据格式
class TddWordInfo{
  List pinyins;       // 拼音
  int numStroke;      // 笔画数
  String radical;     // 部首
  String struct;      // 结构
  List explanationItems;   // 字释义的条目
  var explanation;   // 字释义的具体内容
  List strokeAnim;    // 字的svg动画
  bool collected;    // 字是否被收藏

  TddWordInfo(
    this.pinyins,
    this.numStroke,
    this.radical,
    this.struct,
    this.explanationItems,
    this.explanation,
    this.strokeAnim,
    this.collected,
  );
  TddWordInfo.origin(){
    this.pinyins = ['null'];
    this.numStroke = 0;
    this.radical = "加载中";
    this.struct = "加载中";
    this.explanationItems = ["加载中"];
    this.explanation = [["加载中"]];
    this.strokeAnim = [];
    this.collected = false;
  }

  factory TddWordInfo.fromJson(Map<String, dynamic> json) {
    return TddWordInfo(
      json['characterInfo']['pinyins'],
      json['characterInfo']['numStroke'],
      json['characterInfo']['radical'],
      json['characterInfo']['struct'],
      json['characterInfo']['explanationItems'],
      json['characterInfo']['explanation'],
      json['characterInfo']['strokeAnim'],
      json['collected'],
    );
  }
}