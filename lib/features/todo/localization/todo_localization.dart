library;

import 'package:flutter/widgets.dart';

export 'generated/todo_localizations.dart';

import 'generated/todo_localizations.dart';

extension TodoLocalizationContextExt on BuildContext {
  TodoLocalizations get todoL10n {
    final localization = TodoLocalizations.of(this);
    if (localization == null) {
      throw StateError('TodoLocalizations delegate is not registered.');
    }
    return localization;
  }
}
