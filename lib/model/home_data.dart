
// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 hd



String hdCurrentTextbookName = "";   // 当前教材名字
List hdAllTextbookName = [];  // 获取的所有教材名字
int hdNumLearntWords = 0;         // 当前教材已学习的字数
int hdNumTotalWords = 0;          // 当前教材总共字数


// 学习进度格式
class StudyProgress {
  String currentTextbookName;
  int numLearntWords;
  int numTotalWords;

  StudyProgress({this.currentTextbookName, this.numLearntWords, this.numTotalWords});

  factory StudyProgress.fromJson(Map<String, dynamic> json) {
    return StudyProgress(
      currentTextbookName: json['currentTextbookName'],
      numLearntWords: json['numLearntCharacters'],
      numTotalWords: json['numTotalCharacters'],
    );
  }
}

// 教材名
class HdTextbookName {
  List names;    // 教材名字

  HdTextbookName(this.names);

  factory HdTextbookName.fromJson(Map<String, dynamic> json) {
    return HdTextbookName(
      json['textbookNames'],
    );
  }
}
