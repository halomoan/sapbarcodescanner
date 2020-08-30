import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/utils/PreferenceUtils.dart';
import 'package:sapfascanner/model/apimodel.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ApiProvider {
  Dio _dio;
  final DBHelper _dbHelper = DBHelper();

  ApiProvider() {
    BaseOptions options = new BaseOptions(
      baseUrl: PreferenceUtils.serverUrl,
      contentType: Headers.jsonContentType,
      connectTimeout: 15000,
      receiveTimeout: 15000,
    );
    _dio = new Dio(options);
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      //print('send request：path:${options.path}，baseURL:${options.baseUrl}');

      if (PreferenceUtils.accessToken != null &&
          options.path != '/api/falogin') {
        options.headers["Authorization"] =
            'Bearer ' + PreferenceUtils.accessToken;
      }
      return options; //continue
    }, onResponse: (Response response) async {
      return response; // continue
    }, onError: (DioError e) async {
      return e; //continue
    }));
  }

  Future<Map<String, dynamic>> isConnected() async {
    Map<String, dynamic> result = {'status': false, 'msg': ''};

    if (PreferenceUtils.serverUrl == null ||
        PreferenceUtils.accessToken == null) {
      result['status'] = false;
      result['msg'] = 'Please Initialize This Phone';
      return result;
    }

    try {
      Response response = await _dio.get("/api/facode/test");

      if (response.data['status'] != null && response.data['status']) {
        result['status'] = true;
        result['msg'] = response.data['msg'];
      }
    } on DioError catch (e) {
      if (e.message != null) {
        result['status'] = false;
        result['msg'] = e.message;
      }
    } catch (e) {
      result['status'] = false;
      result['msg'] =
          'Failed to connect to the server. Please check the Settings.';
    }
    return result;
  }

  Future<bool> checkRegistration() async {
    if (PreferenceUtils.serverUrl == null) {
      return false;
    }

    try {
      // _dio.options.contentType = Headers.jsonContentType;
      // _dio.options.baseUrl = PreferenceUtils.serverUrl;

      Response response =
          await _dio.get("/api/faphone/" + PreferenceUtils.uniqueID);

      if (response.data['status'] != null) {
        return response.data['status'];
      }
    } on DioError catch (e) {
      if (e.message != null) {
        print(e.message);
      }
    }
    return false;
  }

  Future<FAInfo> getFAInfo(List barcodes) async {
    FAInfo result;

    if (PreferenceUtils.serverUrl == null) {
      result = new FAInfo(hasErr: true, err: 'Please register this phone');
      return result;
    }

    String qString = "";
    for (final barcode in barcodes) {
      qString = qString + ';' + barcode;
    }

    try {
      Response response = await _dio.get("/api/facode/" + qString);

      if (response.data.length > 0) {
        for (final data in response.data) {
          result = new FAInfo(
              hasErr: false,
              desc: data['desc'],
              loc: data['loc'],
              qty: int.tryParse(data['qty']) ?? 0,
              acqdate: data['acqdate'],
              info: true);

          await _dbHelper.updateInfo(data['id'], result);
        }
      } else if (response.data.contains('msg')) {
        result = new FAInfo(hasErr: true, err: response.data['msg']);
      } else {
        result = new FAInfo(hasErr: true, err: '');
      }
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        // print(e.response.statusCode);
        // print(e.response.data);
        // print(e.response.headers);
        // print(e.response.request);
        result = new FAInfo(hasErr: true, err: e.response.data);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        // print(e.request);
        // print(e.message);

        result = new FAInfo(hasErr: true, err: e.message);
      }
    } catch (e) {
      result = new FAInfo(hasErr: true, err: e.toString());
    }

    return result;
  }

  Future<Map<String, dynamic>> uploadData(
      StreamController _progress, List<SCANFA> scanfa, List images) async {
    Map<String, dynamic> result = {
      'noOfFile': 0,
      'noOfCode': 0,
      'status': true,
      'msg': ''
    };

    if (PreferenceUtils.serverUrl == null) {
      result['status'] = false;
      result['msg'] = 'Please register this phone';
      return result;
    }

    result = await isConnected();
    if (!result['status']) {
      return result;
    }

    List files = new List();

    for (var image in images) {
      files.add(await MultipartFile.fromFile(image.path,
          filename: p.basename(image.path)));
    }

    result['noOfFile'] = files.length;

    List codes = new List();
    for (var code in scanfa) {
      codes.add(code.barcodeId + code.seq);
    }

    String phoneid = PreferenceUtils.uniqueID;
    String version = PreferenceUtils.version;
    String cocode = PreferenceUtils.coCode;

    var key = utf8.encode(r'$7653uolSuperKey=88$');

    var bytes = utf8.encode(phoneid);
    var hmacSha1 = new Hmac(sha1, key);

    var serverkey = base64Encode(hmacSha1.convert(bytes).bytes);

    result['noOfCode'] = codes.length;

    FormData formData = FormData.fromMap({
      "serverkey": serverkey,
      "version": version,
      "cocode": cocode,
      "phoneid": phoneid,
      "codes": codes,
      "files": files
    });

    try {
      Response response = await _dio.post(
        "/api/facode",
        data: formData,
        onSendProgress: (received, total) {
          if (total != -1) {
            //print((received / total * 100).toStringAsFixed(0) + "%");
            _progress.add((received / total * 100).toStringAsFixed(0) + "%");
          }
        },
      );

      result['status'] =
          (response.data['status'] != null) ? response.data['status'] : false;
      if (result['status']) {
        result['msg'] = 'Successfully Uploaded';
      } else {
        result['msg'] =
            (response.data['msg'] != null) ? response.data['msg'] : '';
      }
    } on DioError catch (e) {
      if (e.response != null) {
        //print(e.response.data);
        result['status'] = false;
        result['msg'] = e.response.data;
      } else {
        //print(e.message);
        result['status'] = false;
        result['msg'] = e.message;
      }
    } catch (e) {
      print(e.response);
    }

    return result;
  }

  // Future<Map<String, dynamic>> uploadImage(List images) async {
  //   Map<String, dynamic> result = {'noOfFile': 0, 'status': true, 'msg': ''};

  //   if (PreferenceUtils.serverUrl == null) {
  //     result['status'] = false;
  //     result['msg'] = 'Please register this phone';
  //     return result;
  //   }

  //   result['noOfFile'] = images.length;

  //   List files = new List();

  //   for (var image in images) {
  //     files.add(await MultipartFile.fromFile(image.path,
  //         filename: p.basename(image.path)));
  //   }

  //   FormData formData = FormData.fromMap({"files": files});

  //   try {
  //     Response response = await _dio.post(
  //       "/api/faimage",
  //       data: formData,
  //       onSendProgress: (received, total) {
  //         if (total != -1) {
  //           print((received / total * 100).toStringAsFixed(0) + "%");
  //         }
  //       },
  //     );

  //     result['status'] =
  //         (response.data['status'] != null) ? response.data['status'] : false;
  //     if (result['status']) {
  //       result['msg'] = 'Success';
  //     } else {
  //       result['msg'] =
  //           (response.data['msg'] != null) ? response.data['msg'] : '';
  //     }

  //     print(response);
  //   } on DioError catch (e) {
  //     if (e.response != null) {
  //       //print(e.response.data);
  //       result['status'] = false;
  //       result['msg'] = e.response.data;
  //     } else {
  //       //print(e.message);
  //       result['status'] = false;
  //       result['msg'] = e.message;
  //     }
  //   }

  //   return result;
  // }

  Future<APIConfig> initApp() async {
    APIConfig result;

    try {
      _dio.options.contentType = Headers.jsonContentType;
      _dio.options.baseUrl = PreferenceUtils.serverUrl;

      FormData formData = FormData.fromMap({
        "phoneid": PreferenceUtils.uniqueID,
      });

      Response response = await _dio.post("/api/falogin", data: formData);
      if (response.data['access_token'] != null) {
        result = new APIConfig(
            hasErr: false,
            cocode: response.data['cocode'],
            token: response.data['access_token'],
            sub1len: response.data['sub1len'],
            sub2len: response.data['sub2len'],
            sub3len: response.data['sub3len'],
            runlen: response.data['runlen']);
      } else if (response.data['msg'] != null) {
        result = new APIConfig(hasErr: true, err: response.data['msg']);
      }
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        // print(e.response.statusCode);
        // print(e.response.data);
        // print(e.response.headers);
        // print(e.response.request);
        result = new APIConfig(hasErr: true, err: e.response.data);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        // print(e.request);
        // print(e.message);

        result = new APIConfig(hasErr: true, err: e.message);
      }
    }
    return result;
  }

  get dio {
    return _dio;
  }
}
