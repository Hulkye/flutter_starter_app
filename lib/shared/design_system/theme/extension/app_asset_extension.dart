import 'asset_extension.dart';
import '../asset/app_asset.dart';

final class AppAssetExtension
    extends AssetExtension<AppAsset, AppAssetExtension> {
  const AppAssetExtension({required super.assetData});

  @override
  AppAssetExtension copyWith({AppAsset? assetData}) {
    return AppAssetExtension(assetData: assetData ?? this.assetData);
  }

  @override
  AppAssetExtension lerp(covariant AppAssetExtension? other, double t) {
    return other ?? this;
  }
}
