import '../../header.dart';
import 'app_bootstrap_coordinator.dart';

class AppSessionCoordinator {
  AppSessionCoordinator({required this.read, required this.context});

  final AppReader read;
  final BuildContext context;

  void start() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }
}
