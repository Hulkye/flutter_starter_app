import 'package:flutter_starter_app/core/theme/theme_context_ext.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';
import 'base_switch.dart';

/// 开关组件
class SwitchWidget extends StatelessWidget {
  final bool value; // 当前开关的状态
  final ValueChanged<bool> onChanged; // 开关状态改变时的回调函数

  const SwitchWidget({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: context.appColor.brand,
      trackColor: context.appColor.compBackgroundSecondary,
      thumbColor: context.appColor.compBackgroundPrimary,
      thumbShadowColor: context.appColor.compDivider,
      width: 40.w,
      height: 24.w,
      padding: 1.5.w,
    );
  }
}
