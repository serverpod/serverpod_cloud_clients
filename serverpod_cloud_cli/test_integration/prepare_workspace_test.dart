import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/commands/deploy/prepare_workspace.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test/test.dart';

import 'package:yaml_codec/yaml_codec.dart';

import '../test_utils/project_factory.dart' show ProjectFactory;
import '../test_utils/test_command_logger.dart' show TestCommandLogger;

void main() {
  final logger = TestCommandLogger();

  group(
      'Given a complex workspace directory structure '
      'when preparing the workspace for deployment', () {
    late final Directory wsRootDir;
    late final Iterable<String> includedPackagePaths;

    setUpAll(() async {
      await d.dir('monorepo', [
        d.file('pubspec.yaml', '''
name: monorepo
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
workspace:
  - packages/dart_utilities
  - packages/flutter_utilities
  - project/project_server
  - project/project_client
  - project/project_app
'''),
        d.dir('packages', [
          d.dir('dart_utilities', [
            d.file('pubspec.yaml', '''
name: dart_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
'''),
          ]),
          d.dir('flutter_utilities', [
            d.file('pubspec.yaml', '''
name: flutter_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
resolution: workspace
'''),
          ]),
        ]),
        d.dir('project', [
          d.dir('project_server', [
            d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
dependencies:
  serverpod: ^2.3.0
  dart_utilities: ^1.0.0
'''),
          ]),
          d.dir('project_client', [
            d.file('pubspec.yaml', '''
name: project_client
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
'''),
          ]),
          d.dir('project_app', [
            d.file('pubspec.yaml', '''
name: project_app
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
resolution: workspace
dependencies:
  project_client: ^1.0.0
  flutter_utilities: ^1.0.0
'''),
          ]),
        ]),
      ]).create();

      logger.clear();

      (wsRootDir, includedPackagePaths) =
          WorkspaceProject.prepareWorkspacePaths(
        Directory(p.join(d.sandbox, 'monorepo', 'project', 'project_server')),
      );
    });

    test('then the correct workspace root directory is found', () async {
      expect(wsRootDir.path, equals(p.join(d.sandbox, 'monorepo')));
    });

    test('then the correct included subpaths are returned', () async {
      expect(
          includedPackagePaths,
          containsAll([
            'packages/dart_utilities',
            'project/project_server',
          ]));
    });

    test('then .scloud/scloud_server_dir file is created.', () async {
      final descriptor = d.dir('.scloud', [
        d.file('scloud_server_dir', 'project/project_server'),
      ]);

      await expectLater(
        descriptor.validate(p.join(d.sandbox, 'monorepo')),
        completes,
      );
    });

    test('then .scloud/scloud_ws_pubspec.yaml file is created.', () async {
      final fileDescriptor = d.file('scloud_ws_pubspec.yaml', isNotEmpty);
      final descriptor = d.dir('.scloud', [
        fileDescriptor,
      ]);

      await expectLater(
        descriptor.validate(p.join(d.sandbox, 'monorepo')),
        completes,
      );

      final content = File(
        p.join(d.sandbox, 'monorepo', '.scloud', 'scloud_ws_pubspec.yaml'),
      ).readAsStringSync();
      final doc = yamlDecode(content);
      expect(doc, containsPair('name', 'monorepo'));
      expect(doc, containsPair('environment', isNot(contains('flutter'))));
      expect(
        doc,
        containsPair('environment', containsPair('sdk', isNotEmpty)),
      );
      expect(
        doc,
        containsPair(
          'workspace',
          containsAll([
            'project/project_server',
            'packages/dart_utilities',
          ]),
        ),
      );
    });
  });

  group(
      'Given a workspace directory structure with an indirect flutter dependency '
      'when preparing the workspace for deployment', () {
    setUpAll(() async {
      await d.dir('monorepo', [
        d.file('pubspec.yaml', '''
name: monorepo
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
workspace:
  - packages/flutter_utilities
  - project/project_server
'''),
        d.dir('packages', [
          d.dir('flutter_utilities', [
            d.file('pubspec.yaml', '''
name: flutter_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: 3.29.0
resolution: workspace
'''),
          ]),
        ]),
        d.dir('project', [
          d.dir('project_server', [
            d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
dependencies:
  serverpod: ^2.3.0
  flutter_utilities: ^1.0.0
'''),
          ]),
        ]),
      ]).create();
    });

    setUp(() {
      logger.clear();
    });

    task(final String baseDir) => WorkspaceProject.prepareWorkspacePaths(
          Directory(p.join(baseDir, 'monorepo', 'project', 'project_server')),
        );

    test('then command throws WorkspaceException.', () async {
      expect(
        () => task(d.sandbox),
        throwsA(isA<WorkspaceException>().having(
          (final e) => e.errors,
          'errors',
          equals([
            'A Flutter dependency is not allowed in a server package: flutter_utilities',
          ]),
        )),
      );
    });
  });

  group('Given a workspace package with missing workspace root', () {
    setUpAll(() async {
      logger.clear();

      await d.dir('monorepo', [
        d.dir('packages', [
          d.dir('dart_utilities', [
            d.file('pubspec.yaml', '''
name: dart_utilities
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
'''),
          ]),
        ]),
        d.dir('project', [
          d.dir('project_server', [
            d.file('pubspec.yaml', '''
name: project_server
environment:
  sdk: ${ProjectFactory.validSdkVersion}
resolution: workspace
dependencies:
  serverpod: ^2.3.0
  dart_utilities: ^1.0.0
'''),
          ]),
        ]),
      ]).create();
    });

    setUp(() {
      logger.clear();
    });

    task(final String baseDir) => WorkspaceProject.prepareWorkspacePaths(
          Directory(p.join(baseDir, 'monorepo', 'project', 'project_server')),
        );

    test('then command throws WorkspaceException.', () async {
      expect(
        () => task(d.sandbox),
        throwsA(isA<WorkspaceException>().having(
          (final e) => e.errors,
          'errors',
          equals([
            'Could not find the workspace root directory.',
            'Ensure the project is part of a valid Dart workspace.',
          ]),
        )),
      );
    });
  });
}
