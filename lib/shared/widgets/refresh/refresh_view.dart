import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_starter_app/shared/widgets/refresh/app_refresh_footer.dart';
import 'package:flutter_starter_app/shared/widgets/refresh/app_refresh_header.dart';
import 'package:flutter_starter_app/shared/widgets/refresh/refresh_load_controller.dart';

class RefreshView extends StatelessWidget {
  /// 控制器
  final RefreshLoadController controller;

  /// 滚动控制
  final ScrollController? scrollController;

  /// 内容
  final Widget child;

  /// 自定义头部
  final Header? header;

  /// 自定义尾部
  final Footer? footer;

  /// 刷新
  final Future<dynamic> Function()? onRefresh;

  /// 加载
  final Future<dynamic> Function()? onLoad;

  final ScrollPhysics? physics;

  const RefreshView({
    required this.controller,
    required this.child,
    this.scrollController,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.physics,
    super.key,
  });

  Header? get _header => controller.refreshValue
      ? (header ?? AppRefreshHeader.create())
      : const NotRefreshHeader();

  Footer? get _footer => controller.loadMoreValue
      ? (footer ?? AppRefreshFooter.create())
      : const NotLoadFooter();

  Widget contentWidget(BuildContext context) {
    return EasyRefresh(
      key: controller.refresh != null
          ? ValueKey("${controller.refresh?.value}")
          : null,
      controller: controller,
      scrollController: scrollController,
      header: _header,
      footer: _footer,
      onRefresh: onRefresh,
      onLoad: onLoad,
      child: child,
      scrollBehaviorBuilder: (physics) =>
          EasyRefresh.defaultScrollBehaviorBuilder(this.physics ?? physics),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.refresh != null) {
      return ValueListenableBuilder(
        valueListenable: controller.refresh!,
        builder: (_, bool value, Widget? child) {
          return contentWidget(context);
        },
      );
    }
    return contentWidget(context);
  }
}
