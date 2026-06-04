import 'package:flutter_starter_app/header.dart';

class BaseCard extends StatelessWidget {
  final Color? bgColor;
  final double? borderRadius;
  final Widget child;

  const BaseCard({
    required this.child,
    this.bgColor,
    this.borderRadius,
    super.key,
  });

  Color getBgColor(BuildContext context) {
    return context.appColor.backgroundPrimary;
  }

  double get _borderRadius => borderRadius ?? 8.w;

  BoxShadow getBoxShadow(BuildContext context) {
    return BoxShadow(
      offset: Offset(0, 2),
      blurRadius: _borderRadius,
      spreadRadius: 2.w,
      color: context.appColor.fontPrimary.withValues(alpha: 0.02),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getBgColor(context),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [getBoxShadow(context)],
      ),
      child: child,
    );
  }
}
