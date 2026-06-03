import '../../../header.dart';

typedef CommonConfirmSheetContentBuilder =
    Widget Function(BuildContext context);

Future<void> showCommonConfirmSheet(
  BuildContext context, {
  String? title,
  String? content,
  CommonConfirmSheetContentBuilder? contentBuilder,
  EdgeInsets? contentPadding,
  TextAlign? contentTextAlign,
  String? cancelLabel,
  String? confirmLabel,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  bool enableDrag = true,
  bool isMaskClickCancel = true,
}) {
  return showCommonSheet(
    context,
    CommonConfirmSheet(
      title: title,
      content: content,
      contentBuilder: contentBuilder,
      contentPadding: contentPadding,
      contentTextAlign: contentTextAlign,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      onCancel: onCancel,
      onConfirm: onConfirm,
    ),
    enableDrag: enableDrag,
    isMaskClickCancel: isMaskClickCancel,
  );
}

class CommonConfirmSheet extends StatelessWidget {
  final String? title;
  final String? content;
  final CommonConfirmSheetContentBuilder? contentBuilder;
  final EdgeInsets? contentPadding;
  final TextAlign? contentTextAlign;
  final String? cancelLabel;
  final String? confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const CommonConfirmSheet({
    this.title,
    this.content,
    this.contentBuilder,
    this.contentPadding,
    this.contentTextAlign,
    this.cancelLabel,
    this.confirmLabel,
    this.onCancel,
    this.onConfirm,
    super.key,
  });

  void _close(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildTitle(BuildContext context) {
    final t = title;
    if (t == null || t.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      t,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: context.appColor.fontPrimary,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (contentBuilder != null) {
      return contentBuilder!.call(context);
    }
    final c = content;
    if (c == null || c.isEmpty) {
      return const SizedBox.shrink();
    }
    Widget child = Text(
      c,
      textAlign: contentTextAlign ?? TextAlign.start,
      style: TextStyle(
        fontSize: 17.sp,
        height: 20.sp / 17.sp,
        color: context.appColor.fontSecondary,
      ),
    );
    if (contentPadding != null) {
      child = Padding(padding: contentPadding!, child: child);
    }
    return child;
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SheetCancelBtn(
            label: cancelLabel ?? context.i18n.cancel,
            onPressed: () {
              _close(context);
              onCancel?.call();
            },
          ),
        ),
        SizedBox(width: 17.w),
        Expanded(
          child: SheetConfirmBtn(
            label: confirmLabel ?? context.i18n.confirm,
            onPressed: () {
              _close(context);
              onConfirm?.call();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = title?.isNotEmpty == true;
    final hasContent = contentBuilder != null || content?.isNotEmpty == true;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 23.w),
          if (hasTitle) ...[
            _buildTitle(context),
            SizedBox(height: hasContent ? 17.w : 0),
          ],
          if (hasContent) ...[_buildContent(context), SizedBox(height: 29.w)],
          _buildActions(context),
          SizedBox(height: 17.w),
        ],
      ),
    );
  }
}
