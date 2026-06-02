import 'package:flutter_starter_app/header.dart';

/// 弹窗卡片
class TipsCard extends StatelessWidget {
  final Widget child;

  final double? width;

  const TipsCard({required this.child, this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width ?? 182.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          color: context.appColor.overlayComponentBackground,
        ),
        child: child,
      ),
    );
  }
}

abstract class BaseTipsWidget extends StatelessWidget {
  final String tips;

  const BaseTipsWidget(this.tips, {super.key});

  String getIcon(BuildContext context);

  Widget createIcon(BuildContext context) {
    return ImageView(assetPath: getIcon(context), width: 43.w, height: 43.w);
  }

  Widget createTips(BuildContext context) {
    return Text(
      tips,
      style: TextStyle(
        fontSize: 17.sp,
        height: 22 / 17,
        color: context.appColor.fontOnPrimary,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24.w),
        createIcon(context),
        SizedBox(height: 18.w),
        createTips(context),
        SizedBox(height: 26.w),
      ],
    );
    child = TipsCard(child: child);
    return child;
  }
}

class SuccessTips extends BaseTipsWidget {
  const SuccessTips(super.tips, {super.key});

  @override
  String getIcon(BuildContext context) {
    return context.appAsset.iconFillSuccess;
  }
}

class FailTips extends BaseTipsWidget {
  const FailTips(super.tips, {super.key});

  @override
  String getIcon(BuildContext context) {
    return context.appAsset.iconFillError;
  }
}
