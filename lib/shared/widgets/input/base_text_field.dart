import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_context_ext.dart';
import '../../../core/util/screen_util.dart';

TextStyle createInputTextStyle(
  BuildContext context, {
  double? fontSize,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize ?? 15.sp,
    color: color ?? context.appColor.fontPrimary,
  );
}

InputDecoration createInputDecoration(
  BuildContext context, {
  String? hintText,
  double? fontSize,
  Color? color,
}) {
  return InputDecoration(
    fillColor: Colors.transparent,
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    hintText: hintText,
    hintStyle: TextStyle(
      fontSize: fontSize ?? 15.sp,
      color: color ?? context.appColor.fontTertiary,
    ),
    counterText: '',
  );
}

class BaseTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final String? hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;

  const BaseTextField({
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.hintText,
    this.style,
    this.decoration,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      style: style ?? createInputTextStyle(context),
      decoration:
          decoration ?? createInputDecoration(context, hintText: hintText),
      onTapOutside: (event) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        currentFocus.focusedChild?.unfocus();
      },
      cursorWidth: 2.w,
      cursorColor: context.appColor.brand,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
    );
  }
}
