class APIConfig {
  String token;
  String cocode;
  String sub1len;
  String sub2len;
  String sub3len;
  String runlen;
  String err;
  bool hasErr;

  APIConfig(
      {this.token,
      this.cocode,
      this.sub1len,
      this.sub2len,
      this.sub3len,
      this.runlen,
      this.hasErr,
      this.err});

  bool hasError() {
    return this.hasErr;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "token": token,
      "cocode": cocode,
      "sub1len": sub1len,
      "sub2len": sub2len,
      "sub3len": sub3len,
      "runeln": runlen,
    };
  }

  factory APIConfig.fromJson(Map<String, dynamic> json) {
    return APIConfig(
        token: json['access_token'],
        cocode: json['cocode'],
        sub1len: json['sub1len'],
        sub2len: json['sub2len'],
        sub3len: json['sub3len'],
        runlen: json['runlen'],
        hasErr: (json['err'] != null),
        err: json['msg']);
  }
}

class FAInfo {
  String desc;
  String loc;
  String acqdate;
  bool info;
  int qty;
  String err;
  bool hasErr;

  FAInfo(
      {this.desc,
      this.loc,
      this.qty,
      this.acqdate,
      this.info,
      this.hasErr,
      this.err});

  bool hasError() {
    return this.hasErr;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "desc": desc,
      "loc": loc,
      "acqdate": acqdate,
      "info": info,
      "qty": qty,
    };
  }
}
