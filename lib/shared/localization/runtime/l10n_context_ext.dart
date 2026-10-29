import 'package:flutter/widgets.dart';

import '../generated/app_localizations.dart';

extension L10nContextExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
