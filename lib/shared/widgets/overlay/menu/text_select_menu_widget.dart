import 'package:flutter_starter_app/header.dart';
import 'package:flutter_starter_app/shared/widgets/overlay/context_popup_wrap.dart';
import 'package:flutter_starter_app/shared/widgets/overlay/menu/text_menu_panel.dart';

typedef TextSelectMenuTriggerBuilder = Widget Function(BuildContext context);

class TextSelectMenuWidget extends StatelessWidget {
  final List<TextMenuItem> menuItems;
  final TextSelectMenuTriggerBuilder triggerBuilder;
  final Offset? offset;

  const TextSelectMenuWidget({
    required this.menuItems,
    required this.triggerBuilder,
    this.offset,
    super.key,
  });

  List<TextMenuItem> _wrapMenuItemsWithCancel(
    Future<void> Function() cancelFunc,
  ) {
    return menuItems
        .map((item) {
          return TextMenuItem(
            label: item.label,
            icon: item.icon,
            alignment: item.alignment,
            isSelected: item.isSelected,
            onTap: () async {
              await cancelFunc();
              item.onTap?.call();
            },
          );
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = triggerBuilder.call(context);
    child = ContextPopupWrap(
      maskBgColor: context.appColor.overlayBackground,
      prePopupDirection: PrePopupDirection.bottomRight,
      offset: offset ?? Offset(0, 12.w),
      child: child,
      popupContent: (cancelFunc) {
        return TextMenuPanel(
          items: _wrapMenuItemsWithCancel(cancelFunc),
          minWidth: 142.w,
        );
      },
    );
    return child;
  }
}
