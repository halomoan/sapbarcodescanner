import 'dart:async';

import 'package:dio/dio.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/utils/PreferenceUtils.dart';
import 'package:sapfascanner/model/apimodel.dart';
import 'package:path/path.dart' as p;

class ApiProvider {
  Dio _dio;

  ApiProvider() {
    BaseOptions options = new BaseOptions(
      baseUrl: PreferenceUtils.serverUrl,
      contentType: Headers.jsonContentType,
      connectTimeout: 5000,
      receiveTimeout: 3000,
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

  Future<FAInfo> getFAInfo(String barcodeId) async {
    FAInfo result;

    if (PreferenceUtils.serverUrl == null) {
      return null;
    }

    try {
      Response response = await _dio.get("/api/facode/" + barcodeId);

      if (response.data['desc'] != null) {
        result = new FAInfo(
            hasErr: false,
            desc: response.data['desc'],
            loc: response.data['loc'],
            qty: int.parse(response.data['qty']),
            acqdate: response.data['acqdate'],
            info: true);
      } else if (response.data['msg'] != null) {
        result = new FAInfo(hasErr: true, err: response.data['msg']);
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
    }
    return result;
  }

  Future<Map<String, dynamic>> uploadData(
      StreamController _progress, List<SCANFA> scanfa, List images) async {
    Map<String, dynamic> result = {'noOfFile': 0, 'status': true, 'msg': ''};

    if (PreferenceUtils.serverUrl == null) {
      result['status'] = false;
      result['msg'] = 'Please register this phone';
      return result;
    }

    result['noOfFile'] = images.length;

    List files = new List();

    for (var image in images) {
      files.add(await MultipartFile.fromFile(image.path,
          filename: p.basename(image.path)));
    }

    List codes = new List();
    for (var code in scanfa) {
      codes.add(code.barcodeId);
    }

    FormData formData = FormData.fromMap({"codes": codes, "files": files});

    try {
      Response response = await _dio.post(
        "/api/faimage",
        data: formData,
        onSendProgress: (received, total) {
          if (total != -1) {
            //print((received / total * 100).toStringAsFixed(0) + "%x");
            _progress.add((received / total * 100).toStringAsFixed(0) + "%");
          }
        },
      );

      result['status'] =
          (response.data['status'] != null) ? response.data['status'] : false;
      if (result['status']) {
        result['msg'] = 'Success';
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
