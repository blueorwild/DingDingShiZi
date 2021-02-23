
import 'dart:math';

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 sswd

var sswdSelectDetail;

class SswdSelectDetail {
  List word;     // 词语
  List pinyin;   // 拼音
  List option;   // 选项
  List textbookName;   // 词所属的教材
  List courseName;     // 词所属的课文名
  List isSave;   // 词的收藏状态

  SswdSelectDetail({
    this.word,
    this.pinyin,
    this.option,
    this.textbookName,
    this.courseName,
    this.isSave,
  });

  factory SswdSelectDetail.fromJson(Map<String, dynamic> json) {
    // 脏代码
    // 后台传的选项是非正确选项，需要把正确选项插进去，并且在随机位置
    List word = json['textList'];
    List option = json['optionsList'];
    // 插入随机位置
    for(int i = 0; i < option.length; ++i){
      int index = Random().nextInt(option[i].length - 1);
      option[i].insert(index, word[i]);
    }
    return SswdSelectDetail(
      word: word,
      pinyin: json['pinyinsList'],
      option: option,
      textbookName: json['textbookNameList'],
      courseName: json['courseNameList'],
      isSave: json['collectedList'],
    );
  }
}