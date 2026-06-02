import '../data/res_data.dart';

// const String _suffix = '.webp';

class AppAsset extends AssetData {
  final String logo;
  final String emptyState;
  final String iconFillSuccess;
  final String iconFillError;

  AppAsset({
    this.logo = 'assets/images/logo.png',
    this.emptyState = 'assets/images/empty_state.png',
    this.iconFillSuccess = 'assets/images/icon_fill_success.svg',
    this.iconFillError = 'assets/images/icon_fill_error.svg',
  });
}
