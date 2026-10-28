import 'package:flutter/widgets.dart';

import '../generated/app_localizations.dart';

extension L10nContextExt on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;
}
