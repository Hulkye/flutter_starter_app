import 'package:flutter_starter_app/shared/widgets/toast/dialog/dialog_unit.dart';
import 'package:flutter_starter_app/shared/widgets/toast/dialog_controller.dart';
import 'package:flutter_starter_app/header.dart';

/// 通用弹窗
class CommonDialog extends StatelessWidget {
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
    Widget? descWidget,
  }) {
    Widget dialogWidget =
        child ??
        CommonDialog(
          title: title,
          desc: desc,
          confirmText: confirmText,
          cancelText: cancelText,
          descWidget: descWidget,
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

  final String? title;
  final String? desc;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;

  final Widget? descWidget;

  const CommonDialog({
    this.title,
    this.desc,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.descWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(SizedBox(height: 19.w));
    if (title != null && title!.isNotEmpty) {
      children.add(DialogTitle(title: title!));
    }
    if (children.length > 1) {
      children.add(SizedBox(height: 2.w));
    }
    if (desc != null && desc!.isNotEmpty) {
      children.add(DialogDesc(desc: desc!));
    } else if (descWidget != null) {
      children.add(descWidget!);
    }
    children.add(SizedBox(height: 17.w));
    children.add(buildContent());
    return DialogCard(
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget buildContent() {
    return DialogMainBar(
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
