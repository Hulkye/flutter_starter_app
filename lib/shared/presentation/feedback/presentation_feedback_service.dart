/// Loading 展示回调。
typedef ShowLoadingHandler = void Function({bool allowClick, bool crossPage});

/// Loading 隐藏回调。
typedef HideLoadingHandler = void Function();

/// Hint 展示回调。
typedef ShowHintHandler = void Function(String hint);

/// Loading 展示令牌。
///
/// 调用 [PresentationFeedbackService.showLoading] 后必须用返回的 token 关闭。
final class PresentationLoadingToken {
  PresentationLoadingToken._();
}

/// Presentation 层一次性 UI 反馈服务。
///
/// Loading / Hint 是一次性 UI 反馈，不进入页面长期可渲染 State。
final class PresentationFeedbackService {
  PresentationFeedbackService({
    this.showLoadingHandler,
    this.hideLoadingHandler,
    this.showHintHandler,
  });

  ShowLoadingHandler? showLoadingHandler;
  HideLoadingHandler? hideLoadingHandler;
  ShowHintHandler? showHintHandler;

  final Set<PresentationLoadingToken> _loadingTokens =
      <PresentationLoadingToken>{};

  bool get isShowingLoading => _loadingTokens.isNotEmpty;

  PresentationLoadingToken showLoading({
    bool allowClick = false,
    bool crossPage = true,
  }) {
    final token = PresentationLoadingToken._();
    final shouldShow = _loadingTokens.isEmpty;
    _loadingTokens.add(token);
    if (shouldShow) {
      showLoadingHandler?.call(allowClick: allowClick, crossPage: crossPage);
    }
    return token;
  }

  void hideLoading([PresentationLoadingToken? token]) {
    if (_loadingTokens.isEmpty) return;
    if (token == null) {
      _loadingTokens.clear();
      hideLoadingHandler?.call();
      return;
    }
    if (!_loadingTokens.remove(token)) return;
    if (_loadingTokens.isEmpty) {
      hideLoadingHandler?.call();
    }
  }

  Future<void> runWithLoading(
    Future<void> Function() action, {
    bool allowClick = false,
    bool crossPage = true,
    bool emitErrorHint = true,
    bool rethrowError = true,
  }) async {
    final token = showLoading(allowClick: allowClick, crossPage: crossPage);
    try {
      await action();
    } catch (error, stackTrace) {
      if (emitErrorHint) {
        emitHint(error.toString());
      }
      if (rethrowError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    } finally {
      hideLoading(token);
    }
  }

  void emitHint(String hint) {
    if (hint.trim().isEmpty) return;
    showHintHandler?.call(hint);
  }

  void resetLoadingState() {
    _loadingTokens.clear();
  }
}
