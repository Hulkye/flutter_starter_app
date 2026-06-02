import 'app/application.dart';
import 'app/env.dart';

Future<void> main() async {
  await Application.run(
    envConfig: const EnvConfig(
      envTag: EnvTag.sit,
      baseUrl: 'https://sit.example.com',
      apiPathPrefix: '/api',
      privacyPolicyUrl: 'https://example.com/privacy',
      userAgreementUrl: 'https://example.com/agreement',
    ),
  );
}
