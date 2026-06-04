import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/presentation/presentation.dart';

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  // ── AppBar ──

  @override
  PreferredSizeWidget? appBar(PageScope scope) {
    return AppBar(title: Text(scope.context.i18n.profileTitle));
  }

  // ── 页面 ──

  @override
  Widget page(PageScope scope) {
    final context = scope.context;
    final appColor = context.appColor;

    return Center(
      child: Text(
        context.i18n.profileTitle,
        style: TextStyle(color: appColor.fontPrimary),
      ),
    );
  }
}
