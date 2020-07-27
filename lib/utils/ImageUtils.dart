import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageUtils {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> getImageFromNetwork(String url) async {
    File file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  //https://stackoverflow.com/questions/49455079/flutter-save-a-network-image-to-local-directory
}
