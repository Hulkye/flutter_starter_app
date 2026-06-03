import 'dart:async';
import 'package:flutter_starter_app/header.dart';

/// 基于 [PrimaryRoundButton] 的验证码发送按钮。
///
/// 点击后先执行 [onSend]；仅当返回 `true`（接口成功）时进入倒计时。
/// 请求过程中按钮禁用并展示 [sendingLabel]。
class CountdownRoundButton extends StatefulWidget {
  const CountdownRoundButton({
    super.key,
    this.totalSeconds = 59,
    required this.idleLabel,
    required this.sendingLabel,
    required this.countdownLabelBuilder,
    this.onSend,
    this.idleEnabled = true,
    this.height,
    this.fontSize,
  });

  /// 倒计时时长（秒），界面从 [totalSeconds] 递减到 1 后结束。
  final int totalSeconds;

  /// 可点击时的文案。
  final String idleLabel;

  /// 等待接口响应时的文案。
  final String sendingLabel;

  /// 倒计时中的文案，参数为剩余秒数。
  final String Function(int secondsRemaining) countdownLabelBuilder;

  /// 发送验证码请求；返回 `true` 表示成功，随后开始倒计时；`false` 则保持可重试。
  /// 异常由调用方处理或吞掉；组件内捕获后不会开始倒计时。
  final Future<bool> Function()? onSend;

  /// 空闲状态下是否可点击（例如手机号填完后再允许获取验证码）。
  /// 倒计时与「发送中」不受此影响。
  final bool idleEnabled;

  final double? height;
  final double? fontSize;

  @override
  State<CountdownRoundButton> createState() => _CountdownRoundButtonState();
}

class _CountdownRoundButtonState extends State<CountdownRoundButton> {
  Timer? _timer;
  int? _remaining;
  bool _sending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label() {
    if (_sending) {
      return widget.sendingLabel;
    }
    final remaining = _remaining;
    if (remaining == null) {
      return widget.idleLabel;
    }
    return widget.countdownLabelBuilder(remaining);
  }

  Future<void> _handlePressed() async {
    if (_remaining != null || _sending) {
      return;
    }
    final send = widget.onSend;
    if (send == null) {
      return;
    }
    setState(() => _sending = true);
    var shouldCountdown = false;
    try {
      shouldCountdown = await send();
    } catch (_) {
      shouldCountdown = false;
    }
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    if (shouldCountdown) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remaining = widget.totalSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    final r = _remaining;
    if (r == null) {
      timer.cancel();
      return;
    }
    if (r <= 1) {
      timer.cancel();
      setState(() => _remaining = null);
    } else {
      setState(() => _remaining = r - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inCountdown = _remaining != null;
    final canTap =
        !inCountdown &&
        !_sending &&
        widget.onSend != null &&
        widget.idleEnabled;
    return PrimaryRoundButton(
      context: context,
      label: _label(),
      height: widget.height ?? 30.w,
      fontSize: widget.fontSize ?? 12.sp,
      expand: false,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.w),
      onPressed: canTap ? () => _handlePressed() : null,
    );
  }
}
