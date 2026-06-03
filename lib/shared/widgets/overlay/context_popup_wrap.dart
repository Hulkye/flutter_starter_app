import 'package:flutter/material.dart';

/// 弹窗展开方向和对齐方式的枚举
enum PrePopupDirection {
  topLeft, // 向上展开，弹窗内容左下角对齐目标左上角
  topRight, // 向上展开，弹窗内容右下角对齐目标右上角
  bottomLeft, // 向下展开，弹窗内容左上角对齐目标左下角
  bottomRight, // 向下展开，弹窗内容右上角对齐目标右下角
}

typedef ContextPopupBuilder =
    Widget Function(Future<void> Function() cancelFunc);

class ContextPopupWrap extends StatefulWidget {
  final Widget child; // 触发弹窗的对象
  final ContextPopupBuilder popupContent; // 弹窗内容
  final Offset offset; // 偏移值
  final PrePopupDirection prePopupDirection; // 预设方向和对齐方式
  final Color? maskBgColor;

  const ContextPopupWrap({
    required this.child,
    required this.popupContent,
    this.offset = Offset.zero,
    this.prePopupDirection = PrePopupDirection.bottomLeft, // 默认向下左对齐
    this.maskBgColor,
    super.key,
  });

  @override
  State<ContextPopupWrap> createState() => _ContextPopupWrapState();
}

