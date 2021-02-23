

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 fdd

List fddAllText;  // 所有文本
List fddAllLearnt;  // 所有已学会的文本
String fddText;      // 要显示的完整文本
List fddSplitText;    // 把完整文本按逗号和每行最大字数分割好
String fddParentPage;  // 父页面
int fddCurTextIndex = 0; // 当前文本在此批里的索引

var fddTextDetail = FddTextDetail.origin();

class FddTextDetail {
  List pinyin;
  List meaning;

  FddTextDetail(
    this.pinyin,
    this.meaning,
  );
  FddTextDetail.origin(){
    this.pinyin = [];
    for(int i = 0; i < fddText.length; ++i) this.pinyin.add('null');
    this.meaning = [];
  }

  factory FddTextDetail.fromJson(Map<String, dynamic> json) {
    // 去掉pinyin的空串
    List pinyin = json['pinyins'];
    pinyin.remove("");
    return FddTextDetail(
      pinyin,
      json['explanations'],
    );
  }
}