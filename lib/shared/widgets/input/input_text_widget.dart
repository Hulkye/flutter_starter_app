import 'package:flutter/services.dart';
import 'package:flutter_starter_app/header.dart';

enum InputTextType { password, normal, number, none }

InputDecoration createInputDecoration(
  BuildContext context, {
  String? hintText,
}) {
  return InputDecoration(
    fillColor: Colors.transparent,
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
    hintText: hintText ?? "",
    hintStyle: TextStyle(fontSize: 15.sp, color: context.appColor.fontTertiary),
    counterText: '',
  );
}

class AppTextField extends StatelessWidget {
  final int? maxLength;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextStyle? style;
  final int? maxLines;
  final String? hintText;
  final InputDecoration? decoration;
  final int? minLines;
  final bool? enabled;
  const AppTextField({
    this.maxLength,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.style,
    this.maxLines = 1,
    this.minLines = 1,
    this.hintText,
    this.decoration,
    this.enabled,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Widget child;
    child = TextField(
      maxLength: maxLength,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      style:
          style ??
          TextStyle(fontSize: 15.sp, color: context.appColor.fontPrimary),
      decoration:
          decoration ?? createInputDecoration(context, hintText: hintText),
      cursorWidth: 2.w,
      cursorColor: context.appColor.brand,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
    );
    return child;
  }
}

class InputTextWidget extends StatefulWidget {
  final String? defaultText;
  final String? hintText;
  final InputTextType? type;
  final String? warnText;
  final ValueChanged<String?>? onChanged;

  ///用于外部更新内容
  final ValueNotifier<String?>? textChange;
  final int? maxLen;
  final FocusNode? focusNode;
  final bool? enabled;
  final bool removeSpace;
  final double? horizontalPad;
  final List<TextInputFormatter>? formatterList;
  final Widget? prefixWidget;
  final Widget Function(BuildContext context, bool value)? suffixWidgetBuilder;

