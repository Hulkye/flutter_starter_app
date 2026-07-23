import 'package:flutter/services.dart';

import '../../../core/theme/theme_context_ext.dart';
import '../../../core/util/screen_util.dart';

/// 数字加减步进组件。
class NumberStepper extends StatefulWidget {
  const NumberStepper({
    required this.value,
    required this.onChanged,
    required this.min,
    this.max,
    this.step = 1,
    this.enabled = true,
    this.width,
    this.height,
    super.key,
  }) : assert(max == null || min <= max),
       assert(step > 0);

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;
  final int step;
  final bool enabled;
  final double? width;
  final double? height;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

final class _NumberStepperState extends State<NumberStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && _controller.text != widget.value.toString()) {
      _setText(widget.value.toString());
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _currentValue => int.tryParse(_controller.text) ?? widget.value;

  bool get _canDecrease => widget.enabled && _currentValue > widget.min;
  bool get _canIncrease =>
      widget.enabled && (widget.max == null || _currentValue < widget.max!);

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _commitText();
    }
  }

  void _onTextChanged(String value) {
    final next = int.tryParse(value);
    if (next != null && next >= widget.min && _isWithinMax(next)) {
      _emit(next, syncText: false);
    }
    setState(() {});
  }

  void _commitText() {
    final next = int.tryParse(_controller.text);
    if (next == null) {
      _setText(widget.value.toString());
      return;
    }
    _emit(_normalize(next));
  }

  void _stepBy(int delta) {
    if (!widget.enabled) return;
    _emit(_normalize(_currentValue + delta));
  }

  void _emit(int value, {bool syncText = true}) {
    if (syncText) {
      _setText(value.toString());
    }
    if (value != widget.value) {
      widget.onChanged(value);
    }
    setState(() {});
  }

  int _normalize(int value) {
    final max = widget.max;
    if (max == null) return value < widget.min ? widget.min : value;
    return value.clamp(widget.min, max).toInt();
  }

  bool _isWithinMax(int value) {
    final max = widget.max;
    return max == null || value <= max;
  }

  void _setText(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 32.w;
    final backgroundColor = widget.enabled
        ? context.appColor.compBackgroundGray
        : context.appColor.compBackgroundGray.withValues(alpha: 0.55);
    final textColor = widget.enabled
        ? context.appColor.fontPrimary
        : context.appColor.fontFourth;
    return SizedBox(
      width: widget.width ?? 126.w,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                enabled: _canDecrease,
                onTap: () => _stepBy(-widget.step),
              ),
              _Divider(height: height),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15.sp,
                    height: 1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isCollapsed: true,
                    counterText: '',
                  ),
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _commitText(),
                ),
              ),
              _Divider(height: height),
              _StepperButton(
                icon: Icons.add,
                enabled: _canIncrease,
                onTap: () => _stepBy(widget.step),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: SizedBox.square(
        dimension: 36.w,
        child: Icon(
          icon,
          size: 16.w,
          color: enabled
              ? context.appColor.iconPrimary
              : context.appColor.iconFourth,
        ),
      ),
    );
  }
}

final class _Divider extends StatelessWidget {
  const _Divider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        width: 0.5,
        thickness: 0.5,
        color: context.appColor.compDivider,
      ),
    );
  }
}
