// import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:keyboard_utils_fork/keyboard_utils.dart';
// import 'package:keyboard_utils_fork/keyboard_listener.dart' as k_util;

///maxHeight为内容可以显示的最高高度
typedef AutoHeightSheetContentBuilder =
    Widget Function(BuildContext context, double maxHeight);

typedef AutoHeightSheetMaskContentBuilder =
    Widget Function(BuildContext context, double maxHeight, Function cancel);

typedef AutoHeightSheetLoadingContentBuilder =
    Widget Function(
      BuildContext context,
      double maxHeight,
      ValueNotifier<bool> loading,
    );

AutoHeightLoadingSheet createAutoHeightLoadingSheet({
  required AutoHeightSheetLoadingContentBuilder contentBuilder,
  required double screenWidth,
  required double screenHeight,
  required double paddingBottom,
  required Widget loadingWidget,
  Key? key,
  Color? bgColor,
  bool showDrag = false,
  Color? dragColor,
  bool isMaskClickCancel = false,
  VoidCallback? onCancel,
  double? maxContentHeight,
  double? minContentHeight,
  // bool useKeyboardHeight = true,
  double maxTopPadding = 80,
}) {
  return AutoHeightLoadingSheet(
    key: key,
    loadingContentBuilder: contentBuilder,
    screenWidth: screenWidth,
    screenHeight: screenHeight,
    paddingBottom: paddingBottom,
    loadingWidget: loadingWidget,
    contentBuilder: (_, double value) {
      return Container();
    },
    bgColor: bgColor,
    showDrag: showDrag,
    dragColor: dragColor,
    isMaskClickCancel: isMaskClickCancel,
    onCancel: onCancel,
    maxContentHeight: maxContentHeight,
    minContentHeight: minContentHeight,
    // useKeyboardHeight: useKeyboardHeight,
    maxTopPadding: maxTopPadding,
  );
}

class AutoHeightLoadingSheet extends AutoHeightSheet {
  final AutoHeightSheetLoadingContentBuilder loadingContentBuilder;
  final Widget loadingWidget;

  const AutoHeightLoadingSheet({
    super.key,
    required this.loadingContentBuilder,
    required super.screenWidth,
    required super.screenHeight,
    required super.paddingBottom,
    required this.loadingWidget,
    required super.contentBuilder,
    super.bgColor,
    super.showDrag,
    super.dragColor,
    super.isMaskClickCancel = false,
    super.onCancel,
    super.maxContentHeight,
    super.minContentHeight,
    // super.useKeyboardHeight = true,
    super.maxTopPadding = 80,
  });

  @override
  State<StatefulWidget> createState() => AutoHeightLoadingState();
}

class AutoHeightLoadingState
    extends AutoHeightSheetState<AutoHeightLoadingSheet> {
  final ValueNotifier<bool> _showLoading = ValueNotifier(false);

  Widget loadingWidget(BuildContext context) {
    Widget child;
    child = ValueListenableBuilder(
      valueListenable: _showLoading,
      builder: (_, bool value, Widget? child) {
        Widget newChild = widget.loadingWidget;
        newChild = Visibility(visible: value, child: newChild);
        return newChild;
      },
    );
    return child;
  }

  @override
  void dispose() {
    _showLoading.dispose();
    super.dispose();
  }

  @override
  Widget contentWidget(BuildContext context, double maxHeight) {
    return widget.loadingContentBuilder(context, maxHeight, _showLoading);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = super.build(context);
    child = Stack(children: [child, loadingWidget(context)]);
    return child;
  }
}

/// 自动高度的sheet视图
class AutoHeightSheet extends StatefulWidget {
  /// 内容widget
  final AutoHeightSheetContentBuilder contentBuilder;

  /// 顶部遮罩widget
  final AutoHeightSheetMaskContentBuilder? maskContentBuilder;

  /// 屏幕宽度
  final double screenWidth;

  /// 屏幕高度
  final double screenHeight;

  /// 底部高度
  final double paddingBottom;

  /// 背景色
  final Color? bgColor;

  final bool showDrag;

  /// 调拽条背景色
  final Color? dragColor;

  /// 空白遮罩部分是否点击返回
  final bool isMaskClickCancel;

  /// 关闭回调
  final VoidCallback? onCancel;

  /// 最大内容高度
  final double? maxContentHeight;

  /// 最小内容高度
  final double? minContentHeight;

