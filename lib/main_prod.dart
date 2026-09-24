import 'app/application.dart';
import 'core/config/env_config.dart';

Future<void> main() async {
  await Application.run(
    envConfig: EnvConfig(
      envTag: EnvTag.prod,
      baseUrl: 'https://api.example.com',
      apiPathPrefix: '/api',
      privacyPolicyUrl: 'https://flutter.dev',
      userAgreementUrl: 'https://flutter.dev',
    ),
  );
}
