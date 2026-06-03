import 'package:flutter_starter_app/header.dart';

class TextMenuPanel extends StatelessWidget {
  final List<Widget> items;

  final double? minWidth;

  const TextMenuPanel({required this.items, this.minWidth, super.key});

  @override
  Widget build(BuildContext context) {
    Widget child = _createMenusList(context);
    child = _createMenuWrap(context, child);
    return child;
  }

  Widget _createMenuWrap(BuildContext context, Widget menuWidget) {
    Widget child = Container(
      padding: EdgeInsets.symmetric(vertical: 6.w, horizontal: 18.w),
      constraints: BoxConstraints(minWidth: minWidth ?? 142.w, maxWidth: 311.w),
      decoration: BoxDecoration(
        color: context.appColor.compBackgroundPrimary,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: menuWidget,
    );
    child = IntrinsicWidth(child: child);
    return child;
  }

  Widget _createMenusList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildMenus(context),
    );
  }

  List<Widget> _buildMenus(BuildContext context) {
    List<Widget> menuChildren = [];
    for (var i = 0; i < items.length; i++) {
      menuChildren.add(items[i]);
      // if (i != items.length - 1) {
      //   menuChildren.add(_divider(context));
      // }
    }
    return menuChildren;
  }
}

class TextMenuItem extends StatelessWidget {
  final String label;

  final String? icon;

  final AlignmentGeometry alignment;

  final bool isSelected;

  final VoidCallback? onTap;

  const TextMenuItem({
    required this.label,
    this.icon,
    this.alignment = Alignment.centerLeft,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  Widget _createText(BuildContext context) {
    final txtColor = isSelected
        ? context.appColor.brand
        : context.appColor.fontPrimary;
    return Text(
      label,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        height: 20.sp / 17.sp,
        color: txtColor,
      ),
      maxLines: 1,
    );
  }

  Widget _createIcon(BuildContext context) {
    if (icon == null) {
      return Container();
    }
    Widget child = ImageView(assetPath: icon, width: 24.w, height: 24.w);
    child = Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: child,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.w),
      constraints: BoxConstraints(minHeight: 40.w),
      alignment: alignment,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [_createIcon(context), _createText(context)],
      ),
    );

    child = GestureDetector(onTap: onTap, child: child);

    return child;
  }
}
