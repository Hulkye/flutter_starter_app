import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/presentation/presentation.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends BasePage<ProfileViewModel> {
  const ProfilePage({super.key});

  // ── VM 接入 ──

  @override
  ProfileViewModel notifier(WidgetRef ref) =>
      ref.read(profileViewModelProvider.notifier);

  @override
  BaseState watchState(WidgetRef ref) => ref.watch(profileViewModelProvider);

  // ── AppBar ──

  @override
  PreferredSizeWidget? appBar(
    BuildContext context,
    WidgetRef ref,
    ProfileViewModel vm,
  ) {
    return AppBar(title: Text(context.i18n.profileTitle));
  }

  // ── 页面 ──

  @override
  Widget page(BuildContext context, WidgetRef ref, ProfileViewModel vm) {
    final appColor = context.appColor;

    return Center(
      child: Text(
        context.i18n.profileTitle,
        style: TextStyle(color: appColor.textPrimary),
      ),
    );
  }
}
