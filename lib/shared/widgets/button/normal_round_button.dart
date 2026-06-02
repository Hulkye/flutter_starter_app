import 'package:flutter_starter_app/core/theme/theme_context_ext.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';

import 'round_button.dart';

/// 普通按钮
class NormalRoundButton extends RoundButton {
  NormalRoundButton({
    required BuildContext context,
    required super.label,
    double? height,
    super.width,
    double? fontSize,
    super.fontWeight,
    double? lineHeight,
    super.borderRadius,
    super.onPressed,
    super.onLongPress,
    super.prefixWidget,
    super.suffixWidget,
    super.key,
    super.padding,
    super.expand,
    super.overflow,
    super.maxLines,
    Color? textColor,
    Color? bgColor,
    TextStyle Function(TextStyle style)? textStyleBuilder,
  }) : super(
         height: height ?? 53.w,
         fontSize: fontSize ?? 17.sp,
         lineHeight: lineHeight ?? 1.4,
         textColor: textColor ?? context.appColor.fontSecondary,
         textColorDisabled: context.appColor.fontTertiary,
         bgColor: bgColor ?? context.appColor.compBackgroundSecondary,
         bgColorDisabled: context.appColor.compBackgroundTertiary,
         bgColorHighlight: context.appColor.interactivePressed,
       );
}
