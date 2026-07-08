import 'dart:convert';
import 'dart:io';

const _defaultExcludedDirectories = {
  '.dart_tool',
  '.git',
  '.idea',
  '.vscode',
  'build',
  'ephemeral',
  '.claude',
  '.codex',
  '.cursor',
};

const _generatedL10nDirectory = 'lib/core/l10n/gen';
const _vscodeLaunchPath = '.vscode/launch.json';

const _packageImportDirectories = {'docs', 'lib', 'script', 'test'};

const _packageImportFiles = {'README.md'};

const _textFileExtensions = {
  '.arb',
  '.dart',
  '.gradle',
  '.html',
  '.json',
  '.kt',
  '.kts',
  '.md',
  '.pbxproj',
  '.plist',
  '.properties',
  '.swift',
  '.txt',
  '.xml',
  '.yaml',
  '.yml',
  '.xcconfig',
};

void main(List<String> args) {
  try {
    final options = _Options.parse(args);
    if (options.showHelp) {
      _printHelp();
      return;
    }

    _validateOptions(options);

    final root = Directory.current;
    final pubspec = File(_path(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw const _RenameException(
        'pubspec.yaml was not found. Run this script from project root.',
        66,
      );
    }

    final pubspecContent = pubspec.readAsStringSync();
    final oldName = options.oldName ?? _readPubspecName(pubspecContent);
    if (oldName == null || oldName.isEmpty) {
      throw const _RenameException(
        'Unable to read current project name from pubspec.yaml.',
        65,
      );
    }
    if (!_isValidDartPackageName(oldName)) {
      throw _RenameException(
        'Invalid current project name "$oldName" in pubspec.yaml.',
        65,
      );
    }

    final report = _RenameReport();
    final newName = options.projectName!;
    final packageId = options.packageId!;
    final appName = options.appName!;
    final enAppName = options.enAppName!;

    _updatePubspecName(root, newName, options, report);
    _updatePackageImports(root, oldName, newName, options, report);
    _updateAndroid(root, packageId, appName, options, report);
    _updateIos(root, packageId, appName, newName, options, report);
    _updateArbAppTitle(
      root,
      'lib/core/l10n/arb/app_zh.arb',
      appName,
      options,
      report,
    );
    _updateArbAppTitle(
      root,
      'lib/core/l10n/arb/app_en.arb',
      enAppName,
      options,
      report,
    );
    _updateVsCodeLaunch(root, oldName, newName, enAppName, options, report);

    report.addNotice(
      'Generated localization files under $_generatedL10nDirectory were not edited. Run ./script/gen_l10n.sh after renaming.',
    );
    report.print(dryRun: options.dryRun);
  } on _RenameException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.exitCode;
  }
}

void _validateOptions(_Options options) {
  final newName = options.projectName;
  if (newName == null) {
    throw const _RenameException('Missing project name.', 64);
  }
  if (!_isValidDartPackageName(newName)) {
    throw _RenameException(
      'Invalid project name "$newName". Use lowercase snake_case, e.g. my_app.',
      64,
    );
  }

  final packageId = options.packageId;
  if (packageId == null) {
    throw const _RenameException('Missing required option --package-id.', 64);
  }
  if (!_isValidPackageId(packageId)) {
    throw _RenameException(
      'Invalid package id "$packageId". Use dot-separated lowercase identifiers, e.g. com.example.my_app.',
      64,
    );
  }

  _validateDisplayName(options.appName, '--app-name');
  _validateDisplayName(options.enAppName, '--en-app-name');
}

void _validateDisplayName(String? value, String optionName) {
  if (value == null) {
    throw _RenameException('Missing required option $optionName.', 64);
  }
  if (value.trim().isEmpty || value.contains(RegExp(r'[\r\n]'))) {
    throw _RenameException('Invalid value for $optionName.', 64);
  }
}

