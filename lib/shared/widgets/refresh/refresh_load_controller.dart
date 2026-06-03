import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';

class RefreshLoadController extends EasyRefreshController {
  ///是否加载更多
  final bool showLoadMore;

  ///是否可以下拉刷新
  final bool showRefresh;

  ///当前是否可以下拉
  late bool refreshValue;

  ///当前是否可以上拉
  late bool loadMoreValue;

  ///autoRefresh = true, 则在加载完成后，刷新组件
  ValueNotifier<bool>? refresh;

  RefreshLoadController({
    super.controlFinishRefresh = true,
    super.controlFinishLoad = true,
    this.showLoadMore = true,
    this.showRefresh = true,
    bool autoRefresh = true,
  }) {
    if (autoRefresh) {
      refresh = ValueNotifier(false);
    }

    loadMoreValue = showLoadMore;
    refreshValue = showRefresh;
  }

  @override
  void dispose() {
    refresh?.dispose();
    super.dispose();
  }

  void _doRefresh() {
    if (refresh != null) {
      refresh!.value = !refresh!.value;
    }
  }

  @override
  void finishRefresh([
    IndicatorResult result = IndicatorResult.success,
    bool force = false,
  ]) {
    callRefreshFinish(
      hideRefresh: result == IndicatorResult.noMore,
      fail: result == IndicatorResult.fail,
    );
  }

  void callRefreshFinish({
    bool hideRefresh = false,
    bool fail = false,
    bool controllLoadMore = true,
  }) {
    bool canRefresh = false;
    if (showRefresh) {
      canRefresh = hideRefresh == refreshValue;
      refreshValue = !hideRefresh;
    }
    if (controllLoadMore && !fail && showLoadMore) {
      loadMoreValue = true;
    }

    super.finishRefresh();
    if (canRefresh) {
      _doRefresh();
    }
  }

  @override
  void finishLoad([
    IndicatorResult result = IndicatorResult.success,
    bool force = false,
  ]) {
    callLoadMoreFinish(
      hideLoadMore: result == IndicatorResult.noMore,
      fail: result == IndicatorResult.fail,
    );
  }

  void callLoadMoreFinish({
    bool hideLoadMore = false,
    bool fail = false,
    bool doRefresh = true,
  }) {
    if (showLoadMore) {
      loadMoreValue = !hideLoadMore;
    }
    if (doRefresh) {
      _doRefresh();
    }
    super.finishLoad();
  }
}
