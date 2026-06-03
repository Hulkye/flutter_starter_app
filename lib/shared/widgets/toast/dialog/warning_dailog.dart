import 'package:flutter_starter_app/shared/widgets/toast/dialog/common_dialog.dart';
import 'package:flutter_starter_app/shared/widgets/toast/dialog/dialog_unit.dart';
import 'package:flutter_starter_app/shared/widgets/toast/controller/dialog_controller.dart';
import 'package:flutter_starter_app/header.dart';

class WarningDialog extends CommonDialog {
  const WarningDialog({
    super.key,
    super.title,
    super.desc,
    super.onConfirm,
    super.onCancel,
    super.confirmText,
    super.cancelText,
  });

  /// 打开弹窗
  static void show(
    BuildContext context, {
    String? title,
    String? desc,
    Function? onConfirm,
    Function? onCancel,
    bool clickClose = true,
    String? confirmText,
    String? cancelText,
    Widget? child,
  }) {
    Widget dialogWidget =
        child ??
        WarningDialog(
          title: title,
          desc: desc,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm == null
              ? null
              : () {
                  DialogController.closeDialog();
                  onConfirm.call();
                },
          onCancel: onCancel == null
              ? null
              : () {
                  DialogController.closeDialog();
                  onCancel.call();
                },
        );

    DialogController.showDialog(
      dialogWidget: dialogWidget,
      clickClose: clickClose,
      backgroundColor: context.appColor.overlayBackground,
    );
  }

  @override
  Widget buildContent() {
    return DialogWarningBar(
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
