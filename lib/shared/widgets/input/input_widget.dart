import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme_context_ext.dart';
import '../../../core/util/screen_util.dart';
import 'base_text_field.dart';

enum InputTextType { normal, number, none }

typedef DecoratedInput = Widget Function(BuildContext context, Widget input);

class InputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? defaultText;
  final String? hintText;
  final String? warnText;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<String?>? onSubmitted;
  final ValueNotifier<String?>? textChange;
  final InputTextType type;
  final int? maxLen;
  final bool? enabled;
  final bool removeSpace;
  final bool obscureText;
  final List<TextInputFormatter>? formatterList;
  final Widget? icon;
  final Widget Function(BuildContext context, bool value)? suffixWidgetBuilder;
  final DecoratedInput? decoratedInput;

  const InputWidget({
    this.controller,
    this.focusNode,
    this.defaultText,
    this.hintText,
    this.warnText,
    this.onChanged,
    this.onSubmitted,
    this.textChange,
    this.type = InputTextType.normal,
    this.maxLen,
    this.enabled,
    this.removeSpace = true,
    this.obscureText = false,
    this.formatterList,
    this.icon,
    this.suffixWidgetBuilder,
    this.decoratedInput,
    super.key,
  });

  @override
  State<InputWidget> createState() => InputWidgetState<InputWidget>();
}

class InputWidgetState<T extends InputWidget> extends State<T> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  late final bool ownsController;
  late final bool ownsFocusNode;
  final ValueNotifier<bool> suffixVisible = ValueNotifier(false);
  final ValueNotifier<String?> warnText = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    ownsController = widget.controller == null;
    ownsFocusNode = widget.focusNode == null;
    controller =
        widget.controller ?? TextEditingController(text: widget.defaultText);
    focusNode = widget.focusNode ?? FocusNode();
    warnText.value = widget.warnText;
    syncSuffixVisible(controller.text);
    focusNode.addListener(onFocusChanged);
    widget.textChange?.addListener(listenTextChange);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    warnText.value = widget.warnText;
    if (oldWidget.textChange != widget.textChange) {
      oldWidget.textChange?.removeListener(listenTextChange);
      widget.textChange?.addListener(listenTextChange);
    }
  }

  @override
  void dispose() {
    widget.textChange?.removeListener(listenTextChange);
    focusNode.removeListener(onFocusChanged);
    warnText.dispose();
    suffixVisible.dispose();
    if (ownsFocusNode) {
      focusNode.dispose();
    }
    if (ownsController) {
      controller.dispose();
    }
    super.dispose();
  }

  @protected
  bool get showWarnText => true;

  @protected
  bool get showClearButton => widget.type != InputTextType.none;

  @protected
  bool get obscureText => widget.obscureText;

  @protected
  TextInputAction? get textInputAction => null;

  @protected
  void onFocusChanged() {
    setState(() {});
  }

  @protected
  void listenTextChange() {
    controller.text = widget.textChange?.value ?? '';
    onChanged(controller.text);
  }

  @protected
  void syncSuffixVisible(String? text) {
    suffixVisible.value = text?.isNotEmpty == true;
  }

  @protected
  void onChanged(String? text) {
    var value = text;
    if (widget.removeSpace) {
      value = value?.replaceAll(' ', '');
      if (value != text) {
        controller.text = value ?? '';
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
      }
    }
    syncSuffixVisible(value);
    widget.onChanged?.call(value);
  }

  @protected
  List<TextInputFormatter>? inputFormatters() {
    if (widget.formatterList != null) return widget.formatterList;
    if (widget.type == InputTextType.number) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  @protected
  TextStyle textStyle(BuildContext context) {
    return TextStyle(fontSize: 15.sp, color: context.appColor.fontPrimary);
  }

  @protected
  InputDecoration decoration(BuildContext context) {
    return createInputDecoration(
      context,
      hintText: widget.hintText,
      fontSize: 15.sp,
      color: context.appColor.fontTertiary,
    );
  }

  @protected
  EdgeInsets textFieldPadding(BuildContext context) {
    return EdgeInsets.only(top: 2.w, bottom: 2.w);
  }

  @protected
  Widget textField(BuildContext context) {
    return Padding(
      padding: textFieldPadding(context),
      child: BaseTextField(
        maxLength: widget.maxLen,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.type == InputTextType.number
            ? TextInputType.phone
            : null,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters(),
        obscureText: obscureText,
        style: textStyle(context),
        decoration: decoration(context),
        hintText: widget.hintText,
        enabled: widget.enabled,
      ),
    );
  }

  @protected
  Widget? prefixWidget(BuildContext context) => widget.icon;

  @protected
  Widget clearButton(BuildContext context, bool visible) {
    Widget child = Icon(
      Icons.cancel,
      size: 12.w,
      color: context.appColor.iconTertiary,
    );
    child = Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 16.w, right: 6.w, top: 10.w, bottom: 10.w),
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

  @protected
  Widget? suffixWidget(BuildContext context, bool visible) {
    if (widget.suffixWidgetBuilder != null) {
      return widget.suffixWidgetBuilder!(context, visible);
    }
    if (!showClearButton) return null;
    return clearButton(context, visible);
  }

  @protected
  Widget suffixListenable(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: suffixVisible,
      builder: (_, value, _) =>
          suffixWidget(context, value) ?? const SizedBox.shrink(),
    );
  }

  @protected
  Widget inputRow(BuildContext context) {
    final prefix = prefixWidget(context);
    return Row(
      children: [
        ?prefix,
        Expanded(child: textField(context)),
        suffixListenable(context),
      ],
    );
  }

  @protected
  Widget decoratedInput(BuildContext context) {
    if (widget.decoratedInput != null) {
      return widget.decoratedInput!(context, inputRow(context));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: focusNode.hasFocus
                ? context.appColor.brand
                : context.appColor.compDivider,
            width: 0.5,
          ),
        ),
      ),
      child: inputRow(context),
    );
  }

  @protected
  Widget tappableInput(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (focusNode.canRequestFocus) {
          focusNode.requestFocus();
        }
      },
      child: decoratedInput(context),
    );
  }

  @protected
  Widget warnWidget(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: warnText,
      builder: (_, value, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Visibility(
            visible: value?.isNotEmpty == true,
            child: Text(
              value ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.appColor.warning,
              ),
            ),
          ),
        );
      },
    );
  }

  @protected
  Widget buildInput(BuildContext context) => tappableInput(context);

  @override
  Widget build(BuildContext context) {
    final child = buildInput(context);
    if (!showWarnText) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [child, warnWidget(context)],
    );
  }
}
