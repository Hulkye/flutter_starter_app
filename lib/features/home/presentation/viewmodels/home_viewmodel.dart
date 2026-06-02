import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/presentation.dart';
import '../../data/repositories/home_repository_impl.dart';

/// Home 页面状态。
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
