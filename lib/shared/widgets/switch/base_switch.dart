import 'package:flutter/material.dart';

class BaseSwitch extends StatefulWidget {
  final bool value; // 当前开关的状态
  final ValueChanged<bool> onChanged; // 开关状态改变时的回调函数
  final Color activeColor; // 开关打开时的颜色
  final Color trackColor; // 开关关闭时的背景颜色
  final Color thumbColor; // 滑块颜色
  final Color thumbShadowColor; // 滑块阴影颜色
  final double width; // 开关的宽度
  final double height; // 开关的高度
  final double padding; // 内部间隔
  final Duration animationDuration; // 动画时常

  const BaseSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.trackColor,
    required this.thumbColor,
    required this.thumbShadowColor,
    this.width = 50, // 默认宽度
    this.height = 30, // 默认高度
    this.padding = 2,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<BaseSwitch> createState() => _BaseSwitchState();
}

class _BaseSwitchState extends State<BaseSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool get checked => widget.value;
  double get width => widget.width;
  double get height => widget.height;
  double get padding => widget.padding;

  double get wrapRadius => height / 2;
  double get thumbSize => height - (padding * 2);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: checked ? 1.0 : 0.0, // 根据初始状态设置动画进度
    );
  }

  @override
  void didUpdateWidget(covariant BaseSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(checked ? 1.0 : 0.0); // 当状态改变时更新动画
  }

  void _onToggleSwitch() {
    widget.onChanged(!checked); // 切换状态
    _animationController.animateTo(checked ? 1.0 : 0.0); // 切换时触发动画
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onToggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width, // 使用设置的宽度
        height: height, // 使用设置的高度
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(wrapRadius), // 设置圆角
          color: checked ? widget.activeColor : widget.trackColor, // 根据状态切换颜色
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut, // 滑动的动画曲线
          alignment: checked
              ? Alignment.centerRight
              : Alignment.centerLeft, // 滑块的位置
          child: Container(
            width: thumbSize, // 滑块的宽度
            height: thumbSize, // 滑块的高度
            decoration: BoxDecoration(
              shape: BoxShape.circle, // 滑块是一个圆形
              color: widget.thumbColor, // 滑块颜色
              boxShadow: checked
                  ? []
                  : [
                      BoxShadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 3,
                        spreadRadius: 0,
                        color: widget.thumbShadowColor,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // 销毁动画控制器
    super.dispose();
  }
}
