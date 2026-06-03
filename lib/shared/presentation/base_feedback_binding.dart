import '../widgets/toast/toast.dart';
import 'base_vm.dart';

void bindBaseVmFeedbackHandlers() {
  BaseVM.showLoadingHandler = BaseLoading.show;
  BaseVM.hideLoadingHandler = BaseLoading.close;
  BaseVM.showHintHandler = BaseToast.show;
}
