import 'app/application.dart';
import 'app/env.dart';

Future<void> main() async {
  await Application.run(
    envConfig: const EnvConfig(
      envTag: EnvTag.dev,
      baseUrl: 'https://dev.example.com',
      apiPathPrefix: '/api',
      proxyEnable: false,
      caughtAddress: '127.0.0.1:8888',
      privacyPolicyUrl: 'https://example.com/privacy',
      userAgreementUrl: 'https://example.com/agreement',
    ),
  );
}
