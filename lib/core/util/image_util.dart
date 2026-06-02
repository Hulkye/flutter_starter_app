import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

final _imageSizeCache = <String, Size>{};

class ImageUtil {
  /// 获取图片大小（缓存）
  static Future<Size> getImageSizeCached(String path) async {
    if (_imageSizeCache.containsKey(path)) {
      return _imageSizeCache[path]!;
    }
    final size = await getImageSize(path);
    _imageSizeCache[path] = size;
    return size;
  }

  ///解析base64图片
  static Uint8List parseBase64Img(String data) {
    data = data.split(',')[1];
    Uint8List bytes = base64.decode(data.replaceAll(RegExp(r'\s+'), ''));
    return bytes;
  }

  ///获取base64图片尺寸
  static Future<Size> getMemImageSize(Uint8List data) async {
    final completer = Completer<Size>();
    final Image image = Image.memory(data);
    image.image
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener((ImageInfo info, _) {
            completer.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
          }, onError: (e, stack) => completer.completeError(e, stack)),
        );
    return completer.future.timeout(const Duration(seconds: 10));
  }

  /// 获取图片大小
  static Future<Size> getImageSize(
    String imagePath, {
    Size? defaultSize,
  }) async {
    // 创建对应的 ImageProvider
    final ImageProvider imageProvider = getImageProvider(imagePath);

    final completer = Completer<Size>();
    final ImageStream stream = imageProvider.resolve(
      const ImageConfiguration(),
    );

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()),
        );
        stream.removeListener(listener);
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        if (defaultSize != null) {
          completer.complete(defaultSize);
        } else {
          completer.completeError(error, stackTrace);
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    return completer.future.timeout(const Duration(seconds: 10));
  }

  /// 获取ImageProvider
  static ImageProvider getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  ///保存Uint8List图片
  static Future<String?> saveImageWithData(Uint8List rawData) async {
    try {
      // 1. 获取存储目录（以应用文档目录为例）
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. 创建文件并写入字节数据
      final File file = File(filePath);
      await file.writeAsBytes(rawData);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