void _updatePubspecName(
  Directory root,
  String newName,
  _Options options,
  _RenameReport report,
) {
  _updateFile(
    root,
    'pubspec.yaml',
    options,
    report,
    (content) => _replaceFirstMatch(
      content,
      RegExp(r'^name:\s*[a-zA-Z0-9_]+\s*$', multiLine: true),
      (_) => 'name: $newName',
      path: 'pubspec.yaml',
      description: 'pubspec package name',
    ),
  );
}

void _updatePackageImports(
  Directory root,
  String oldName,
  String newName,
  _Options options,
  _RenameReport report,
) {
  final from = 'package:$oldName/';
  final to = 'package:$newName/';
  for (final file in _walkPackageImportFiles(root)) {
    final relative = _relativePath(root, file);
    final original = file.readAsStringSync();
    final updated = original.replaceAll(from, to);
    if (updated == original) continue;

    report.addFile(relative);
    if (!options.dryRun) {
      file.writeAsStringSync(updated);
    }
  }
}

void _updateAndroid(
  Directory root,
  String packageId,
  String appName,
  _Options options,
  _RenameReport report,
) {
  _updateFile(root, 'android/app/build.gradle.kts', options, report, (content) {
    var updated = _replaceFirstMatch(
      content,
      RegExp(r'namespace\s*=\s*"[^"]+"'),
      (_) => 'namespace = "$packageId"',
      path: 'android/app/build.gradle.kts',
      description: 'Android namespace',
    );
    updated = _replaceFirstMatch(
      updated,
      RegExp(r'applicationId\s*=\s*"[^"]+"'),
      (_) => 'applicationId = "$packageId"',
      path: 'android/app/build.gradle.kts',
      description: 'Android applicationId',
    );
    return updated;
  });

  _updateFile(
    root,
    'android/app/src/main/AndroidManifest.xml',
    options,
    report,
    (content) => _replaceFirstMatch(
      content,
      RegExp(r'android:label="[^"]*"'),
      (_) => 'android:label="${_escapeXmlAttribute(appName)}"',
      path: 'android/app/src/main/AndroidManifest.xml',
      description: 'Android app label',
    ),
  );

  _updateAndroidMainActivity(root, packageId, options, report);
}

void _updateAndroidMainActivity(
  Directory root,
  String packageId,
  _Options options,
  _RenameReport report,
) {
  final sourceRoots = [
    'android/app/src/main/kotlin',
    'android/app/src/main/java',
  ];
  File? activity;
  String? sourceRoot;
  for (final candidateRoot in sourceRoots) {
    activity = _findMainActivity(Directory(_path(root, candidateRoot)));
    if (activity != null) {
      sourceRoot = candidateRoot;
      break;
    }
  }
  if (activity == null || sourceRoot == null) {
    report.addNotice(
      'Android MainActivity was not found; package directory migration was skipped.',
    );
    return;
  }

  final sourceRelative = _relativePath(root, activity);
  final extension = sourceRelative.endsWith('.java') ? '.java' : '.kt';
  final targetRelative =
      '$sourceRoot/${packageId.replaceAll('.', '/')}/MainActivity$extension';
  final original = activity.readAsStringSync();
  final updated = _replaceFirstMatch(
    original,
    RegExp(r'^package\s+[A-Za-z_][A-Za-z0-9_.]*;?', multiLine: true),
    (_) => extension == '.java' ? 'package $packageId;' : 'package $packageId',
    path: sourceRelative,
    description: 'Android MainActivity package declaration',
  );

  if (sourceRelative == targetRelative) {
    if (updated == original) return;
    report.addFile(sourceRelative);
    if (!options.dryRun) {
      activity.writeAsStringSync(updated);
    }
    return;
  }

  final target = File(_path(root, targetRelative));
  if (target.existsSync()) {
    throw _RenameException(
      'Refusing to overwrite existing Android MainActivity at $targetRelative.',
      73,
    );
  }

  report.addMove(sourceRelative, targetRelative);
  if (options.dryRun) return;

  target.parent.createSync(recursive: true);
  target.writeAsStringSync(updated);
  activity.deleteSync();
  _deleteEmptyParentDirectories(
    activity.parent,
    Directory(_path(root, sourceRoot)),
  );
}

