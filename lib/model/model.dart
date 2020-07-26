class SAPFA {
  String barcodeId = "";
  String coCode = "";
  String mainCode = "";
  String subCode = "";
  String desc = "";
  String loc = "";
  String acqdate = "";
  String photo;
  int qty = 0;
  int scanqty = 0;
  int createdAt = 0;

  SAPFA(
      {this.barcodeId,
      this.coCode,
      this.mainCode,
      this.subCode,
      this.desc,
      this.loc,
      this.acqdate,
      this.photo,
      this.qty,
      this.scanqty,
      this.createdAt});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "barcodeid": barcodeId,
      "cocode": coCode,
      "maincode": mainCode,
      "subcode": subCode,
      "desc": desc,
      "loc": loc,
      "acqdate": acqdate,
      "photo": photo,
      "qty": qty
    };
  }

  SAPFA.fromMap(Map<String, dynamic> map) {
    barcodeId = map['barcodid'];
    coCode = map['cocode'];
    mainCode = map['maincode'];
    subCode = map['subcode'];
    desc = map['desc'];
    loc = map['loc'];
    acqdate = map['acqdate'];
    photo = map['photo'];
    qty = map['qty'];
    scanqty = map['scanqty'];
    createdAt = map['createdat'];
  }
}

class SCANFA {
  String barcodeId = "";
  String seq = "";
  int createdAt;

  SCANFA({this.barcodeId, this.seq, this.createdAt});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"barcodeid": barcodeId, "seq": seq};
  }
}
