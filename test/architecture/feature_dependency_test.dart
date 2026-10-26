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

  test('core router does not import app, features, or toast', () {
    final offenders = <String>[];
    final importPattern = RegExp(
      r"""^\s*import\s+['"]([^'"]+)['"]""",
      multiLine: true,
    );
    const forbiddenPrefixes = <String>[
      'package:flutter_starter_app/app/',
      'package:flutter_starter_app/features/',
      'package:flutter_starter_app/shared/widgets/toast/',
    ];

    for (final file in _coreRouterDartFiles()) {
      final content = file.readAsStringSync();
      for (final match in importPattern.allMatches(content)) {
        final importUri = match.group(1)!;
        if (forbiddenPrefixes.any(importUri.startsWith)) {
          offenders.add('${file.path}: $importUri');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'core/router must stay decoupled from app, features, and toast.',
    );
  });

  test('Riverpod imports are isolated to the Riverpod integration', () {
    final offenders = <String>[];
    final importPattern = RegExp(
      r'''^\s*import\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );

    for (final file in _coreRouterDartFiles()) {
      final relativePath = file.path.replaceAll('\\', '/');
      if (relativePath.contains('/integrations/riverpod/')) continue;
      for (final match in importPattern.allMatches(file.readAsStringSync())) {
        final importUri = match.group(1)!;
        if (importUri == 'package:flutter_riverpod/flutter_riverpod.dart') {
          offenders.add('${file.path}: $importUri');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Riverpod dependencies must stay in integrations/riverpod.',
    );
  });

  test('features use typed navigation and do not import GoRouter', () {
    final offenders = <String>[];
    final stringNavigationPattern = RegExp(
      r'\.(goLocation|pushLocation|replaceLocation|replaceAllLocation)\s*\(',
    );

    for (final file in _featureDartFiles()) {
      final content = file.readAsStringSync();
      if (content.contains('package:go_router/go_router.dart')) {
        offenders.add('${file.path}: GoRouter import');
      }
      if (stringNavigationPattern.hasMatch(content)) {
        offenders.add('${file.path}: string navigation API');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Features must use typed targets through the router contract.',
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

Iterable<File> _coreRouterDartFiles() {
  return Directory(
    'lib/core/router',
  ).listSync(recursive: true).whereType<File>().where((file) {
    return file.path.replaceAll('\\', '/').endsWith('.dart');
  });
}

Iterable<File> _featureDartFiles() {
  return Directory(
    'lib/features',
  ).listSync(recursive: true).whereType<File>().where((file) {
    return file.path.replaceAll('\\', '/').endsWith('.dart');
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
