import 'dart:convert';
import 'dart:io';

const _configPath = 'config/deep_links.json';
const _androidOutputPath = 'android/deep_links.properties';
const _iosOutputPath = 'ios/Flutter/DeepLinks.generated.xcconfig';

void main(List<String> args) {
  final options = _Options.parse(args);
  if (options.help) {
    _printHelp();
    return;
  }

  final root = Directory.current;
  final configFile = File(_path(root, _configPath));
  if (!configFile.existsSync()) {
    _disableNativeConfiguration(root, options);
    return;
  }

  final environments = _readConfig(root);
  final environment = environments[options.environment];
  if (environment == null) {
    stderr.writeln('Unknown environment: ${options.environment}');
    exitCode = 64;
    return;
  }
  _validate(environment, options.environment);
  if (!options.check && !options.dryRun) {
    _setNativeConfigurationEnabled(root, environment);
  }

  final outputs = <String, String>{
    _androidOutputPath: _androidContent(environment),
    _iosOutputPath: _iosContent(environment),
  };
  final mismatches = <String>[];
  for (final entry in outputs.entries) {
    final file = File(_path(root, entry.key));
    if (!file.existsSync() || file.readAsStringSync() != entry.value) {
      mismatches.add(entry.key);
    }
    if (!options.check && !options.dryRun) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
  }

  if (options.check) {
    if (mismatches.isNotEmpty) {
      stderr.writeln('Generated deep link files are out of date:');
      for (final path in mismatches) {
        stderr.writeln('  - $path');
      }
      exitCode = 1;
      return;
    }
    stdout.writeln(
      'Deep link files are up to date for ${options.environment}.',
    );
    return;
  }

  if (options.dryRun) {
    stdout.writeln('Would generate for ${options.environment}:');
    for (final path in outputs.keys) {
      stdout.writeln('  - $path');
    }
    return;
  }
  stdout.writeln('Generated deep link files for ${options.environment}.');
}

