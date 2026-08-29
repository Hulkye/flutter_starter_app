import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/auth/auth.dart';

enum AppBootstrapTarget { root, login }

/// App bootstrap 是否已完成。
final appBootstrapCompletedProvider = StateProvider<bool>((ref) => false);

typedef AppReader = T Function<T>(ProviderListenable<T> provider);

final appBootstrapCoordinatorProvider = Provider<AppBootstrapCoordinator>(
  (ref) => AppBootstrapCoordinator(ref.read),
);

class AppBootstrapCoordinator {
  AppBootstrapCoordinator(this.ref);

  final AppReader ref;

  Future<AppBootstrapTarget> start() async {
    final session = ref(authSessionProvider);
    if (session?.isValid != true) {
      return AppBootstrapTarget.login;
    }

    return AppBootstrapTarget.root;
  }
}
