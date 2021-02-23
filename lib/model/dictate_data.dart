
// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 dd

// 本地的
List ddAllWord;   // 此批听写的所有词
var ddWordDetail = DdWordDetail.origin();   // 听写的词的细节
List ddTextName;  // 课文名字(对应每个词的)
List ddTextbookName; // 教材名字(对应每个词的)
String ddParentPage;   // 父页面名字


// 教材详细内容
class DdWordDetail {
  List tokens;
  List pinyins;
  List explanations;
  List dictationOps;
  List pinyinOps;
  bool collected;

  DdWordDetail(
    this.tokens,
    this.pinyins,
    this.explanations,
    this.dictationOps,
    this.pinyinOps,
    this.collected,
  );
  DdWordDetail.origin(){
    this.tokens = [];
    this.pinyins = [];
    this.explanations = [];
    this.dictationOps = [];
    this.pinyinOps = [];
    this.collected = false;
  }


  factory DdWordDetail.fromJson(Map<String, dynamic> json) {
    return DdWordDetail(
      json['wordInfo']['tokens'],
      json['wordInfo']['pinyins'],
      json['wordInfo']['explanations'],
      json['wordInfo']['dictationOps'],
      json['wordInfo']['pinyinOps'],
      json['collected']
    );
  }
}