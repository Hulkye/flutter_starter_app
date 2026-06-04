import 'package:flutter_starter_app/header.dart';
import 'package:flutter_starter_app/shared/widgets/label_widget/label_row.dart';

typedef LabelRowValueBuilder = Widget Function();
typedef LabelRowDescBuilder = Widget Function();

class LabelArrowRow extends LabelRow {
  final String? value;
  final String? defValue;
  final double? valueSize;
  final double? valueColor;
  final LabelRowValueBuilder? valueBuilder;
  final LabelRowDescBuilder? descBuilder;
  final double? arrowSize;
  final bool showArrow;

  const LabelArrowRow({
    required super.label,
    super.labelColor,
    super.labelFontSize,
    super.icon,
    super.iconSize,
    super.onTap,
    super.padding,
    super.key,
    this.value,
    this.defValue,
    this.valueSize,
    this.valueColor,
    this.valueBuilder,
    this.descBuilder,
    this.arrowSize,
    this.showArrow = true,
  });

  Widget arrowWidget(BuildContext context) {
    Widget child = Container();
    if (showArrow) {
      final size = arrowSize ?? 14.w;
      child = Icon(
        Icons.arrow_forward_ios,
        size: size,
        color: context.appColor.fontSecondary,
      );
      child = Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: child,
      );
    }

    return child;
  }

  Widget valueWidget(BuildContext context) {
    Widget child = Container();
    if (valueBuilder != null) {
      child = valueBuilder!.call();
    } else {
      if (value != null || defValue != null) {
        child = Text(
          value ?? defValue!,
          style: TextStyle(
            fontSize: valueSize ?? 15.sp,
            color: context.appColor.fontSecondary,
          ),
        );
      }
    }
    return child;
  }

  @override
  Widget labelWidget(BuildContext context) {
    Widget child = super.labelWidget(context);
    if (descBuilder != null) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [child, descBuilder!.call()],
      );
    }
    return child;
  }

  @override
  Widget createExt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [valueWidget(context), arrowWidget(context)],
    );
  }
}
