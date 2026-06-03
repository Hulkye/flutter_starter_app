import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_starter_app/shared/widgets/toast/controller/loading_controller.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';
import 'package:flutter_starter_app/header.dart';

class BaseLoading extends StatelessWidget {
  /// 打开轻提示
  static ToastCancel show({bool allowClick = false, bool crossPage = true}) {
    if (!LoadingController.hadSet) {
      LoadingController.setLoadingWidget(BaseLoading());
    }
    return LoadingController.showLoading(
      allowClick: allowClick,
      crossPage: crossPage,
    );
  }

  static void close() {
    LoadingController.close();
  }

  final double? size;
  const BaseLoading({this.size, super.key});

  @override
  Widget build(BuildContext context) {
    Widget child = LoadingAnimationWidget.discreteCircle(
      color: context.appColor.brand,
      secondRingColor: context.appColor.warning,
      thirdRingColor: context.appColor.alert,
      size: size ?? 32.w,
    );
    child = Center(child: child);
    return child;
  }
}
