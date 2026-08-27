import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../test_utils/project_factory.dart';

void main() {
  test(
    'Given a pubspec with a serverpod dependency, when the isServerpodServer method is called, then the result is true',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.isServerpodServer();
      expect(result, isTrue);
    },
  );

  test(
    'Given a pubspec without a serverpod dependency, when the isServerpodServer method is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''),
      );

      final result = pubspec.isServerpodServer();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without a sdk constraint, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, contains('No sdk constraint found in package my_project'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a too old serverpod version, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ^2.2.0
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isNotEmpty);
      expect(
        result.first,
        contains('Unsupported serverpod version constraint'),
      );
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a compatible sdk version range, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and the min compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: "3.8.0"
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a high but compatible sdk version, when the projectDependencyIssues method is called, then the result is empty',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: ${ProjectFactory.highValidSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isEmpty);
    },
  );

  test(
    'Given a pubspec without dependencies section and a compatible sdk version, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, contains('No serverpod dependency found in pubspec.yaml'));
    },
  );

  test(
    'Given a pubspec without serverpod dependency, when the projectDependencyIssues method is called, then the result contains the serverpod error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, contains('No serverpod dependency found in pubspec.yaml'));
    },
  );

  test(
    'Given a pubspec with a flutter dependency, when the projectDependencyIssues method is called, then the result contains the flutter error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
  flutter: '3.29.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(
        result,
        contains(
          'A Flutter dependency is not allowed in a server package: my_project',
        ),
      );
    },
  );

  test(
    'Given a pubspec without serverpod dependency and without sdk constraint, when the projectDependencyIssues method is called, then the result contains both errors',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
dependencies:
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(
        result,
        allOf([
          contains('No serverpod dependency found in pubspec.yaml'),
          contains('No sdk constraint found in package my_project'),
        ]),
      );
    },
  );

  test(
    'Given a pubspec with serverpod.scripts.flutter_build, when hasFlutterBuildScript is called, then the result is true',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  scripts:
    flutter_build: dart run tool/build_web.dart
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isTrue);
    },
  );

  test(
    'Given a pubspec without serverpod.scripts.flutter_build, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without serverpod.scripts, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
serverpod:
  other_field: value
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec without serverpod section, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        '''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''',
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  test(
    'Given a pubspec with empty raw content, when hasFlutterBuildScript is called, then the result is false',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.2.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.hasFlutterBuildScript();
      expect(result, isFalse);
    },
  );

  group('TenantProjectPubspec.readLockfileDartSdk issues', () {
    test(
      'Given no pubspec.lock file, when readLockfileDartSdk is called, then the result is empty',
      () async {
        await d.dir('no_lockfile').create();
        final lockfile = d.path('no_lockfile/pubspec.lock');

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(lockfile),
        ).issues;
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock with a supported dart sdk constraint, when readLockfileDartSdk is called, then the result is empty',
      () async {
        await d.dir('supported_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.10.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(d.path('supported_lockfile/pubspec.lock')),
        ).issues;
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock without an sdks section, when readLockfileDartSdk is called, then the result is empty',
      () async {
        await d.dir('no_sdks_lockfile', [
          d.file('pubspec.lock', '''
packages:
  foo:
    dependency: direct
'''),
        ]).create();

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(d.path('no_sdks_lockfile/pubspec.lock')),
        ).issues;
        expect(result, isEmpty);
      },
    );
  });

  group('TenantProjectPubspec.readLockfileDartSdk constraint', () {
    test(
      'Given a pubspec.lock with a dart sdk constraint, when readLockfileDartSdk is called, then the constraint is returned',
      () async {
        await d.dir('constraint_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.10.3 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(d.path('constraint_lockfile/pubspec.lock')),
        ).constraint;

        expect(result, '>=3.10.3 <4.0.0');
      },
    );

    test(
      'Given no pubspec.lock file, when readLockfileDartSdk is called, then null is returned',
      () async {
        await d.dir('constraint_no_lockfile').create();

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(d.path('constraint_no_lockfile/pubspec.lock')),
        ).constraint;

        expect(result, isNull);
      },
    );

    test(
      'Given a pubspec.lock without an sdks section, when readLockfileDartSdk is called, then null is returned',
      () async {
        await d.dir('constraint_no_sdks', [
          d.file('pubspec.lock', '''
packages:
  serverpod:
    version: "3.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.readLockfileDartSdk(
          File(d.path('constraint_no_sdks/pubspec.lock')),
        ).constraint;

        expect(result, isNull);
      },
    );
  });
}
