import 'package:flutter/material.dart';

import '../../core/l10n/l10n_context_ext.dart';
import '../../core/theme/theme_context_ext.dart';
import '../../core/util/screen_util.dart';
import '../../shared/widgets/image_view/image_view.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColor.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageView(assetPath: context.appAsset.logo, width: 160.w),
                SizedBox(height: 20.w),
                Text(
                  context.i18n.appTitle,
                  style: TextStyle(
                    color: context.appColor.fontPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 36.w),
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4.w,
                    color: context.appColor.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
