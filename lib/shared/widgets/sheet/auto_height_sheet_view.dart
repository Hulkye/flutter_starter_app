import '../../../header.dart';

double get maxTopPadding => 88.w;

Future<dynamic> showCommonSheet(
  BuildContext context,
  Widget contentWidget, {
  bool fullHeight = false,
  double? sheetHeight,
  bool enableDrag = true,
  bool isMaskClickCancel = true,
}) {
  return showModalBottomSheet<dynamic>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    enableDrag: enableDrag,
    builder: (_) {
      return AutoHeightSheetView(
        isMaskClickCancel: isMaskClickCancel,
        contentBuilder: (_, double maxHeight) {
          Widget child = contentWidget;
          if (fullHeight) {
            child = Container(
              constraints: BoxConstraints(minHeight: maxHeight),
              child: child,
            );
          } else {
            if (sheetHeight != null) {
              child = SizedBox(height: sheetHeight, child: child);
            }
          }
          return child;
        },
      );
    },
  );
}

/// 自动高度的sheet视图
class AutoHeightSheetView extends StatelessWidget {
  /// 内容widget
  final AutoHeightSheetContentBuilder contentBuilder;

  /// 顶部遮罩widget
  final AutoHeightSheetMaskContentBuilder? maskContentBuilder;

  final bool isMaskClickCancel;

  // final bool useKeyboardHeight;
  const AutoHeightSheetView({
    required this.contentBuilder,
    this.maskContentBuilder,
    // this.useKeyboardHeight = true,
    this.isMaskClickCancel = true,
    super.key,
  });

  void onCancel(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoHeightSheet(
      contentBuilder: contentBuilder,
      maskContentBuilder: maskContentBuilder,
      screenWidth: ScreenUtil.screenWidth,
      screenHeight: ScreenUtil.screenHeight,
      paddingBottom: ScreenUtil.paddingBottom,
      bgColor: context.appColor.backgroundPrimary,
      showDrag: false,
      isMaskClickCancel: isMaskClickCancel,
      onCancel: () => onCancel(context),
      maxTopPadding: maxTopPadding,
      // useKeyboardHeight: useKeyboardHeight,
    );
  }
}
