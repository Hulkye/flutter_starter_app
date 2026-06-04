import 'package:flutter_starter_app/header.dart';

/// 基础的标签行组件
class LabelRow extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final double? labelFontSize;

  final String? icon;
  final double? iconSize;

  final VoidCallback? onTap;

  final EdgeInsets? padding;

  const LabelRow({
    required this.label,
    this.labelColor,
    this.labelFontSize,
    this.icon,
    this.iconSize,
    this.onTap,
    this.padding,
    super.key,
  });

  Widget createWrap(BuildContext context, Widget child) {
    return Container(color: Colors.transparent, padding: padding, child: child);
  }

  Widget iconWidget(BuildContext context) {
    Widget child = Container();
    if (icon != null) {
      final size = iconSize ?? 24.w;
      child = ImageView(assetPath: icon, width: size, height: size);
      child = Padding(
        padding: EdgeInsetsDirectional.only(end: 8.w),
        child: child,
      );
    }
    return child;
  }

  Widget labelWidget(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: labelFontSize ?? 15.sp,
        color: labelColor ?? context.appColor.fontPrimary,
      ),
    );
  }

  Widget createContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget(context),
        Expanded(child: labelWidget(context)),
      ],
    );
  }

  Widget createExt(BuildContext context) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: [
        Expanded(child: createContent(context)),
        createExt(context),
      ],
    );
    child = createWrap(context, child);
    child = GestureDetector(onTap: onTap, child: child);
    return child;
  }
}