  /// 是否使用键盘高度作为bottomPadding
  // final bool useKeyboardHeight;

  ///弹窗与顶部间隔
  final double maxTopPadding;
  const AutoHeightSheet({
    required this.contentBuilder,
    this.maskContentBuilder,
    required this.screenWidth,
    required this.screenHeight,
    required this.paddingBottom,
    this.bgColor,
    this.showDrag = false,
    this.dragColor,
    this.isMaskClickCancel = false,
    this.onCancel,
    this.maxContentHeight,
    this.minContentHeight,
    // this.useKeyboardHeight = true,
    this.maxTopPadding = 80,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => AutoHeightSheetState();
}

class AutoHeightSheetState<T extends AutoHeightSheet> extends State<T> {
  // final KeyboardUtils _keyboardUtils = KeyboardUtils();
  // late int _idKeyboardListener;
  // late ValueNotifier<double> _keyboardHeight;

  @override
  void initState() {
    // _keyboardHeight = ValueNotifier(widget.paddingBottom);
    // _idKeyboardListener = _keyboardUtils.add(
    //     listener: k_util.KeyboardListener(willHideKeyboard: () {
    //   _keyboardHeight.value = widget.paddingBottom;
    // }, willShowKeyboard: (double keyboardHeight) {
    //   _keyboardHeight.value = keyboardHeight;
    // }));
    super.initState();
  }

  @override
  void dispose() {
    // _keyboardUtils.unsubscribeListener(subscribingId: _idKeyboardListener);
    // if (_keyboardUtils.canCallDispose()) {
    //   _keyboardUtils.dispose();
    // }
    // _keyboardHeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.screenWidth,
      height: widget.screenHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: createMask(context)),
          createBody(context),
        ],
      ),
    );
    return child;
  }

  void onClose() {
    widget.onCancel?.call();
  }

  Widget createMask(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = constraints.maxHeight;
        Widget? child = widget.maskContentBuilder?.call(
          context,
          maxHeight,
          onClose,
        );
        child = Container(color: Colors.transparent, child: child);
        return GestureDetector(
          onTap: () {
            if (widget.isMaskClickCancel) {
              onClose();
            }
          },
          child: child,
        );
      },
    );
  }

  Widget createBody(BuildContext context) {
    return sheetView(context);
  }

  /// 底部bottom占位
  Widget sheetBottom(BuildContext context) {
    Widget child;
    child = Container(color: widget.bgColor, height: widget.paddingBottom);
    // if (widget.useKeyboardHeight) {
    //   child = ValueListenableBuilder(
    //     valueListenable: _keyboardHeight,
    //     builder: (_, double height, Widget? child) {
    //       double h = height;
    //       if (h < widget.paddingBottom) {
    //         h = widget.paddingBottom;
    //       }
    //       return Container(color: widget.bgColor, height: h);
    //     },
    //   );
    // }
    return child;
  }

  Widget sheetHeader(BuildContext context) {
    Widget child = Container();
    if (widget.showDrag) {
      child = Container(
        width: 50,
        height: 3,
        decoration: BoxDecoration(
          color: widget.dragColor ?? Colors.grey[400],
          borderRadius: BorderRadius.circular(1.5),
        ),
      );
      child = Container(height: 27, alignment: Alignment.center, child: child);
    }
    return child;
  }

  BorderRadius get borderRadius {
    return const BorderRadius.vertical(top: Radius.circular(20));
  }

  Widget contentWidget(BuildContext context, double maxHeight) {
    return widget.contentBuilder(context, maxHeight);
  }

  Widget sheetView(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      color: widget.bgColor,
    );
    double maxHeight =
        widget.maxContentHeight ??
        widget.screenHeight -
            MediaQuery.of(context).viewInsets.top -
            27 - //sheetHeader高度
            widget.maxTopPadding - //弹窗与顶部间隔
            widget.paddingBottom;

    /// 最大显示高度
    BoxConstraints constraints = BoxConstraints(
      minHeight: widget.minContentHeight ?? 0.0,
      maxHeight: maxHeight,
    );

    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        sheetHeader(context),
        Container(
          constraints: constraints,
          child: SingleChildScrollView(
            child: contentWidget(context, maxHeight),
          ),
        ),
        sheetBottom(context),
      ],
    );

    child = Container(decoration: decoration, child: child);

    return child;
  }
}