File? _findMainActivity(Directory sourceRoot) {
  if (!sourceRoot.existsSync()) return null;
  final matches = sourceRoot
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) {
        final name = file.path.split(Platform.pathSeparator).last;
        return name == 'MainActivity.kt' || name == 'MainActivity.java';
      })
      .toList();
  if (matches.length > 1) {
    throw _RenameException(
      'Found multiple Android MainActivity files: ${matches.map((file) => file.path).join(', ')}.',
      65,
    );
  }
  return matches.firstOrNull;
}

void _updateIos(
  Directory root,
  String packageId,
  String appName,
  String newName,
  _Options options,
  _RenameReport report,
) {
  _updateFile(root, 'ios/Runner.xcodeproj/project.pbxproj', options, report, (
    content,
  ) {
    var count = 0;
    final updated = content.replaceAllMapped(
      RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);'),
      (match) {
        count++;
        final current = match.group(1)!.trim();
        final bundleId = current.endsWith('.RunnerTests')
            ? '$packageId.RunnerTests'
            : packageId;
        return 'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;';
      },
    );
    if (count == 0) {
      throw const _RenameException(
        'Unable to update PRODUCT_BUNDLE_IDENTIFIER in ios/Runner.xcodeproj/project.pbxproj.',
        65,
      );
    }
    return updated;
  });

  _updateFile(root, 'ios/Runner/Info.plist', options, report, (content) {
    var updated = _replacePlistStringValue(
      content,
      'CFBundleDisplayName',
      appName,
      'ios/Runner/Info.plist',
    );
    updated = _replacePlistStringValue(
      updated,
      'CFBundleName',
      newName,
      'ios/Runner/Info.plist',
    );
    return updated;
  });
}

void _updateArbAppTitle(
  Directory root,
  String relativePath,
  String title,
  _Options options,
  _RenameReport report,
) {
  _updateFile(root, relativePath, options, report, (content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw _RenameException('$relativePath is not a JSON object.', 65);
    }
    final data = Map<String, dynamic>.from(decoded);
    if (!data.containsKey('appTitle')) {
      throw _RenameException('Missing appTitle in $relativePath.', 65);
    }
    data['appTitle'] = title;
    return '${const JsonEncoder.withIndent('  ').convert(data)}\n';
  });
}

void _updateVsCodeLaunch(
  Directory root,
  String oldName,
  String newName,
  String enAppName,
  _Options options,
  _RenameReport report,
) {
  final file = File(_path(root, _vscodeLaunchPath));
  if (!file.existsSync()) {
    report.addNotice(
      '$_vscodeLaunchPath was not found; VS Code launch configuration names were skipped.',
    );
    return;
  }

  _updateFile(root, _vscodeLaunchPath, options, report, (content) {
    var matchedNames = 0;
    var renamedNames = 0;
    final updated = content.replaceAllMapped(
      RegExp(r'("name"\s*:\s*")([^"]*)(")'),
      (match) {
        matchedNames++;
        final name = match.group(2)!;
        final renamed = _renameLaunchName(name, oldName, newName, enAppName);
        if (renamed != name) renamedNames++;
        return '${match.group(1)}$renamed${match.group(3)}';
      },
    );
    if (matchedNames == 0) {
      report.addNotice(
        '$_vscodeLaunchPath has no launch configuration name fields.',
      );
    } else if (renamedNames == 0) {
      report.addNotice(
        '$_vscodeLaunchPath has no launch configuration names matching the old project values.',
      );
    }
    return updated;
  });
}

String _renameLaunchName(
  String name,
  String oldName,
  String newName,
  String enAppName,
) {
  return name
      .replaceAll(_titleFromPackageName(oldName), enAppName)
      .replaceAll('Flutter Starter', enAppName)
      .replaceAll(oldName, newName);
}

