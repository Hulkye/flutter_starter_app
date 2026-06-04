import 'package:flutter/material.dart';
import 'base_text_field.dart';
import '../../../core/theme/theme_context_ext.dart';
import '../../../core/util/screen_util.dart';
import 'input_widget.dart';

class SearchInputWidget extends InputWidget {
  final Color? bgColor;
  final double? height;

  const SearchInputWidget({
    super.key,
    super.controller,
    super.focusNode,
    super.defaultText,
    super.hintText,
    this.bgColor,
    this.height,
    super.onChanged,
    super.onSubmitted,
    super.decoratedInput,
  }) : super(removeSpace: false);

  @override
  InputWidgetState<SearchInputWidget> createState() =>
      _SearchInputWidgetState();
}

class _SearchInputWidgetState extends InputWidgetState<SearchInputWidget> {
  @override
  bool get showWarnText => false;

  @override
  TextInputAction? get textInputAction => TextInputAction.search;

  @override
  TextStyle textStyle(BuildContext context) {
    return TextStyle(
      color: context.appColor.fontPrimary,
      fontSize: 17.sp,
      height: 22 / 17,
    );
  }

  @override
  InputDecoration decoration(BuildContext context) {
    return createInputDecoration(
      context,
      hintText: widget.hintText,
      fontSize: 17.sp,
      color: context.appColor.fontTertiary,
    );
  }

  @override
  EdgeInsets textFieldPadding(BuildContext context) {
    return EdgeInsets.only(top: 7.w, bottom: 7.w);
  }

  @override
  Widget? prefixWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 3.w),
      child: Icon(Icons.search, size: 22.w, color: context.appColor.fontFourth),
    );
  }

  @override
  Widget clearButton(BuildContext context, bool visible) {
    Widget child = Icon(
      Icons.cancel,
      size: 12.w,
      color: context.appColor.fontFourth,
    );
    child = Container(
      padding: EdgeInsets.only(left: 12.w, top: 12.w, bottom: 12.w, right: 8.w),
      color: Colors.transparent,
      child: child,
    );
    child = GestureDetector(
      onTap: () {
        controller.text = '';
        onChanged(controller.text);
      },
      child: child,
    );
    return Visibility(
      visible: visible,
      maintainState: true,
      maintainSize: true,
      maintainAnimation: true,
      child: child,
    );
  }

  @override
  Widget decoratedInput(BuildContext context) {
    if (widget.decoratedInput != null) {
      return widget.decoratedInput!(context, inputRow(context));
    }
    return Container(
      padding: EdgeInsets.only(left: 8.w),
      height: widget.height ?? 46.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.w)),
        color: widget.bgColor ?? context.appColor.backgroundSecondary,
      ),
      child: inputRow(context),
    );
  }
}
