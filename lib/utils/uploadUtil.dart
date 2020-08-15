import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sapfascanner/model/dbHelper.dart';
import 'package:sapfascanner/model/model.dart';
import 'package:sapfascanner/utils/apiUtil.dart';

class UploadUtils {
  final DBHelper _dbHelper = DBHelper();
  final String _fileExt = '.png';
  final ApiProvider api = new ApiProvider();

  Future<Map<String, dynamic>> getUploadInfo() async {
    Map<String, dynamic> result = {'codeTotal': 0, 'pictTotal': 0};

    result['codeTotal'] = await _dbHelper.noOfRecord();
    result['pictTotal'] = await _getTotalImage();

    return result;
  }

  Future<int> _getTotalImage() async {
    int total = 0;

    String _dirPath = (await getApplicationDocumentsDirectory()).path;
    Directory dir = new Directory(_dirPath);
    List files = dir.listSync();

    for (var file in files) {
      if (file is File && p.extension(file.path) == _fileExt) {
        total++;
      }
    }

    return total;
  }

  Future<Map<String, dynamic>> doUpload(StreamController _progress) async {
    Map<String, dynamic> result;

    List images = await _getImageFiles();
    List<SCANFA> scanfa = await _dbHelper.allScannedFA();
    result = await api.uploadData(_progress, scanfa, images);

    return result;
  }

  Future<List> _getImageFiles() async {
    List result = new List();
    String _dirPath = (await getApplicationDocumentsDirectory()).path;
    Directory dir = new Directory(_dirPath);
    List files = dir.listSync();

    for (var file in files) {
      if (file is File && p.extension(file.path) == _fileExt) {
        result.add(file);
      }
    }

    return result;
  }
}
