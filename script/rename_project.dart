import 'dart:io';

const _defaultExcludedDirectories = {
  '.dart_tool',
  '.git',
  '.idea',
  '.vscode',
  'build',
  'ephemeral',
  '.claude',
};

const _textFileExtensions = {
  '.arb',
  '.dart',
  '.gradle',
  '.html',
  '.json',
  '.kt',
  '.md',
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
  final options = _Options.parse(args);
  if (options.showHelp) {
    _printHelp();
    return;
  }

  final newName = options.projectName;
  if (newName == null) {
    stderr.writeln('Missing project name.');
    _printUsage();
    exitCode = 64;
    return;
  }

  if (!_isValidDartPackageName(newName)) {
    stderr.writeln(
      'Invalid project name "$newName". Use lowercase snake_case, e.g. my_app.',
    );
    exitCode = 64;
    return;
  }

  final root = Directory.current;
  final pubspec = File('${root.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln(
      'pubspec.yaml was not found. Run this script from project root.',
    );
    exitCode = 66;
    return;
  }

  final pubspecContent = pubspec.readAsStringSync();
  final oldName = options.oldName ?? _readPubspecName(pubspecContent);
  if (oldName == null || oldName.isEmpty) {
    stderr.writeln('Unable to read current project name from pubspec.yaml.');
    exitCode = 65;
    return;
  }

  if (oldName == newName && options.appName == null) {
    stdout.writeln('Project name is already "$newName". Nothing to do.');
    return;
  }

  final replacements = <_Replacement>[
    _Replacement(oldName, newName),
    _Replacement('package:$oldName/', 'package:$newName/'),
    if (options.appName != null)
      _Replacement(_titleFromPackageName(oldName), options.appName!),
  ];

  final changedFiles = <String>[];
  for (final file in _walkTextFiles(root)) {
    final original = file.readAsStringSync();
    var updated = original;
    for (final replacement in replacements) {
      updated = updated.replaceAll(replacement.from, replacement.to);
    }
    if (updated == original) continue;

    changedFiles.add(_relativePath(root, file));
    if (!options.dryRun) {
      file.writeAsStringSync(updated);
    }
  }

  if (changedFiles.isEmpty) {
    stdout.writeln('No files changed.');
    return;
  }

  final action = options.dryRun ? 'Would update' : 'Updated';
  stdout.writeln('$action ${changedFiles.length} file(s):');
  for (final path in changedFiles) {
    stdout.writeln('  - $path');
  }

  if (!options.dryRun) {
    stdout.writeln('\nNext steps:');
    stdout.writeln('  1. flutter pub get');
    stdout.writeln('  2. dart format lib test script');
    stdout.writeln('  3. flutter analyze');
  }
}

Iterable<File> _walkTextFiles(Directory root) sync* {
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is Directory) continue;
    if (entity is! File) continue;
    final relative = _relativePath(root, entity);
    if (_isExcluded(relative)) continue;
    if (relative.endsWith('Generated.xcconfig')) continue;
    if (!_isTextFile(relative)) continue;
    yield entity;
  }
}

bool _isExcluded(String relativePath) {
  final parts = relativePath.split(Platform.pathSeparator);
  return parts.any(_defaultExcludedDirectories.contains);
}

bool _isTextFile(String path) {
  final lower = path.toLowerCase();
  return _textFileExtensions.any(lower.endsWith);
}

String _relativePath(Directory root, FileSystemEntity entity) {
  final prefix = '${root.path}${Platform.pathSeparator}';
  return entity.path.startsWith(prefix)
      ? entity.path.substring(prefix.length)
      : entity.path;
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

String _titleFromPackageName(String packageName) {
  return packageName
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run script/rename_project.dart <new_project_name> [options]',
  );
}

void _printHelp() {
  _printUsage();
  stdout.writeln('''

Renames the Flutter template package name and package imports.

Arguments:
  <new_project_name>        New Dart package name, e.g. my_app.

Options:
  --old-name <name>         Override the current package name read from pubspec.yaml.
  --app-name <name>         Also replace the title-cased app name, e.g. "My App".
  --dry-run                 Print files that would change without writing them.
  -h, --help                Show this help message.

Examples:
  dart run script/rename_project.dart my_app
  dart run script/rename_project.dart my_app --app-name "My App"
  dart run script/rename_project.dart my_app --dry-run
''');
}

final class _Replacement {
  const _Replacement(this.from, this.to);

  final String from;
  final String to;
}

final class _Options {
  const _Options({
    required this.projectName,
    required this.oldName,
    required this.appName,
    required this.dryRun,
    required this.showHelp,
  });

  final String? projectName;
  final String? oldName;
  final String? appName;
  final bool dryRun;
  final bool showHelp;

  static _Options parse(List<String> args) {
    String? projectName;
    String? oldName;
    String? appName;
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
          i++;
          if (i >= args.length) {
            stderr.writeln('Missing value for --old-name.');
            exit(64);
          }
          oldName = args[i];
        case '--app-name':
          i++;
          if (i >= args.length) {
            stderr.writeln('Missing value for --app-name.');
            exit(64);
          }
          appName = args[i];
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
      appName: appName,
      dryRun: dryRun,
      showHelp: showHelp,
    );
  }
}
