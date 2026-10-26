import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

extension L10nContextExt on BuildContext {
  AppLocalizations get i18n => AppLocalizations.of(this)!;
}
