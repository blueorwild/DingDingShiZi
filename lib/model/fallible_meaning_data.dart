

// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 fmd


var fmdDetail = FmdDetail.origin();

class FmdDetail {
  List all;
  List learnt;
  List unLearnt;

  FmdDetail(
      this.all,
      this.learnt,
      this.unLearnt,
      );
  FmdDetail.origin(){
    this.all = [];
    this.learnt = [];
    this.unLearnt = [];
  }

  factory FmdDetail.fromJson(Map<String, dynamic> json) {
    List unLearnt = [];
    List all = json['all'];
    List learnt = json['learnt'];
    all.forEach((e) {
      if(!learnt.contains(e)) unLearnt.add(e);
    });
    return FmdDetail(all,learnt,unLearnt);
  }
}
