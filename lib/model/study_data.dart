

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 sd

//-------------------- 本地变量--------------------------
var sdTextbookDetail = SdTextbookDetail.origin(); // 教材详细内容
var sdTextbookName;      // 进入本页显示的教材名字
List sdTextbookNames = [];    // 所有教材名字

//---------------------网络数据--------------------------------
// 教材详细内容
class SdTextbookDetail {
  List courses;    // 课文
  List allWords;   // 课文的字
  List allLearntWords;  // 课文中已经学过的字
  String lastLearntCourseName; // 上次学到的课文名字

  SdTextbookDetail(
    this.courses,
    this.allWords,
    this.allLearntWords,
    this.lastLearntCourseName
  );
  // 默认命名构造函数
  SdTextbookDetail.origin(){
    this.courses = ['加载中'];
    this.allWords = [[]];
    this.allLearntWords = [[]];
    this.lastLearntCourseName = "";
  }

  factory SdTextbookDetail.fromJson(Map<String, dynamic> json) {
    return SdTextbookDetail(
        json['courses'],
        json['allCharacters'],
        json['allLearntCharacters'],
        json['lastLearntCourseName']
    );
  }
}