void _updateFile(
  Directory root,
  String relativePath,
  _Options options,
  _RenameReport report,
  String Function(String content) update,
) {
  final file = File(_path(root, relativePath));
  if (!file.existsSync()) {
    report.addNotice('$relativePath was not found; skipped.');
    return;
  }

  final original = file.readAsStringSync();
  final updated = update(original);
  if (updated == original) return;

  report.addFile(relativePath);
  if (!options.dryRun) {
    file.writeAsStringSync(updated);
  }
}

String _replaceFirstMatch(
  String content,
  RegExp pattern,
  String Function(Match match) replacement, {
  required String path,
  required String description,
}) {
  final match = pattern.firstMatch(content);
  if (match == null) {
    throw _RenameException('Unable to update $description in $path.', 65);
  }
  return content.replaceRange(match.start, match.end, replacement(match));
}

String _replacePlistStringValue(
  String content,
  String key,
  String value,
  String path,
) {
  return _replaceFirstMatch(
    content,
    RegExp(
      '(<key>${RegExp.escape(key)}</key>\\s*<string>)(.*?)(</string>)',
      dotAll: true,
    ),
    (match) => '${match.group(1)}${_escapeXmlText(value)}${match.group(3)}',
    path: path,
    description: key,
  );
}

Iterable<File> _walkTextFiles(Directory root) sync* {
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is Directory) continue;
    if (entity is! File) continue;
    final relative = _relativePath(root, entity);
    if (_isExcluded(relative)) continue;
    if (_isGeneratedL10nFile(relative)) continue;
    if (relative.endsWith('Generated.xcconfig')) continue;
    if (!_isTextFile(relative)) continue;
    yield entity;
  }
}

Iterable<File> _walkPackageImportFiles(Directory root) sync* {
  for (final file in _walkTextFiles(root)) {
    final relative = _relativePath(root, file);
    if (_packageImportFiles.contains(relative) ||
        _packageImportDirectories.any(
          (directory) =>
              relative == directory || relative.startsWith('$directory/'),
        )) {
      yield file;
    }
  }
}

bool _isExcluded(String relativePath) {
  final parts = relativePath.split('/');
  return parts.any(_defaultExcludedDirectories.contains);
}

bool _isGeneratedL10nFile(String relativePath) {
  return relativePath == _generatedL10nDirectory ||
      relativePath.startsWith('$_generatedL10nDirectory/');
}

bool _isTextFile(String path) {
  final lower = path.toLowerCase();
  return _textFileExtensions.any(lower.endsWith);
}

String _path(Directory root, String relativePath) {
  return '${root.path}/${relativePath.replaceAll('/', Platform.pathSeparator)}';
}

String _relativePath(Directory root, FileSystemEntity entity) {
  final prefix = '${root.path}${Platform.pathSeparator}';
  final path = entity.path.startsWith(prefix)
      ? entity.path.substring(prefix.length)
      : entity.path;
  return path.replaceAll(Platform.pathSeparator, '/');
}

String? _readPubspecName(String content) {
  final match = RegExp(
    r'^name:\s*([a-zA-Z0-9_]+)\s*$',
    multiLine: true,
  ).firstMatch(content);
  return match?.group(1);
}

bool _isValidDartPackageName(String name) {
  return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name) &&
      !name.endsWith('_') &&
      !name.contains('__');
}

bool _isValidPackageId(String packageId) {
  return RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(packageId);
}

