

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 fcd

var fcdCharacterDetail = FcdCharacterDetail.origin();

class FcdCharacterDetail {
  List all;
  List learnt;
  List unLearnt;

  FcdCharacterDetail(
    this.all,
    this.learnt,
    this.unLearnt,
  );
  FcdCharacterDetail.origin(){
    this.all = [];
    this.learnt = [];
    this.unLearnt = [];
  }

  factory FcdCharacterDetail.fromJson(Map<String, dynamic> json) {
    List unLearnt = [];
    List all = json['all'];
    List learnt = json['learnt'];
    all.forEach((e) {
      if(!learnt.contains(e)) unLearnt.add(e);
    });
    return FcdCharacterDetail(all,learnt,unLearnt);
  }
}