class _ContextPopupWrapState extends State<ContextPopupWrap>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final GlobalKey _popupKey = GlobalKey(); // 用于动态测量弹窗高度

  bool _isExpanded = false; // 弹窗是否展开
  double _popupHeight = 0.0; // 动态获取弹窗的高度
  double _popupWidth = 0.0; // 动态获取弹窗的宽度
  PrePopupDirection _currentDirection = PrePopupDirection.bottomLeft; // 当前方向

  double _horizontalPosition = 0;
  double _verticalPosition = 0;

  bool get _isFirstShow => _popupHeight == 0 && _popupWidth == 0;

  bool isRtl() {
    final locale = Localizations.localeOf(context);
    return ["ar", "fa", "he", "ps", "sd", "ur"].contains(locale.languageCode);
  }

  PrePopupDirection _changeDirection(PrePopupDirection direction) {
    if (isRtl()) {
      if (direction == PrePopupDirection.topLeft) {
        return PrePopupDirection.topRight;
      }
      if (direction == PrePopupDirection.topRight) {
        return PrePopupDirection.topLeft;
      }
      if (direction == PrePopupDirection.bottomLeft) {
        return PrePopupDirection.bottomRight;
      }
      if (direction == PrePopupDirection.bottomRight) {
        return PrePopupDirection.bottomLeft;
      }
    }
    return direction;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 180),
    );

    // 初始化动画
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0), // 默认初始位置
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.dispose();
    super.dispose();
  }

  Widget _overlayBuilder(BuildContext context) {
    return PopScope(
      canPop: _isExpanded,
      onPopInvokedWithResult: (didPop, result) {
        _closePopup(context, true);
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _closePopup(context), // 点击其他区域关闭弹窗
            child: Container(color: widget.maskBgColor ?? Colors.transparent),
          ),
          Positioned(
            left: _horizontalPosition,
            top: _verticalPosition,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    key: _popupKey, // 绑定 key，用于动态测量高度
                    child: widget.popupContent(() => _closePopup(context)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _measureOverlayBuilder(BuildContext context) {
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned(
              left: -100000,
              top: -100000,
              child: Opacity(
                opacity: 0,
                child: Container(
                  key: _popupKey,
                  child: widget.popupContent(() async {}),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _doShow(BuildContext context) {
    _isExpanded = true;
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return _overlayBuilder(context);
          },
    );
    _animationController.forward();
  }

  void _doShowHandle(
    BuildContext context, {
    VoidCallback? beforeShowHandle,
    VoidCallback? afterShowHandle,
  }) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset targetPosition = renderBox.localToGlobal(Offset.zero);
    final Size targetSize = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;
    // 根据空间调整方向
    _currentDirection = _adjustDirection(
      targetPosition,
      targetSize,
      screenSize,
    );
    // 更新动画方向
    _slideAnimation =
        Tween<Offset>(
          begin: _getSlideAnimationBegin(_currentDirection),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    // 计算位置并更新
    _calculateHorizontalPosition(targetPosition, targetSize);
    _calculateVerticalPosition(targetPosition, targetSize);
    beforeShowHandle?.call();
    _doShow(context);
    afterShowHandle?.call();
  }

  void _showPopup(BuildContext context) {
    _animationController.value = 0;
    if (_isFirstShow) {
      _overlayEntry = OverlayEntry(
        builder: (context) => _measureOverlayBuilder(context),
      );

      // 插入弹窗到 Overlay
      Overlay.of(context).insert(_overlayEntry!);

      // 延迟获取高度和宽度，并根据屏幕空间调整方向
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_popupKey.currentContext?.mounted ?? false) {
          _popupHeight = _getPopupHeight();
          _popupWidth = _getPopupWidth();

          _doShowHandle(
            context,
            beforeShowHandle: () {
              _overlayEntry?.remove();
            },
          );
        }
      });
    } else {
      _doShowHandle(context);
    }
  }

  void _calculateHorizontalPosition(Offset targetPosition, Size targetSize) {
    double position = 0;
    if (_currentDirection == PrePopupDirection.topLeft ||
        _currentDirection == PrePopupDirection.bottomLeft) {
      position = targetPosition.dx + widget.offset.dx; // 左对齐
    } else {
      position =
          targetPosition.dx +
          targetSize.width -
          _popupWidth -
          widget.offset.dx; // 右对齐
    }
    _horizontalPosition = position;
  }

  void _calculateVerticalPosition(Offset targetPosition, Size targetSize) {
    double position = 0;
    if (_currentDirection == PrePopupDirection.topLeft ||
        _currentDirection == PrePopupDirection.topRight) {
      position = targetPosition.dy - _popupHeight - widget.offset.dy; // 向上展开
    } else {
      position =
          targetPosition.dy + targetSize.height + widget.offset.dy; // 向下展开
    }
    _verticalPosition = position;
  }

  double _getPopupHeight() {
    final RenderBox? popupRenderBox =
        _popupKey.currentContext?.findRenderObject() as RenderBox?;
    return popupRenderBox?.size.height ?? 0.0;
  }

  double _getPopupWidth() {
    final RenderBox? popupRenderBox =
        _popupKey.currentContext?.findRenderObject() as RenderBox?;
    return popupRenderBox?.size.width ?? 0.0;
  }

  PrePopupDirection _adjustDirection(
    Offset targetPosition,
    Size targetSize,
    Size screenSize,
  ) {
    // 如果向下展开空间不足
    if ((widget.prePopupDirection == PrePopupDirection.bottomLeft ||
            widget.prePopupDirection == PrePopupDirection.bottomRight) &&
        (targetPosition.dy +
                targetSize.height +
                _popupHeight +
                widget.offset.dy >
            screenSize.height)) {
      PrePopupDirection direction =
          widget.prePopupDirection == PrePopupDirection.bottomLeft
          ? PrePopupDirection.topLeft
          : PrePopupDirection.topRight;
      return _changeDirection(direction);
    }

    // 如果向上展开空间不足
    if ((widget.prePopupDirection == PrePopupDirection.topLeft ||
            widget.prePopupDirection == PrePopupDirection.topRight) &&
        (targetPosition.dy - _popupHeight - widget.offset.dy < 0)) {
      PrePopupDirection direction =
          widget.prePopupDirection == PrePopupDirection.topLeft
          ? PrePopupDirection.bottomLeft
          : PrePopupDirection.bottomRight;
      return _changeDirection(direction);
    }

    // 如果水平空间不足（可以扩展逻辑）
    return _changeDirection(widget.prePopupDirection);
  }

  Offset _getSlideAnimationBegin(PrePopupDirection direction) {
    if (direction == PrePopupDirection.topLeft ||
        direction == PrePopupDirection.topRight) {
      return const Offset(0, 0.1); // 从下往上展开
    } else {
      return const Offset(0, -0.1); // 从上往下展开
    }
  }

  Future<void> _closePopup(BuildContext context, [bool fromPop = false]) async {
    _isExpanded = false;
    await _animationController.reverse();
    if (!fromPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPopup(context);
      },
      child: widget.child,
    );
  }
}
