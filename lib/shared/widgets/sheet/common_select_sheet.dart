

import '../../../header.dart';
import 'auto_height_sheet_view.dart';

Future<void> showCommonSelectSheet(
  BuildContext context, {
  required List<SelectItemOption> options,
  int? checkedIndex,
  String? title,
  ValueChanged<int>? onSelectChange,
}) {
  final contentWidget = CommonSelectSheet(
    options: options,
    checkedIndex: checkedIndex,
    title: title,
    onSelectChange: onSelectChange,
  );
  return showCommonSheet(context, contentWidget);
}

class SelectItemOption {
  final String label;
  final dynamic value;

  SelectItemOption({required this.label, this.value});
}

class CommonSelectSheet extends StatelessWidget {
  final int? checkedIndex; // 选中的角标
  final List<SelectItemOption> options;
  final String? title;
  final ValueChanged<int>? onSelectChange;

  const CommonSelectSheet({
    required this.options,
    this.checkedIndex,
    this.title,
    this.onSelectChange,
    super.key,
  });

  void _onCancel(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Widget createTitle(BuildContext context) {
    if (title == null || title!.isEmpty) {
      return Container();
    }
    Widget child = Text(
      title!,
      style: TextStyle(
        fontSize: 17.sp,
        color: context.appColor.fontPrimary,
        fontWeight: FontWeight.bold,
        height: 22 / 17,
      ),
    );
    child = Container(
      constraints: BoxConstraints(minHeight: 60.w),
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: child,
    );
    return child;
  }

  Widget createCancelBtn(BuildContext context) {
    Widget child = NormalRoundButton(
      context: context,
      label: context.i18n.cancel,
      height: 44.w,
      onPressed: () {
        _onCancel(context);
      },
      expand: false,
    );
    child = Padding(
      padding: EdgeInsets.symmetric(vertical: 23.w, horizontal: 18.w),
      child: child,
    );
    return child;
  }

  Widget createOptionItem(BuildContext context, int index) {
    final item = options[index];
    final checked = checkedIndex == index;
    Color labelColor, bgColor;
    if (checked) {
      labelColor = context.appColor.brand;
      bgColor = context.appColor.compEmphasizeTertiary;
    } else {
      labelColor = context.appColor.fontSecondary;
      bgColor = Colors.transparent;
    }
    Widget child = Text(
      item.label,
      style: TextStyle(
        fontSize: 17.sp,
        color: labelColor,
        fontWeight: FontWeight.bold,
        height: 22 / 17,
      ),
    );
    child = Container(
      alignment: Alignment.center,
      height: 52.w,
      color: bgColor,
      child: child,
    );
    child = GestureDetector(
      onTap: () {
        onSelectChange?.call(index);
        _onCancel(context);
      },
      child: child,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(createTitle(context));
    for (var i = 0; i < options.length; i++) {
      children.add(createOptionItem(context, i));
    }
    children.add(createCancelBtn(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
