
// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 pd

String pdCurrentTextbookName;   // 当前教材名字

// 选中的词(记录随机)
class PdWord{
  List words;
  List collectedWords;

  PdWord(
    this.words,
    this.collectedWords
  );

  factory PdWord.fromJson(Map<String, dynamic> json) {
    return PdWord(
        json['randomWords'],
        json['collectedWords']
    );
  }
}