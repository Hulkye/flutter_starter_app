import '../../header.dart';

enum AppBootstrapTarget { root, login }

typedef AppReader = T Function<T>(ProviderListenable<T> provider);

final appBootstrapCoordinatorProvider = Provider<AppBootstrapCoordinator>(
  (ref) => AppBootstrapCoordinator(ref.read),
);

class AppBootstrapCoordinator {
  AppBootstrapCoordinator(this.ref);

  final AppReader ref;

  Future<AppBootstrapTarget> start() async {
    if (!authStore.isAuthenticated) {
      return AppBootstrapTarget.login;
    }

    return AppBootstrapTarget.root;
  }
}
