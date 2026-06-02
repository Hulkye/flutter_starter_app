import 'package:flutter_starter_app/header.dart';

enum DialogBtnType { normal, primary, warning }

class DialogBtn extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback? onTap;
  final DialogBtnType? btnType;

  const DialogBtn({
    required this.label,
    required this.height,
    this.onTap,
    this.btnType,
    super.key,
  });

  Color getColor(BuildContext context) {
    switch (btnType) {
      case DialogBtnType.normal:
        return context.appColor.fontSecondary;
      case DialogBtnType.warning:
        return context.appColor.warning;
      default:
        return context.appColor.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      label,
      style: TextStyle(
        color: getColor(context),
        fontSize: 17.sp,
        height: 22 / 17,
      ),
    );
    child = Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: child,
    );
    child = GestureDetector(onTap: onTap, child: child);
    return child;
  }
}

/// 弹窗卡片
class DialogCard extends StatelessWidget {
  final Widget child;

  final double? width;

  final EdgeInsets? padding;

  const DialogCard({required this.child, this.width, this.padding, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width ?? 270.w,
        decoration: BoxDecoration(
          color: context.appColor.compBackgroundPrimary,
          borderRadius: BorderRadius.circular(12.w),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// 弹窗标题
class DialogTitle extends StatelessWidget {
  final String title;

  final EdgeInsetsGeometry? margin;

  const DialogTitle({required this.title, this.margin, super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 17.sp,
      height: 22 / 17,
      color: context.appColor.fontPrimary,
      fontWeight: FontWeight.bold,
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: margin,
      alignment: Alignment.topCenter,
      child: Text(title, style: textStyle, textAlign: TextAlign.center),
    );
  }
}

/// 弹窗描述
class DialogDesc extends StatelessWidget {
  final String desc;

  final EdgeInsetsGeometry? margin;

  const DialogDesc({required this.desc, this.margin, super.key});

  Widget addContainer(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: margin,
      constraints: BoxConstraints(maxHeight: 230.w),
      child: SingleChildScrollView(child: child),
    );
  }

  Widget createDesc(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 13.sp,
      height: 18 / 13,
      color: context.appColor.fontPrimary,
    );
    return Text(desc, style: textStyle, textAlign: TextAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    return addContainer(createDesc(context));
  }
}

/// 弹窗bar
class DialogMainBar extends StatelessWidget {
  /// 确认回调
  final VoidCallback? onConfirm;

  /// 撤销回调
  final VoidCallback? onCancel;

  final String? confirmText;
  final String? cancelText;

  const DialogMainBar({
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    super.key,
  });

  bool get showCancel => onCancel != null;
  bool get showConfirm => onConfirm != null;
  bool get showAll => showCancel && showConfirm;

  DialogBtnType get confirmBtnType => DialogBtnType.primary;
  DialogBtnType get cancelBtnType => DialogBtnType.normal;

  Widget confirmBtn(BuildContext context) {
    return DialogBtn(
      btnType: confirmBtnType,
      height: 44.w,
      label: confirmText ?? context.i18n.confirm,
      onTap: onConfirm,
    );
  }

  Widget cancelBtn(BuildContext context) {
    return DialogBtn(
      btnType: cancelBtnType,
      height: 44.w,
      label: cancelText ?? context.i18n.cancel,
      onTap: onCancel,
    );
  }

  Widget spaceLine(BuildContext context) {
    return VerticalDivider(width: 0.3, color: context.appColor.compDivider);
  }

  @override
  Widget build(BuildContext context) {
    if (!showCancel && !showConfirm) {
      return SizedBox(height: 8.w);
    }
    Widget child = Row(
      children: [
        if (showCancel) Expanded(child: cancelBtn(context)),
        if (showAll) spaceLine(context),
        if (showConfirm) Expanded(child: confirmBtn(context)),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.3, color: context.appColor.compDivider),
        ),
      ),
      child: child,
    );
  }
}

class DialogWarningBar extends DialogMainBar {
  const DialogWarningBar({
    super.key,
    super.onConfirm,
    super.onCancel,
    super.confirmText,
    super.cancelText,
  });

  @override
  DialogBtnType get confirmBtnType => DialogBtnType.warning;
}
