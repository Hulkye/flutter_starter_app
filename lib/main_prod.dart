import 'package:flutter/widgets.dart';

import 'app/application.dart';
import 'core/config/env_config.dart';
import 'core/config/deep_link_config_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deepLinkConfig = await tryLoadDeepLinkConfig(environment: 'prod');
  await Application.run(
    envConfig: EnvConfig(
      envTag: EnvTag.prod,
      baseUrl: 'https://api.example.com',
      apiPathPrefix: '/api',
      privacyPolicyUrl: 'https://flutter.dev',
      userAgreementUrl: 'https://flutter.dev',
      deepLinkConfig: deepLinkConfig,
    ),
  );
}
