import 'package:flutter/material.dart';
import 'package:flutter_starter_app/shared/design_system/design_system.dart';
import 'todo_asset.dart';
import 'todo_color.dart';

export 'todo_asset.dart';
export 'todo_color.dart';

final class TodoColorExtension
    extends ColorExtension<TodoColor, TodoColorExtension> {
  const TodoColorExtension({required super.colorData});

  static const light = TodoColorExtension(colorData: TodoColor.light);
  static const dark = TodoColorExtension(colorData: TodoColor.dark);

  @override
  TodoColorExtension copyWith({TodoColor? colorData}) {
    return TodoColorExtension(colorData: colorData ?? this.colorData);
  }

  @override
  TodoColorExtension lerp(covariant TodoColorExtension? other, double t) {
    if (other == null) return this;
    return TodoColorExtension(colorData: colorData.lerp(other.colorData, t));
  }
}

final class TodoAssetExtension
    extends AssetExtension<TodoAsset, TodoAssetExtension> {
  const TodoAssetExtension({required super.assetData});

  static const light = TodoAssetExtension(assetData: TodoAsset.light);
  static const dark = TodoAssetExtension(assetData: TodoAsset.dark);

  @override
  TodoAssetExtension copyWith({TodoAsset? assetData}) {
    return TodoAssetExtension(assetData: assetData ?? this.assetData);
  }

  @override
  TodoAssetExtension lerp(covariant TodoAssetExtension? other, double t) {
    return other ?? this;
  }
}

extension TodoDesignContextExt on BuildContext {
  TodoColor get todoColor {
    final extension = Theme.of(this).extension<TodoColorExtension>();
    if (extension == null) {
      throw StateError('TodoColorExtension is not registered in ThemeData.');
    }
    return extension.colorData;
  }

  TodoAsset get todoAsset {
    final extension = Theme.of(this).extension<TodoAssetExtension>();
    if (extension == null) {
      throw StateError('TodoAssetExtension is not registered in ThemeData.');
    }
    return extension.assetData;
  }
}
