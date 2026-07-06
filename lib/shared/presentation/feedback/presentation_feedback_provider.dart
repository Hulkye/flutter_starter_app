import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/toast/toast.dart';
import 'presentation_feedback_service.dart';

/// Presentation 反馈服务 Provider。
final presentationFeedbackProvider = Provider<PresentationFeedbackService>((
  ref,
) {
  return PresentationFeedbackService(
    showLoadingHandler: BaseLoading.show,
    hideLoadingHandler: BaseLoading.close,
    showHintHandler: BaseToast.show,
  );
});
