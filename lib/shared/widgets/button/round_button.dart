import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  /// 按钮文字
  final String label;

  /// 按钮高度
  final double? height;

  /// 按钮宽度
  final double? width;

  /// 文字大小
  final double fontSize;

  /// 字重
  final FontWeight? fontWeight;

  final TextOverflow? overflow;
  final int? maxLines;

  /// 文字行高
  final double lineHeight;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 前缀组件
  final Widget? prefixWidget;

  /// 后缀组件
  final Widget? suffixWidget;

  /// 文本颜色
  final Color textColor;

  /// 文本颜色（禁止点击）
  final Color textColorDisabled;

  /// 按钮背景色
  final Color bgColor;

  /// 按钮背景色（禁止点击）
  final Color bgColorDisabled;

  /// 按钮高亮色
  final Color bgColorHighlight;

  /// 按钮边框色
  final Color? borderColor;

  /// 按钮边框色
  final Color? borderColorDisabled;

  /// 边框
  final double? borderRadius;

  final TextStyle Function(TextStyle style)? textStyleBuilder;

  ///是否横向占满
  final bool expand;

  ///是自适应，还是上下有间隔
  final MaterialTapTargetSize? tapTargetSize;

  ///间隔
  final EdgeInsetsGeometry? padding;
  const RoundButton({
    required this.label,
    this.padding,
    this.height = 40,
    this.width,
    this.fontSize = 16,
    this.fontWeight,
    this.overflow,
    this.maxLines,
    this.lineHeight = 1.4,
    this.onPressed,
    this.onLongPress,
    this.prefixWidget,
    this.suffixWidget,
    required this.textColor,
    required this.textColorDisabled,
    required this.bgColor,
    required this.bgColorDisabled,
    required this.bgColorHighlight,
    this.borderColor,
    this.borderColorDisabled,
    this.borderRadius,
    this.textStyleBuilder,
    this.expand = true,
    this.tapTargetSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color foregroundColor = onPressed == null ? textColorDisabled : textColor;
    Color backgroundColor = onPressed == null ? bgColorDisabled : bgColor;
    Color overlayColor = bgColorHighlight;
    Color? borderSideColor = onPressed == null
        ? borderColorDisabled
        : borderColor;

    TextStyle textStyle = TextStyle(
      color: foregroundColor,
      fontSize: fontSize,
      height: lineHeight,
      fontWeight: fontWeight,
      overflow: overflow,
    );
    if (textStyleBuilder != null) {
      textStyle = textStyleBuilder!(textStyle);
    }

    Widget child;
    child = Text(
      label,
      style: textStyle,
      maxLines: maxLines,
      textAlign: TextAlign.center,
    );
    if (width != null && overflow != null) {
      child = Expanded(child: child);
    }
    child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [?prefixWidget, child, ?suffixWidget],
    );
    child = Container(
      padding: padding,
      alignment: Alignment.center,
      width: width,
      height: padding != null ? null : height,
      child: child,
    );
    child = ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ButtonStyle(
        tapTargetSize: tapTargetSize,
        minimumSize: WidgetStateProperty.all<Size>(const Size(0, 0)),
        splashFactory: NoSplash.splashFactory,
        elevation: WidgetStateProperty.all<double>(0.0),
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        overlayColor: WidgetStateProperty.all<Color>(overlayColor),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? (height ?? 0 / 2),
            ),
            side: borderSideColor != null
                ? BorderSide(color: borderSideColor)
                : BorderSide.none,
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
        visualDensity: VisualDensity.compact,
        animationDuration: const Duration(milliseconds: 100),
      ),
      child: child,
    );
    if (padding != null && expand) {
      child = Row(
        children: [
          Expanded(child: Container()),
          child,
          Expanded(child: Container()),
        ],
      );
    }
    return child;
  }
}
