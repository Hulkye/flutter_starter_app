import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart';

typedef PermissionGrantedCallback = void Function();
typedef PermissionDeniedCallback = void Function();
typedef PermissionLimitedCallback = void Function();
typedef PermissionHintCallback = Future<bool> Function({bool isLimited});

/// 通用权限申请工具。
class PermissionUtil {
  PermissionUtil._();

  static Future<PermissionStatus> status(Permission permission) {
    return permission.status;
  }

  static Future<bool> isGranted(Permission permission) async {
    final current = await permission.status;
    return _isUsable(current);
  }

  static Future<bool> request(Permission permission) async {
    final result = await permission.request();
    return _isUsable(result);
  }

  static Future<void> checkPermission(
    Permission permission,
    PermissionGrantedCallback grantedCallback, {
    PermissionDeniedCallback? deniedCallback,
    PermissionLimitedCallback? limitedCallback,
  }) async {
    final current = await permission.status;
    if (_isUsable(current)) {
      grantedCallback.call();
    } else if (current.isDenied) {
      deniedCallback?.call();
    } else if (current.isPermanentlyDenied || current.isRestricted) {
      limitedCallback?.call();
    }
  }

  static Future<bool> checkAndRequest(
    Permission permission, {
    PermissionHintCallback? beforeRequest,
    bool openSettingsWhenLimited = true,
  }) async {
    final current = await permission.status;
    if (_isUsable(current)) {
      return true;
    }

    if (current.isDenied) {
      final shouldRequest = await beforeRequest?.call(isLimited: false) ?? true;
      if (!shouldRequest) {
        return false;
      }
      return request(permission);
    }

    if (current.isPermanentlyDenied || current.isRestricted) {
      final shouldOpenSettings =
          await beforeRequest?.call(isLimited: true) ?? openSettingsWhenLimited;
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  static Future<bool> confirmBeforeRequest(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Continue',
    String cancelLabel = 'Cancel',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  static Future<bool> openAppSettingPage() {
    return openAppSettings();
  }

  static bool _isUsable(PermissionStatus status) {
    return status.isGranted || status.isLimited || status.isProvisional;
  }
}
