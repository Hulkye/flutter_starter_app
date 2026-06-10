import 'package:flutter_starter_app/header.dart';
import 'app_bootstrap_coordinator.dart';
import 'app_session_coordinator.dart';

class AppHost extends ConsumerStatefulWidget {
  const AppHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppHost> createState() => _AppHostState();
}

class _AppHostState extends ConsumerState<AppHost> {
  late final AppSessionCoordinator _sessionCoordinator;
  bool _bootstrapStarted = false;

  @override
  void initState() {
    super.initState();
    _sessionCoordinator = AppSessionCoordinator(
      read: ref.read,
      context: context,
    );
    _sessionCoordinator.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bootstrapStarted) return;
      _bootstrapStarted = true;
      _startBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _startBootstrap() async {
    final appRouter = ref.read(appRouterProvider);
    final bootstrapCoordinator = ref.read(appBootstrapCoordinatorProvider);
    final location = appRouter.location;
    if (Uri.tryParse(location)?.path != const SplashRoute().path) return;

    final target = await bootstrapCoordinator.start();
    if (!mounted) return;

    final targetLocation = switch (target) {
      AppBootstrapTarget.root => RootRoute().location,
      AppBootstrapTarget.login => const LoginRoute().location,
    };
    if (appRouter.location == targetLocation) return;
    appRouter.replaceAll(targetLocation);
  }
}
