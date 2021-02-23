

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 tod

// 本地的
var todTextbookDetail;    // 进入本页应该显示的教材内容
String todTextbookName;      // 进入本页显示的教材名字
List todTextbookNames;    // 所有教材名字

// 教材详细内容
class TodTextbookDetail {
  List courses;    // 所有课文名
  List numWords;   // 每篇课文的总词数
  List numPracticedWords;  // 课文中已经学过的字

  TodTextbookDetail(
    this.courses,
    this.numWords,
    this.numPracticedWords,
  );
  TodTextbookDetail.origin(){
    this.courses = [todTextbookName];
    this.numWords = [0];
    this.numPracticedWords = [0];
  }

  factory TodTextbookDetail.fromJson(Map<String, dynamic> json) {
    return TodTextbookDetail(
        json['courses'],
        json['numWords'],
        json["numPracticedWords"],
    );
  }
}

// 教材名字
class TodTextbookName {
  List names;    // 教材名字

  TodTextbookName(
    this.names
  );

  TodTextbookName.origin(){
    this.names = [todTextbookName];
  }

  factory TodTextbookName.fromJson(Map<String, dynamic> json) {
    return TodTextbookName(
      json['textbookNames'],
    );
  }
}