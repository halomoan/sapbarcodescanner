import 'package:dio/dio.dart';
import 'package:sapfascanner/utils/PreferenceUtils.dart';
import 'package:sapfascanner/model/apimodel.dart';

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
        print(PreferenceUtils.accessToken);
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
    print(PreferenceUtils.serverUrl);

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
    } on DioError catch (e) {}
    return false;
  }

  Future<FAInfo> getFAInfo(String code) async {
    FAInfo result;

    if (PreferenceUtils.serverUrl == null) {
      return null;
    }

    try {
      Response response =
          await _dio.get("/api/facode/" + PreferenceUtils.uniqueID);
      if (response.data['desc'] != null) {
        result = new FAInfo(
          hasErr: false,
          desc: response.data['desc'],
          loc: response.data['loc'],
          qty: response.data['qty'],
          acqdate: response.data['acqdate'],
        );
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
}
