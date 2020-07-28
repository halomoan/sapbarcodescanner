import 'package:sapfascanner/model/model.dart';
import 'PreferenceUtils.dart';

class BarcodeUtils {
  int _validLength;
  SAPFA _barcode;
  SCANFA _scancode;
  String _counter;
  bool _isValid;

  BarcodeUtils() {
    _validLength = PreferenceUtils.coCodeLen +
        PreferenceUtils.mainCodeLen +
        PreferenceUtils.subCodeLen +
        PreferenceUtils.counterLen;
  }

  set code(String code) {
    if (code.length == _validLength) {
      _barcode = new SAPFA(
          barcodeId: code.substring(0, 14),
          coCode: code.substring(0, 4),
          mainCode: code.substring(4, 10),
          subCode: code.substring(10, 14),
          desc: "",
          acqdate: "",
          loc: "",
          qty: 0,
          photo: null);

      _scancode = SCANFA(barcodeId: _barcode.barcodeId, seq: _counter);
      _counter = code.substring(14, 18);
      _isValid = true;
    } else {
      _barcode = null;
      _scancode = null;
      _counter = "";
      _isValid = false;
    }
  }

  SAPFA get sapFA {
    return _barcode;
  }

  SCANFA get scanFA {
    return _scancode;
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
}