String _titleFromPackageName(String packageName) {
  return packageName
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _escapeXmlAttribute(String value) {
  return _escapeXmlText(
    value,
  ).replaceAll('"', '&quot;').replaceAll("'", '&apos;');
}

String _escapeXmlText(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

void _deleteEmptyParentDirectories(Directory directory, Directory stopAt) {
  var current = directory;
  while (current.path != stopAt.path && current.existsSync()) {
    if (current.listSync().isNotEmpty) return;
    final parent = current.parent;
    current.deleteSync();
    current = parent;
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run script/rename_project.dart <new_project_name> --package-id <id> --app-name <name> --en-app-name <name> [options]',
  );
}

void _printHelp() {
  _printUsage();
  stdout.writeln('''

Renames the Flutter template package name, platform package identifiers, app display names, package imports, ARB app titles, and VS Code launch configuration names when present.

Arguments:
  <new_project_name>        New Dart package name, e.g. my_app.

Required options:
  --package-id <id>         Android applicationId/namespace and iOS bundle id, e.g. com.example.myapp.
  --app-name <name>         Default display name for Android, iOS, and zh ARB, e.g. "我的APP".
  --en-app-name <name>      English display name for en ARB and VS Code launch names, e.g. "My App".

Other options:
  --old-name <name>         Override the current package name read from pubspec.yaml.
  --dry-run                 Print files that would change without writing them.
  -h, --help                Show this help message.

Examples:
  dart run script/rename_project.dart my_app --package-id com.example.myapp --app-name "我的APP" --en-app-name "My App"
  dart run script/rename_project.dart my_app --package-id com.example.myapp --app-name "我的APP" --en-app-name "My App" --dry-run
''');
}

final class _Move {
  const _Move(this.from, this.to);

  final String from;
  final String to;
}

final class _RenameException implements Exception {
  const _RenameException(this.message, this.exitCode);

  final String message;
  final int exitCode;
}

final class _RenameReport {
  final _files = <String>{};
  final _moves = <_Move>[];
  final _notices = <String>[];

  void addFile(String path) {
    _files.add(path);
  }

  void addMove(String from, String to) {
    _moves.add(_Move(from, to));
  }

  void addNotice(String notice) {
    _notices.add(notice);
  }

  void print({required bool dryRun}) {
    final action = dryRun ? 'Would update' : 'Updated';
    if (_files.isEmpty && _moves.isEmpty) {
      stdout.writeln('No files changed.');
    } else {
      final count = _files.length + _moves.length;
      stdout.writeln('$action $count item(s):');
      for (final path in _files) {
        stdout.writeln('  - $path');
      }
      for (final move in _moves) {
        stdout.writeln('  - ${move.from} -> ${move.to}');
      }
    }

    if (_notices.isNotEmpty) {
      stdout.writeln('\nNotes:');
      for (final notice in _notices) {
        stdout.writeln('  - $notice');
      }
    }

    if (!dryRun) {
      stdout.writeln('\nNext steps:');
      stdout.writeln('  1. flutter pub get');
      stdout.writeln('  2. ./script/gen_l10n.sh');
      stdout.writeln('  3. dart format lib test script');
      stdout.writeln('  4. flutter analyze');
    }
  }
}

final class _Options {
  const _Options({
    required this.projectName,
    required this.oldName,
    required this.packageId,
    required this.appName,
    required this.enAppName,
    required this.dryRun,
    required this.showHelp,
  });

  final String? projectName;
  final String? oldName;
  final String? packageId;
  final String? appName;
  final String? enAppName;
  final bool dryRun;
  final bool showHelp;

  static _Options parse(List<String> args) {
    String? projectName;
    String? oldName;
    String? packageId;
    String? appName;
    String? enAppName;
    var dryRun = false;
    var showHelp = false;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '-h':
        case '--help':
          showHelp = true;
        case '--dry-run':
          dryRun = true;
        case '--old-name':
          oldName = _readOptionValue(args, ++i, '--old-name');
        case '--package-id':
          packageId = _readOptionValue(args, ++i, '--package-id');
        case '--app-name':
          appName = _readOptionValue(args, ++i, '--app-name');
        case '--en-app-name':
          enAppName = _readOptionValue(args, ++i, '--en-app-name');
        default:
          if (arg.startsWith('-')) {
            stderr.writeln('Unknown option: $arg');
            exit(64);
          }
          if (projectName != null) {
            stderr.writeln('Unexpected argument: $arg');
            exit(64);
          }
          projectName = arg;
      }
    }

    return _Options(
      projectName: projectName,
      oldName: oldName,
      packageId: packageId,
      appName: appName,
      enAppName: enAppName,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}

String _readOptionValue(List<String> args, int index, String optionName) {
  if (index >= args.length) {
    stderr.writeln('Missing value for $optionName.');
    exit(64);
  }
  return args[index];
}

extension _NullableFirst<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
