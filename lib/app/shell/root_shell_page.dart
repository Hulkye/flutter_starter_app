import 'package:flutter_starter_app/header.dart';

class RootShellPage extends StatelessWidget {
  const RootShellPage({
    required this.shellNavigator,
    required this.tabs,
    super.key,
  });

  final AppShellNavigator shellNavigator;
  final List<AppTabEntry> tabs;

  static double get _tabIconSize => 24.w;
  static double get _tabFontSize => 12.sp;

  BottomNavigationBarItem _createBottomBarItem(
    BuildContext context,
    AppTabEntry tab,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: ImageView(
          assetPath: tab.icon(context),
          width: _tabIconSize,
          height: _tabIconSize,
          color: context.appColor.fontSecondary,
        ),
      ),
      activeIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w),
        child: ImageView(
          assetPath: tab.selectedIcon(context),
          width: _tabIconSize,
          height: _tabIconSize,
        ),
      ),
      label: tab.label(context),
    );
  }

  List<BottomNavigationBarItem> _createBottomBarItems(BuildContext context) {
    return [for (final tab in tabs) _createBottomBarItem(context, tab)];
  }

  Widget _createBottomNavigationBar(BuildContext context) {
    Widget child = BottomNavigationBar(
      backgroundColor: context.appColor.backgroundPrimary,
      elevation: 0,
      enableFeedback: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: shellNavigator.currentIndex,
      selectedItemColor: context.appColor.brand,
      unselectedItemColor: context.appColor.fontSecondary,
      selectedFontSize: _tabFontSize,
      unselectedFontSize: _tabFontSize,
      items: _createBottomBarItems(context),
      onTap: (index) {
        shellNavigator.goBranch(
          index,
          initialLocation: index == shellNavigator.currentIndex,
        );
      },
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColor.backgroundPrimary,
      body: shellNavigator.child,
      bottomNavigationBar: tabs.length < 2
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: context.appColor.compDivider,
                ),
                _createBottomNavigationBar(context),
              ],
            ),
    );
  }
}
