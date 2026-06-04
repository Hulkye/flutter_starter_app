import '../widgets/toast/toast.dart';

/// Loading 展示回调。
typedef ShowLoadingHandler = void Function({bool allowClick, bool crossPage});

/// Loading 隐藏回调。
typedef HideLoadingHandler = void Function();

/// Hint 展示回调。
typedef ShowHintHandler = void Function(String hint);

/// Presentation 层通用辅助工具。
///
/// Loading / Hint 是一次性 UI 反馈，不进入 [BaseState]。
final class PresentationHelper {
  const PresentationHelper._();

  static ShowLoadingHandler? showLoadingHandler;
  static HideLoadingHandler? hideLoadingHandler;
  static ShowHintHandler? showHintHandler;

  static bool _isShowingLoading = false;

  static void showLoading({bool allowClick = false, bool crossPage = true}) {
    _isShowingLoading = true;
    showLoadingHandler?.call(allowClick: allowClick, crossPage: crossPage);
  }

  static void hideLoading() {
    if (!_isShowingLoading) return;
    _isShowingLoading = false;
    hideLoadingHandler?.call();
  }

  static Future<void> runWithLoading(
    Future<void> Function() action, {
    bool allowClick = false,
    bool crossPage = true,
  }) async {
    if (_isShowingLoading) return;
    showLoading(allowClick: allowClick, crossPage: crossPage);
    try {
      await action();
    } catch (e) {
      emitHint(e.toString());
    } finally {
      hideLoading();
    }
  }

  static void emitHint(String hint) {
    if (hint.trim().isEmpty) return;
    showHintHandler?.call(hint);
  }

  static void resetHandlers() {
    showLoadingHandler = null;
    hideLoadingHandler = null;
    showHintHandler = null;
    _isShowingLoading = false;
  }
}

void bindPresentationHelper() {
  PresentationHelper.showLoadingHandler = BaseLoading.show;
  PresentationHelper.hideLoadingHandler = BaseLoading.close;
  PresentationHelper.showHintHandler = BaseToast.show;
}
