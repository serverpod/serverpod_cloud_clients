import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:serverpod_cloud_cli/constants.dart' show VersionConstants;
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
    'Given a pubspec with a serverpod dependency and a too advanced sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.999.0 <4.0.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isNotEmpty);
      expect(result.first, contains('Unsupported sdk version constraint'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and sdk version just above the supported range, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '3.12.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(
        result,
        isNotEmpty,
        reason: 'Version was allowed but expected to be rejected',
      );
      expect(result.first, contains('Unsupported sdk version constraint'));
    },
  );

  test(
    'Given a pubspec with a serverpod dependency and a too old sdk version, when the projectDependencyIssues method is called, then the result contains the sdk error',
    () {
      final pubspec = TenantProjectPubspec(
        Pubspec.parse('''
name: my_project
environment:
  sdk: '>=3.1.0 <3.2.0'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
      );

      final result = pubspec.projectDependencyIssues();
      expect(result, isNotEmpty);
      expect(result.first, contains('Unsupported sdk version constraint'));
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
  sdk: "${VersionConstants.minSupportedSdkVersion}"
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

  group('TenantProjectPubspec.lockfileDependencyIssues', () {
    test(
      'Given a compatible pubspec sdk and an incompatible lockfile sdk, when both are validated, then the lockfile sdk error is returned',
      () async {
        await d.dir('mismatch', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.12.0 <4.0.0"
'''),
        ]).create();

        final pubspec = TenantProjectPubspec(
          Pubspec.parse('''
name: my_project
environment:
  sdk: '^3.10.3'
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
'''),
        );

        final pubspecIssues = pubspec.projectDependencyIssues();
        final lockfileIssues = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('mismatch/pubspec.lock')),
        );

        expect(pubspecIssues, isEmpty);
        expect(lockfileIssues, isNotEmpty);
        expect(
          lockfileIssues.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given no pubspec.lock file, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('no_lockfile').create();
        final lockfile = d.path('no_lockfile/pubspec.lock');

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(lockfile),
        );
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock with a supported dart sdk constraint, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('supported_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.10.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('supported_lockfile/pubspec.lock')),
        );
        expect(result, isEmpty);
      },
    );

    test(
      'Given a pubspec.lock with a too advanced dart sdk constraint, when lockfileDependencyIssues is called, then the result contains the sdk error',
      () async {
        await d.dir('advanced_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0 <4.0.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('advanced_lockfile/pubspec.lock')),
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock with a too old dart sdk constraint, when lockfileDependencyIssues is called, then the result contains the sdk error',
      () async {
        await d.dir('old_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: ">=3.1.0 <3.2.0"
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('old_lockfile/pubspec.lock')),
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Unsupported sdk version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock with an invalid dart sdk constraint, when lockfileDependencyIssues is called, then the result contains a parse error',
      () async {
        await d.dir('invalid_lockfile', [
          d.file('pubspec.lock', '''
sdks:
  dart: not-a-version
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('invalid_lockfile/pubspec.lock')),
        );
        expect(result, isNotEmpty);
        expect(
          result.first,
          contains('Invalid Dart SDK version constraint in pubspec.lock'),
        );
      },
    );

    test(
      'Given a pubspec.lock without an sdks section, when lockfileDependencyIssues is called, then the result is empty',
      () async {
        await d.dir('no_sdks_lockfile', [
          d.file('pubspec.lock', '''
packages:
  foo:
    dependency: direct
'''),
        ]).create();

        final result = TenantProjectPubspec.lockfileDependencyIssues(
          File(d.path('no_sdks_lockfile/pubspec.lock')),
        );
        expect(result, isEmpty);
      },
    );
  });
}
