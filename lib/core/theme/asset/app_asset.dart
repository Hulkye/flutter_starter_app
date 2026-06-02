import '../data/res_data.dart';

// const String _suffix = '.webp';

class AppAsset extends AssetData {
  final String logo;
  final String emptyState;

  AppAsset({
    this.logo = 'assets/images/logo.png',
    this.emptyState = 'assets/images/empty_state.png',
  });
}
