import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature presentation does not import data layer', () {
    final offenders = <String>[];
    final importPattern = RegExp(
      r"""^\s*import\s+['"]([^'"]+)['"]""",
      multiLine: true,
    );

    for (final file in _presentationDartFiles()) {
      final content = file.readAsStringSync();
      for (final match in importPattern.allMatches(content)) {
        final importUri = match.group(1)!;
        final resolvedPath = _resolveImportPath(file, importUri);
        if (resolvedPath == null) continue;
        if (_isFeatureDataPath(resolvedPath)) {
          offenders.add('${file.path}: $importUri');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Presentation must depend on domain abstractions, not data.',
    );
  });
}

Iterable<File> _presentationDartFiles() {
  return Directory(
    'lib/features',
  ).listSync(recursive: true).whereType<File>().where((file) {
    final path = file.path.replaceAll('\\', '/');
    return path.endsWith('.dart') && path.contains('/presentation/');
  });
}

String? _resolveImportPath(File file, String importUri) {
  if (importUri.startsWith('dart:')) return null;
  if (importUri.startsWith('package:')) {
    const packagePrefix = 'package:flutter_starter_app/';
    if (!importUri.startsWith(packagePrefix)) return null;
    return 'lib/${importUri.substring(packagePrefix.length)}';
  }
  return file.parent.uri.resolve(importUri).normalizePath().toFilePath();
}

bool _isFeatureDataPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('lib/features/') && normalized.contains('/data/');
}
