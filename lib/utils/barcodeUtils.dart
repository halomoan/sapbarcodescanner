import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'PreferenceUtils.dart';

class BarcodeUtils {
  final DBHelper _dbHelper = DBHelper();

  String _plainCode;
  String _barcodeId;
  String _counter;

  bool _isValid;
  bool _isNew;
  int _validLength;

  SAPFA _barcode;
  SCANFA _scancode;

  BarcodeUtils() {
    PreferenceUtils.init();
    _validLength = PreferenceUtils.coCodeLen +
        PreferenceUtils.mainCodeLen +
        PreferenceUtils.subCodeLen +
        PreferenceUtils.counterLen;
  }

  Future<SAPFA> _findInDB() async {
    SAPFA sapfa = await _dbHelper.getSAPFA(_barcodeId);
    if (sapfa != null) {
      _isNew = false;
    } else {
      _isNew = true;
      sapfa = new SAPFA(
        barcodeId: _barcodeId,
        coCode: _plainCode.substring(0, PreferenceUtils.coCodeLen),
        mainCode: _plainCode.substring(PreferenceUtils.coCodeLen,
            PreferenceUtils.coCodeLen + PreferenceUtils.mainCodeLen),
        subCode: _plainCode.substring(
            PreferenceUtils.coCodeLen + PreferenceUtils.mainCodeLen,
            PreferenceUtils.coCodeLen +
                PreferenceUtils.mainCodeLen +
                PreferenceUtils.subCodeLen),
        desc: "",
        loc: "",
        acqdate: "",
        photo: false,
        info: false,
        qty: 0,
      );
    }

    return sapfa;
  }

  setCode(String code) async {
    _plainCode = code;
    if (_plainCode.length == _validLength) {
      _barcodeId = code.substring(
          0,
          PreferenceUtils.coCodeLen +
              PreferenceUtils.mainCodeLen +
              PreferenceUtils.subCodeLen);

      _barcode = await _findInDB();
      _counter = _plainCode.substring(
          PreferenceUtils.coCodeLen +
              PreferenceUtils.mainCodeLen +
              PreferenceUtils.subCodeLen,
          PreferenceUtils.coCodeLen +
              PreferenceUtils.mainCodeLen +
              PreferenceUtils.subCodeLen +
              PreferenceUtils.counterLen);
      _scancode = SCANFA(barcodeId: _barcode.barcodeId, seq: _counter);
      this._isValid = true;
    } else {
      _barcode = null;
      _scancode = null;
      _counter = "";
      this._isValid = false;
    }
  }

  SAPFA get sapFA {
    return _barcode;
  }

  SCANFA get scanFA {
    return _scancode;
  }

  String get scanCode {
    return _plainCode;
  }

  String get barcodeId {
    return _barcode.barcodeId;
  }

  String get counter {
    return _counter;
  }

  int get validLength {
    return _validLength;
  }

  bool get isValid {
    return _isValid;
  }

  bool get isNew {
    return _isNew;
  }

  bool get doRefresh {
    if (this._isNew || _barcode.desc.length == 0) {
      return true;
    } else {
      return false;
    }
  }
}
