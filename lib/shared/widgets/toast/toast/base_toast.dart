import 'package:flutter_starter_app/shared/widgets/toast/toast_controller.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';
import 'package:flutter_starter_app/header.dart';

/// 轻提示
class BaseToast extends StatelessWidget {
  /// 打开轻提示
  static ToastCancel show(String msg) {
    ToastController.setToastWidget(BaseToast(msg));
    return ToastController.showToast(clickClose: false, crossPage: true);
  }

  static void close() {
    ToastController.close();
  }

  /// 提示消息
  final String msg;

  const BaseToast(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 14.w,
      height: 1.4,
      color: context.appColor.fontOnPrimary,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      constraints: BoxConstraints(maxWidth: 315.w),
      decoration: BoxDecoration(
        color: context.appColor.overlayComponentBackground,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Text(msg, style: textStyle, textAlign: TextAlign.start),
    );
  }
}
