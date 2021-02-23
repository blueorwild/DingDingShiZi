




// 变量名均加上当前文件名首字母，防止冲突
// 本文件 为 fwd

var fwdWordDetail = FwdWordDetail.origin();

class FwdWordDetail {
  List all;
  List learnt;
  List unLearnt;

  FwdWordDetail(
      this.all,
      this.learnt,
      this.unLearnt,
      );
  FwdWordDetail.origin(){
    this.all = [];
    this.learnt = [];
    this.unLearnt = [];
  }

  factory FwdWordDetail.fromJson(Map<String, dynamic> json) {
    List unLearnt = [];
    List all = json['all'];
    List learnt = json['learnt'];
    all.forEach((e) {
      if(!learnt.contains(e)) unLearnt.add(e);
    });
    return FwdWordDetail(all,learnt,unLearnt);
  }
}