

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 mtrd

// 本地的
var mtrdTextbookDetail;     // 进入本页应该显示的教材内容
List mtrdTextbookNames;    // 所有教材名字
var mtrdTextbookName;      // 进入本页显示的教材名字

// 教材详细内容
class MtrdTextbookDetail {
  List courses;    // 所有课文名
  List numWords;   // 每篇课文的总词数
  List numPracticedWords;  // 课文中已经学过的字

  MtrdTextbookDetail(
      this.courses,
      this.numWords,
      this.numPracticedWords,
      );
  MtrdTextbookDetail.origin(){
    this.courses = ['加载中'];
    this.numWords = [0];
    this.numPracticedWords = [0];
  }

  factory MtrdTextbookDetail.fromJson(Map<String, dynamic> json) {
    return MtrdTextbookDetail(
      json['courses'],
      json['numWords'],
      json["numPracticedWords"],
    );
  }
}

// 教材名字
class MtrdTextbookName {
  List names;    // 教材名字

  MtrdTextbookName(
    this.names
  );
  MtrdTextbookName.origin(){
    this.names = [mtrdTextbookName];
  }

  factory MtrdTextbookName.fromJson(Map<String, dynamic> json) {
    return MtrdTextbookName(
      json['textbookNames'],
    );
  }
}

// 选中课文的词
class MtrdWord{
  List words;
  List collectedWords;

  MtrdWord(
    this.words,
    this.collectedWords
  );

  factory MtrdWord.fromJson(Map<String, dynamic> json) {
    return MtrdWord(
      json['randomWords'],
      json['collectedWords']
    );
  }

}