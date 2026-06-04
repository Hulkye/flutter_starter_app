import 'package:flutter/material.dart';
import 'package:flutter_starter_app/shared/widgets/label_widget/label_row.dart';
import 'package:flutter_starter_app/shared/widgets/switch/switch_widget.dart';

/// 带开关的标签行
class LabelSwitchRow extends LabelRow {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const LabelSwitchRow({
    required super.label,
    super.labelColor,
    super.labelFontSize,
    super.icon,
    super.iconSize,
    super.onTap,
    super.padding,
    super.key,
    required this.checked,
    required this.onChanged,
  });

  Widget switchWidget(BuildContext context) {
    return SwitchWidget(value: checked, onChanged: onChanged);
  }

  @override
  Widget createExt(BuildContext context) {
    return switchWidget(context);
  }
}
