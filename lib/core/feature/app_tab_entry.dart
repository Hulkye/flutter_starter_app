import 'package:flutter/widgets.dart';
import '../router/definitions/router_definitions.dart';

abstract class AppTabEntry {
  const AppTabEntry();

  String get key;

  String label(BuildContext context);

  String icon(BuildContext context);

  String selectedIcon(BuildContext context);

  AppPageRoute get route;

  String get initialLocation => route.location;
}
