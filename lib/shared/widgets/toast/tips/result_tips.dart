import 'package:flutter_starter_app/shared/widgets/toast/tips/tips_unit.dart';
import 'package:flutter_starter_app/shared/widgets/toast/controller/tips_controller.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

/// 成功提示
ToastCancel showSuccessTips(
  String tips, {
  bool allowClick = false,
  bool crossPage = true,
  Duration? duration,
}) {
  TipsController.setTipsWidget(SuccessTips(tips));
  return TipsController.showTips(
    allowClick: allowClick,
    crossPage: crossPage,
    duration: duration,
  );
}

/// 失败提示
ToastCancel showFailTips(
  String tips, {
  bool allowClick = false,
  bool crossPage = true,
  Duration? duration,
}) {
  TipsController.setTipsWidget(FailTips(tips));
  return TipsController.showTips(
    allowClick: allowClick,
    crossPage: crossPage,
    duration: duration,
  );
}
