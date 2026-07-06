import 'package:flutter/widgets.dart';

import 'common_select_sheet.dart';

Future<void> showBusinessSelectSheet(
  BuildContext context, {
  String? title,
  required List<SelectItemOption> options,
  int? checkedValue, // value
  ValueChanged<int>? onSelectChange, // 选中的value，非index
}) {
  return showCommonSelectSheet(
    context,
    options: options,
    title: title,
    checkedIndex: options.indexWhere((item) => item.value == checkedValue),
    onSelectChange: (index) {
      final value = options[index].value;
      if (value != checkedValue) {
        onSelectChange?.call(value);
      }
    },
  );
}