  const InputTextWidget({
    this.defaultText,
    this.hintText,
    this.warnText,
    this.onChanged,
    this.type = InputTextType.normal,
    this.focusNode,
    this.enabled,
    this.maxLen,
    this.removeSpace = true,
    this.prefixWidget,
    this.suffixWidgetBuilder,
    this.textChange,
    this.formatterList,
    this.horizontalPad,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => InputTextState();
}

class InputTextState extends State<InputTextWidget> {
  late TextEditingController editController;
  late FocusNode _focusNode;
  late InputTextType type;
  ValueNotifier<bool> tailStatus = ValueNotifier(false);
  ValueNotifier<String?> warnText = ValueNotifier(null);

  @override
  void didUpdateWidget(covariant InputTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    warnText.value = widget.warnText;
  }

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    type = widget.type ?? InputTextType.normal;
    if (type != InputTextType.password &&
        widget.defaultText?.isNotEmpty == true) {
      tailStatus = ValueNotifier(true);
    } else {
      tailStatus = ValueNotifier(false);
    }
    warnText.value = widget.warnText;

    editController = TextEditingController(text: widget.defaultText);
    _focusNode.addListener(() {
      setState(() {});
    });
    widget.textChange?.addListener(listenTextChange);
    super.initState();
  }

  void listenTextChange() {
    String? value = widget.textChange?.value;
    editController.text = value ?? "";
    onChange(editController.text);
  }

  @override
  void dispose() {
    widget.textChange?.removeListener(listenTextChange);
    warnText.dispose();
    if (_focusNode != widget.focusNode) {
      _focusNode.dispose();
    }
    editController.dispose();
    super.dispose();
  }

  void onChange(String? text) {
    if (widget.removeSpace) {
      text = text?.replaceAll(" ", "");
    }
    widget.onChanged?.call(text);
    if (type != InputTextType.password) {
      tailStatus.value = text?.isNotEmpty == true;
    }
  }

  Widget warnWidget(BuildContext context) {
    Widget child;
    child = ValueListenableBuilder(
      valueListenable: warnText,
      builder: (_, String? value, Widget? child) {
        Widget subChild = Text(
          textAlign: TextAlign.left,
          value ?? "",
          style: TextStyle(fontSize: 12.sp, color: context.appColor.warning),
        );
        subChild = Visibility(
          visible: value?.isNotEmpty == true,
          child: subChild,
        );
        return subChild;
      },
    );
    child = Padding(padding: EdgeInsets.only(top: 4), child: child);
    return child;
  }

  List<TextInputFormatter>? inputFormatters() {
    List<TextInputFormatter>? result;
    if (widget.formatterList != null) {
      result = widget.formatterList;
    } else {
      if (widget.type == InputTextType.number) {
        result = [FilteringTextInputFormatter.digitsOnly];
      }
    }
    return result;
  }

  Widget textFieldWidget(BuildContext context) {
    Widget child;
    child = AppTextField(
      maxLength: widget.maxLen,
      controller: editController,
      focusNode: _focusNode,
      onChanged: onChange,
      keyboardType: type == InputTextType.number ? TextInputType.phone : null,
      inputFormatters: inputFormatters(),
      obscureText: type == InputTextType.password ? !tailStatus.value : false,
      style: TextStyle(fontSize: 15.sp),
      hintText: widget.hintText,
      enabled: widget.enabled,
    );
    child = Padding(
      padding: EdgeInsets.only(top: 16.w, bottom: 16.w),
      child: child,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (type == InputTextType.password) {
      child = ValueListenableBuilder(
        valueListenable: tailStatus,
        builder: (_, bool value, Widget? child) {
          return textFieldWidget(context);
        },
      );
    } else {
      child = textFieldWidget(context);
    }
    child = borderWidget(context, child);
    child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [child, warnWidget(context)],
    );
    return child;
  }

  Widget normalWidget(BuildContext context, bool value) {
    Widget child = Icon(
      Icons.cancel,
      size: 12.w,
      color: context.appColor.iconTertiary,
    );
    child = Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16.w,
        right: widget.horizontalPad ?? 8.w,
        top: 10.w,
        bottom: 10.w,
      ),
      child: child,
    );
    child = GestureDetector(
      onTap: () {
        editController.text = "";
        onChange(editController.text);
      },
      child: child,
    );
    child = Visibility(
      visible: value,
      maintainState: true,
      maintainSize: true,
      maintainAnimation: true,
      child: child,
    );
    return child;
  }

  Widget passwordTailWidget(BuildContext context, bool value) {
    Widget child = Icon(
      value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      size: 20.w,
      color: context.appColor.iconTertiary,
    );
    child = Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16.w,
        right: widget.horizontalPad ?? 0,
        top: 10.w,
        bottom: 10.w,
      ),
      child: child,
    );
    child = GestureDetector(
      onTap: () {
        tailStatus.value = !value;
      },
      child: child,
    );
    return child;
  }

  Widget tailWidget(BuildContext context, InputTextType type) {
    Widget child;
    child = ValueListenableBuilder(
      valueListenable: tailStatus,
      builder: (_, bool value, Widget? child) {
        Widget subChild;
        if (widget.suffixWidgetBuilder != null) {
          return widget.suffixWidgetBuilder!.call(context, value);
        } else if (type != InputTextType.password) {
          subChild = normalWidget(context, value);
        } else {
          subChild = passwordTailWidget(context, value);
        }
        return subChild;
      },
    );
    return child;
  }

  Widget borderWidget(BuildContext context, Widget child) {
    Widget? tail;

    if (type != InputTextType.none) {
      tail = tailWidget(context, type);
    }
    if (tail != null) {
      child = Row(
        children: [
          ?widget.prefixWidget,
          Expanded(child: child),
          tail,
        ],
      );
    }

    child = Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _focusNode.hasFocus
                ? context.appColor.brand
                : context.appColor.compDivider,
            width: 1,
          ),
        ),
      ),
      child: child,
    );
    child = GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: child,
    );
    return child;
  }
}
