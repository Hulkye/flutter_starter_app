import 'package:flutter/material.dart';

import '../../../core/theme/theme_context_ext.dart';
import '../../../core/util/screen_util.dart';
import 'input_widget.dart';

class PwdInputWidget extends InputWidget {
  const PwdInputWidget({
    super.controller,
    super.focusNode,
    super.defaultText,
    super.hintText,
    super.warnText,
    super.onChanged,
    super.textChange,
    super.maxLen,
    super.enabled,
    super.icon,
    super.key,
  });

  @override
  InputWidgetState<PwdInputWidget> createState() => _PwdInputWidgetState();
}

class _PwdInputWidgetState extends InputWidgetState<PwdInputWidget> {
  @override
  bool get obscureText => !suffixVisible.value;

  @override
  void syncSuffixVisible(String? text) {}

  @override
  Widget? suffixWidget(BuildContext context, bool visible) {
    Widget child = Icon(
      visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 18.w,
      color: context.appColor.iconTertiary,
    );
    child = Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 16.w, right: 2.w, top: 10.w, bottom: 10.w),
      child: child,
    );
    return GestureDetector(
      onTap: () => suffixVisible.value = !visible,
      child: child,
    );
  }

  @override
  Widget buildInput(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: suffixVisible,
      builder: (_, _, _) => tappableInput(context),
    );
  }
}
