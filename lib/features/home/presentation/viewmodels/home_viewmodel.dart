import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/presentation.dart';
import '../../data/repositories/home_repository_impl.dart';

/// Home 页面状态。
///
/// 注意：这里没有使用 @freezed，因为 ViewModel state 通常只有 2-3 个字段，
/// 手动 copyWith 足够简洁。对于 data 层 DTO 模型（字段多且需要 JSON 序列化），
/// 推荐使用 @freezed + @JsonSerializable。
class HomeState extends BaseState {
  const HomeState({
    super.isReady = true,
    this.requestResult = '',
    this.requesting = false,
  });

  final String requestResult;
  final bool requesting;

  @override
  HomeState copyWithBase({bool? isReady}) {
    return copyWith(isReady: isReady);
  }

  HomeState copyWith({
    bool? isReady,
    String? requestResult,
    bool? requesting,
  }) {
    return HomeState(
      isReady: isReady ?? this.isReady,
      requestResult: requestResult ?? this.requestResult,
      requesting: requesting ?? this.requesting,
    );
  }
}

/// Home ViewModel。
final class HomeViewModel extends BaseVM<HomeState> {
  @override
  HomeState initialState() => const HomeState();

  Future<void> requestDemo() async {
    if (state.requesting) return;
    state = state.copyWith(requesting: true);
    try {
      final data = await ref.read(homeRepositoryProvider).fetchDemo();
      state = state.copyWith(
        requestResult: 'success: ${data.toString()}',
        requesting: false,
      );
    } catch (e) {
      emitHint(e.toString());
      state = state.copyWith(
        requestResult: e.toString(),
        requesting: false,
      );
    }
  }
}

/// Home ViewModel Provider。
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
