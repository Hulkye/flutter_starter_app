import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/presentation.dart';

/// Profile 页面状态。
class ProfileState extends BaseState {
  const ProfileState();
}

/// Profile ViewModel。
final class ProfileViewModel extends BaseVM<ProfileState> {
  @override
  ProfileState initialState() => const ProfileState();
}

/// Profile ViewModel Provider。
final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
