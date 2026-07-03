import '../../core/feature/app_feature.dart';
import '../../core/router/router.dart';
import 'presentation/webview_routes.dart';

export 'domain/entities/web_page_config.dart';
export 'presentation/webview_routes.dart';

final class WebViewFeature extends AppFeature {
  const WebViewFeature();

  @override
  String get name => 'webview';

  @override
  List<AppPageRoute> get routes => const [WebPageRoute(), AuthWebPageRoute()];
}