void _disableNativeConfiguration(Directory root, _Options options) {
  final generatedPaths = [_androidOutputPath, _iosOutputPath];
  if (!options.check && !options.dryRun) {
    for (final relativePath in generatedPaths) {
      final file = File(_path(root, relativePath));
      if (file.existsSync()) file.deleteSync();
    }
    _setNativeConfigurationDisabled(root);
  }

  if (options.check) {
    final hasGeneratedFiles = generatedPaths.any(
      (relativePath) => File(_path(root, relativePath)).existsSync(),
    );
    if (hasGeneratedFiles) {
      stderr.writeln(
        'Deep link generated files must be removed when configuration is missing.',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('Deep Link is disabled; native configuration is clean.');
    return;
  }

  if (options.dryRun) {
    stdout.writeln('Would disable Deep Link native configuration.');
    return;
  }
  stdout.writeln('Deep Link is disabled; native configuration was cleaned.');
}

void _setNativeConfigurationEnabled(
  Directory root,
  Map<String, dynamic> config,
) {
  _syncMarkedBlock(
    root,
    'android/app/src/main/AndroidManifest.xml',
    _androidManifestBlock(config),
    before: '</activity>',
  );
  _syncMarkedBlock(
    root,
    'ios/Runner/Info.plist',
    _iosInfoPlistBlock(),
    before: '<key>LSRequiresIPhoneOS</key>',
  );
  _syncMarkedBlock(
    root,
    'ios/Runner/Runner.entitlements',
    _iosEntitlementsBlock(),
    before: '</dict>',
  );
}

void _setNativeConfigurationDisabled(Directory root) {
  _removeMarkedBlock(root, 'android/app/src/main/AndroidManifest.xml');
  _removeMarkedBlock(root, 'ios/Runner/Info.plist');
  _removeMarkedBlock(root, 'ios/Runner/Runner.entitlements');
}

void _syncMarkedBlock(
  Directory root,
  String relativePath,
  String block, {
  required String before,
}) {
  final file = File(_path(root, relativePath));
  if (!file.existsSync()) return;
  var content = _removeMarkedBlockContent(file.readAsStringSync());
  final index = content.indexOf(before);
  if (index < 0) {
    stderr.writeln('Missing insertion point in $relativePath.');
    exit(65);
  }
  content = '${content.substring(0, index)}$block${content.substring(index)}';
  file.writeAsStringSync(content);
}

String _removeMarkedBlockContent(String content) {
  return content.replaceFirst(
    RegExp(
      r'\s*<!-- DEEP_LINK_START -->.*?<!-- DEEP_LINK_END -->\s*',
      dotAll: true,
    ),
    '\n',
  );
}

void _removeMarkedBlock(Directory root, String relativePath) {
  final file = File(_path(root, relativePath));
  if (!file.existsSync()) return;
  final content = file.readAsStringSync();
  final updated = _removeMarkedBlockContent(content);
  if (updated != content) file.writeAsStringSync(updated);
}

Map<String, Map<String, dynamic>> _readConfig(Directory root) {
  final file = File(_path(root, _configPath));
  if (!file.existsSync()) {
    stderr.writeln('Missing $_configPath.');
    exit(66);
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('$_configPath must contain a JSON object.');
    exit(65);
  }
  return {
    for (final entry in decoded.entries)
      if (entry.value is Map<String, dynamic>)
        entry.key: entry.value as Map<String, dynamic>,
  };
}

void _validate(Map<String, dynamic> config, String environment) {
  final scheme = config['appScheme'];
  final host = config['appLinkHost'];
  if (scheme is! String || !RegExp(r'^[a-z][a-z0-9+.-]*$').hasMatch(scheme)) {
    stderr.writeln('Invalid appScheme for $environment.');
    exit(65);
  }
  if (host is! String || !_isHost(host)) {
    stderr.writeln('Invalid appLinkHost for $environment.');
    exit(65);
  }
}

bool _isHost(String value) {
  final uri = Uri.tryParse('https://$value');
  return uri != null && uri.host == value && uri.path == '';
}

String _androidContent(Map<String, dynamic> config) {
  return '# Generated by script/configure_links.dart. Do not edit.\n'
      'appScheme=${config['appScheme']}\n'
      'appLinkHost=${config['appLinkHost']}\n';
}

String _androidManifestBlock(Map<String, dynamic> config) {
  return '''            <!-- DEEP_LINK_START -->
            <meta-data
                android:name="flutter_deeplinking_enabled"
                android:value="false" />
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="\${appScheme}" />
            </intent-filter>
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="\${appLinkHost}" />
            </intent-filter>
            <!-- DEEP_LINK_END -->
''';
}

String _iosInfoPlistBlock() {
  return '''\t<!-- DEEP_LINK_START -->
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>\$(APP_URL_SCHEME)</string>
			</array>
		</dict>
	</array>
	<key>FlutterDeepLinkingEnabled</key>
	<false/>
	<!-- DEEP_LINK_END -->
''';
}

String _iosEntitlementsBlock() {
  return '''\t<!-- DEEP_LINK_START -->
	<key>com.apple.developer.associated-domains</key>
	<array>
		<string>applinks:\$(APP_LINK_HOST)</string>
	</array>
	<!-- DEEP_LINK_END -->
''';
}

String _iosContent(Map<String, dynamic> config) {
  return '// Generated by script/configure_links.dart. Do not edit.\n'
      'APP_URL_SCHEME = ${config['appScheme']}\n'
      'APP_LINK_HOST = ${config['appLinkHost']}\n';
}

String _path(Directory root, String relative) =>
    '${root.path}${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';

void _printHelp() {
  stdout.writeln(
    '''Usage: dart run script/configure_links.dart --env <dev|sit|prod> [options]

Options:
  --env <name>   Select the JSON environment to generate.
  --check        Fail when generated native files are out of date.
  --dry-run      Print generated file paths without writing.
  -h, --help     Show this help message.
''',
  );
}

final class _Options {
  const _Options({
    required this.environment,
    required this.check,
    required this.dryRun,
    required this.help,
  });

  final String environment;
  final bool check;
  final bool dryRun;
  final bool help;

  static _Options parse(List<String> args) {
    var environment = '';
    var check = false;
    var dryRun = false;
    var help = false;
    for (var index = 0; index < args.length; index++) {
      switch (args[index]) {
        case '--env':
          if (++index >= args.length) {
            throw const FormatException('Missing --env value.');
          }
          environment = args[index];
        case '--check':
          check = true;
        case '--dry-run':
          dryRun = true;
        case '-h':
        case '--help':
          help = true;
        default:
          throw FormatException('Unknown option: ${args[index]}');
      }
    }
    if (!help && environment.isEmpty) {
      throw const FormatException('Missing required --env option.');
    }
    return _Options(
      environment: environment,
      check: check,
      dryRun: dryRun,
      help: help,
    );
  }
}
