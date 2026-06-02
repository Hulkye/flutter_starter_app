import 'app/application.dart';

import 'app/env.dart';

Future<void> main() async {
  await Application.run(
    envConfig: const EnvConfig(
      envTag: EnvTag.prod,
      baseUrl: 'https://api.example.com',
      apiPathPrefix: '/api',
      privacyPolicyUrl: '',
      userAgreementUrl: '',
    ),
  );
}
