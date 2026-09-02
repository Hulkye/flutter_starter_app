import 'package:flutter/widgets.dart';

import 'app/application.dart';
import 'core/config/env_config.dart';
import 'core/config/deep_link_config_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deepLinkConfig = await tryLoadDeepLinkConfig(environment: 'dev');
  await Application.run(
    envConfig: EnvConfig(
      envTag: EnvTag.dev,
      baseUrl: 'https://dev.example.com',
      apiPathPrefix: '/api',
      proxyEnable: false,
      caughtAddress: '127.0.0.1:8888',
      privacyPolicyUrl: 'https://flutter.dev',
      userAgreementUrl: 'https://flutter.dev',
      deepLinkConfig: deepLinkConfig,
    ),
  );
}
