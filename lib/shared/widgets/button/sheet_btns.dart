import 'package:flutter_starter_app/header.dart';

abstract class BaseSheetBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const BaseSheetBtn({super.key, required this.label, this.onPressed});

  Color getBgColor(BuildContext context);
  Color getBorderColor(BuildContext context);
  Color getTextColor(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      label,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: getTextColor(context),
      ),
    );
    child = Container(
      height: 50.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getBgColor(context),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: child,
    );
    child = GestureDetector(onTap: onPressed, child: child);
    return child;
  }
}

class SheetConfirmBtn extends BaseSheetBtn {
  const SheetConfirmBtn({super.key, required super.label, super.onPressed});

  @override
  Color getBgColor(BuildContext context) => context.appColor.brand;

  @override
  Color getBorderColor(BuildContext context) => context.appColor.brand;

  @override
  Color getTextColor(BuildContext context) => context.appColor.fontOnPrimary;
}

class SheetCancelBtn extends BaseSheetBtn {
  const SheetCancelBtn({super.key, required super.label, super.onPressed});

  @override
  Color getBgColor(BuildContext context) => Colors.transparent;

  @override
  Color getBorderColor(BuildContext context) => context.appColor.compDivider;

  @override
  Color getTextColor(BuildContext context) => context.appColor.fontPrimary;
}
