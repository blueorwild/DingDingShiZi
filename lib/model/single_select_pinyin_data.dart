import 'dart:math';

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 sspd

var sspdSelectDetail;

class SspdSelectDetail {
  List word;     // 词语
  List pinyin;   // 拼音
  List option;   // 选项
  List textbookName;   // 词所属的教材
  List courseName;     // 词所属的课文名
  List isSave;   // 词的收藏状态

  SspdSelectDetail({
    this.word,
    this.pinyin,
    this.option,
    this.textbookName,
    this.courseName,
    this.isSave,
  });

  factory SspdSelectDetail.fromJson(Map<String, dynamic> json) {
    // 脏代码
    // 后台传的选项是非正确选项，需要把正确选项插进去，并且在随机位置
    // 另外，把拼音数组拼接成字符串
    List pinyin = json['pinyinsList'];
    // 拼音转为字符串
    for(int i = 0; i < pinyin.length; ++i){
      String str = "";
      pinyin[i].forEach((e){
        str = str + e + ' ';
      });
      str = str.substring(0, str.length-1);
      pinyin[i] = str;
    }
    List option = json['optionsList'];
    // 选项转为字符串
    for(int i = 0; i < option.length; ++i){
      for(int j = 0; j < option[i].length; ++j) {
        String str = "";
        option[i][j].forEach((e){
          str = str + e + ' ';
        });
        str = str.substring(0, str.length-1);
        option[i][j] = str;
      }
    }
    // 插入随机位置
    for(int i = 0; i < option.length; ++i){
      int index = Random().nextInt(option[i].length - 1);
      option[i].insert(index, pinyin[i]);
    }
    return SspdSelectDetail(
      word: json['textList'],
      pinyin: pinyin,
      option: option,
      textbookName: json['textbookNameList'],
      courseName: json['courseNameList'],
      isSave: json['collectedList'],
    );
  }
}