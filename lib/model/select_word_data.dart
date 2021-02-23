

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 swd

var swdCourseDetail = SwdCourseDetail.origin();  // 进入本页应该显示的课文内容
String swdCourseName;  // 课文名
String swdTextbookName;  // 教材名

// 数据格式
class SwdCourseDetail {
  List words;    // 该课文的所有词
  List practicedWords;   // 已练
  List mistakenWords;  // 错误
  List unPracticedWords;  // 未练，自行计算

  SwdCourseDetail(
    this.words,
    this.practicedWords,
    this.mistakenWords,
    this.unPracticedWords,
  );
  SwdCourseDetail.origin(){
    this.words = [];
    this.practicedWords = [];
    this.mistakenWords = [];
    this.unPracticedWords = [];
  }

  factory SwdCourseDetail.fromJson(Map<String, dynamic> json) {
    List words = json['words'];
    List practicedWords = json['practicedWords'];
    List mistakenWords = json['mistakenWords'];
    List unPracticedWords = [];
    words.forEach((ele) {
      if(!practicedWords.contains(ele) && !mistakenWords.contains(ele))
        unPracticedWords.add(ele);
    });
    return SwdCourseDetail(
      words,
      practicedWords,
      mistakenWords,
      unPracticedWords,
    );
  }
}