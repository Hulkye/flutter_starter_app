import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_app/core/util/image_util.dart';
import 'package:flutter_svg/svg.dart';

/// 图片显示组件
class ImageView extends StatelessWidget {
  /// 网络图片地址
  final String? imageUrl;

  /// 本地资源图片路径
  final String? assetPath;

  /// 本地文件图片路径
  final String? filePath;

  /// 统一图片路径(支持网络、本地资源、本地文件路径)
  final String? value;

  /// 图片的宽高
  final double? width, height;

  /// 图片的拉伸缩放策略
  final BoxFit? fit;

  final double? scale;

  /// 四周圆角
  final double? radius;

  /// 默认加载图
  /// 当图片为网络图片才会生效
  final PlaceholderWidgetBuilder? placeholderWidgetBuilder;

  /// 错误加载图
  /// 当图片为网络图片才会生效
  final LoadingErrorWidgetBuilder? errorWidgetBuilder;

  final Widget? emptyWidget;
  final AlignmentGeometry alignment;
  final Color? color;

  ///bytes图片
  final Uint8List? bytes;
  const ImageView({
    this.imageUrl,
    this.assetPath,
    this.filePath,
    this.value,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.scale,
    this.radius,
    this.placeholderWidgetBuilder,
    this.errorWidgetBuilder,
    this.emptyWidget,
    this.alignment = Alignment.center,
    this.color,
    this.bytes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = radius != null && radius! > 0
        ? BorderRadius.circular(radius!)
        : BorderRadius.zero;
    Widget child;

    if (imageUrl?.isNotEmpty == true) {
      child = buildNetworkImage(imageUrl);
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      child = buildAssetImage(assetPath);
    } else if (filePath != null && filePath!.isNotEmpty) {
      child = buildFileImage(filePath);
    } else if (bytes != null) {
      child = buildMemoryImage(bytes: bytes);
    } else {
      String? imgValue = value;
      if (imgValue?.isNotEmpty == true) {
        if (imgValue!.startsWith('http')) {
          child = buildNetworkImage(imgValue);
        } else if (imgValue.startsWith('asset') ||
            imgValue.startsWith('package')) {
          child = buildAssetImage(imgValue);
        } else if (imgValue.startsWith('data:image')) {
          child = buildMemoryImage(base64Str: imgValue);
        } else {
          child = buildFileImage(imgValue);
        }
      } else {
        child = emptyPlaceholder;
      }
    }
    child = ClipRRect(borderRadius: borderRadius, child: child);
    return child;
  }

  /// 网络图片
  Widget buildNetworkImage(String? url) {
    if (url == null || url.isEmpty) {
      return emptyPlaceholder;
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholderWidgetBuilder,
      errorWidget: (BuildContext context, String url, Object error) {
        // 返回错误 Widget
        if (errorWidgetBuilder != null) {
          return errorWidgetBuilder!.call(context, url, error);
        }
        return emptyPlaceholder;
      },
      scale: scale ?? 1.0,
      alignment: alignment.resolve(null),
      color: color,
    );
  }

  ///加载Uint8List图片
  Widget buildMemoryImage({Uint8List? bytes, String? base64Str}) {
    if (base64Str?.isNotEmpty == true) {
      bytes = ImageUtil.parseBase64Img(base64Str!);
    }
    if (bytes == null) {
      return emptyPlaceholder;
    }
    try {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        scale: scale ?? 1.0,
        alignment: alignment,
        color: color,
      );
    } catch (e) {
      return emptyPlaceholder;
    }
  }

  /// 本地文件图片
  Widget buildFileImage(String? path) {
    if (path == null || path.isEmpty) {
      return emptyPlaceholder;
    }
    try {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        scale: scale ?? 1.0,
        alignment: alignment,
        color: color,
      );
    } catch (e) {
      return emptyPlaceholder;
    }
  }

  /// 本地资源图片/SVG
  /// 目前只有app资源文件才会区分图片或者SVG，其他路径（网络、本地文件）都默认当做图片处理
  Widget buildAssetImage(String? path) {
    if (path == null || path.isEmpty) {
      return emptyPlaceholder;
    }
    try {
      if (path.endsWith('.svg')) {
        // 使用flutter_svg加载SVG图片
        return SvgPicture.asset(
          path,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          alignment: alignment,
          color: color,
        );
      }
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        scale: scale,
        alignment: alignment,
        color: color,
      );
    } catch (e) {
      return emptyPlaceholder;
    }
  }

  Widget get emptyPlaceholder {
    return emptyWidget ??
        Container(width: width, height: height, color: Colors.transparent);
  }
}
