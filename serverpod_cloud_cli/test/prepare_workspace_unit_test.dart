import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/commands/deploy/prepare_workspace.dart';

import '../test_utils/project_factory.dart';

void main() {
  group('WorkspaceProjectLogic.getWorkspaceDependencies -', () {
    test('Given a single package with no dependencies, '
        'when called, then returns only itself', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final allPackages = {'package_a': packageA};
      final included = {'package_a': packageA};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, unorderedEquals(['package_a']));
    });

    test('Given a package with a direct workspace dependency, '
        'when called, then returns both', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  package_b:
''');
      final pubspecB = Pubspec.parse('''
name: package_b
dependencies:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final packageB = WorkspacePackage(Directory('b'), pubspecB);
      final allPackages = {'package_a': packageA, 'package_b': packageB};
      final included = {'package_a': packageA};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, containsAll(['package_a', 'package_b']));
      expect(result.length, 2);
    });

    test('Given a package with a transitive workspace dependency, '
        'when called, then returns all transitives', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  package_b:
''');
      final pubspecB = Pubspec.parse('''
name: package_b
dependencies:
  package_c:
''');
      final pubspecC = Pubspec.parse('''
name: package_c
dependencies:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final packageB = WorkspacePackage(Directory('b'), pubspecB);
      final packageC = WorkspacePackage(Directory('c'), pubspecC);
      final allPackages = {
        'package_a': packageA,
        'package_b': packageB,
        'package_c': packageC,
      };
      final included = {'package_a': packageA};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, containsAll(['package_a', 'package_b', 'package_c']));
      expect(result.length, 3);
    });

    test('Given a package with a non-workspace dependency, '
        'when called, then ignores non-workspace dependency', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  external_package:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final allPackages = {'package_a': packageA};
      final included = {'package_a': packageA};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, containsAll(['package_a']));
      expect(result.length, 1);
    });

    test('Given duplicate dependencies, '
        'when called, then does not repeat dependencies', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  package_b:
  package_c:
''');
      final pubspecB = Pubspec.parse('''
name: package_b
dependencies:
  package_c:
''');
      final pubspecC = Pubspec.parse('''
name: package_c
dependencies:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final packageB = WorkspacePackage(Directory('b'), pubspecB);
      final packageC = WorkspacePackage(Directory('c'), pubspecC);
      final allPackages = {
        'package_a': packageA,
        'package_b': packageB,
        'package_c': packageC,
      };
      final included = {'package_a': packageA};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, containsAll(['package_a', 'package_b', 'package_c']));
      expect(result.length, 3);
    });

    test(
      'Given circular dependencies, when called, then does not infinite loop',
      () {
        final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  package_b:
''');
        final pubspecB = Pubspec.parse('''
name: package_b
dependencies:
  package_a:
''');
        final packageA = WorkspacePackage(Directory('a'), pubspecA);
        final packageB = WorkspacePackage(Directory('b'), pubspecB);
        final allPackages = {'package_a': packageA, 'package_b': packageB};
        final included = {'package_a': packageA};
        final result = WorkspaceProjectLogic.getWorkspaceDependencies(
          allWorkspacePackages: allPackages,
          package: packageA,
          included: included,
        );
        expect(result.keys, containsAll(['package_a', 'package_b']));
        expect(result.length, 2);
      },
    );

    test('Given already included packages, '
        'when called, then does not add or recurse again', () {
      final pubspecA = Pubspec.parse('''
name: package_a
dependencies:
  package_b:
''');
      final pubspecB = Pubspec.parse('''
name: package_b
dependencies:
''');
      final packageA = WorkspacePackage(Directory('a'), pubspecA);
      final packageB = WorkspacePackage(Directory('b'), pubspecB);
      final allPackages = {'package_a': packageA, 'package_b': packageB};
      final included = {'package_a': packageA, 'package_b': packageB};
      final result = WorkspaceProjectLogic.getWorkspaceDependencies(
        allWorkspacePackages: allPackages,
        package: packageA,
        included: included,
      );
      expect(result.keys, containsAll(['package_a', 'package_b']));
      expect(result.length, 2);
    });
  });

  group('WorkspaceProjectLogic.validateIncludedPackages -', () {
    test('Given all valid packages, when called, then does not throw', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''');
      final pubspecB = Pubspec.parse('''
name: package_b
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
''');
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([
          pubspecA,
          pubspecB,
        ]),
        returnsNormally,
      );
    });

    test('Given a single package with issues, '
        'when called, then throws WorkspaceException', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ">=2.12.0 <3.0.0"
dependencies:
''');
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([pubspecA]),
        throwsA(
          isA<WorkspaceException>().having(
            (final e) => e.errors,
            'errors',
            contains(
              startsWith(
                'Unsupported sdk version constraint in package package_a: >=2.12.0 <3.0.0',
              ),
            ),
          ),
        ),
      );
    });

    test('Given multiple packages, one with issues, '
        'when called, then throws WorkspaceException with issues', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''');
      final pubspecB = Pubspec.parse('''
name: package_b
environment:
  sdk: ">=2.12.0 <3.0.0"
dependencies:
''');
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([
          pubspecA,
          pubspecB,
        ]),
        throwsA(
          isA<WorkspaceException>().having(
            (final e) => e.errors,
            'errors',
            contains(
              startsWith(
                'Unsupported sdk version constraint in package package_b: >=2.12.0 <3.0.0',
              ),
            ),
          ),
        ),
      );
    });

    test('Given multiple packages, multiple with issues, '
        'when called, then throws WorkspaceException with all issues', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ">=2.12.0 <3.0.0"
dependencies:
''');
      final pubspecB = Pubspec.parse('''
name: package_b
environment:
  sdk: ">=2.10.0 <2.12.0"
dependencies:
''');
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([
          pubspecA,
          pubspecB,
        ]),
        throwsA(
          isA<WorkspaceException>().having(
            (final e) => e.errors,
            'errors',
            hasLength(2),
          ),
        ),
      );
    });

    test('Given an empty package list, when called, then does not throw', () {
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([]),
        returnsNormally,
      );
    });

    test('Given a package with only dev_dependencies, '
        'when called, then does not throw', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dev_dependencies:
  test: any
''');
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([pubspecA]),
        returnsNormally,
      );
    });

    test('Given a package with optional serverpod dependency, '
        'when called, then does not throw', () {
      final pubspecA = Pubspec.parse('''
name: package_a
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
''');
      // The logic sets requireServerpod: false, so this should not throw
      expect(
        () => WorkspaceProjectLogic.validateIncludedPackages([pubspecA]),
        returnsNormally,
      );
    });
  });

  group('WorkspaceProjectLogic.makeScloudRootPubspecContent -', () {
    test('Given a valid root pubspec with workspace and dependencies, '
        'when called, then replaces workspace and removes '
        'dependencies/dev_dependencies/environment.flutter', () {
      final rootPubspec =
          '''
name: root
workspace:
  - packages/a
  - packages/b
dependencies:
  some_dep: ^1.0.0
dev_dependencies:
  test: any
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: ">=3.0.0 <4.0.0"
''';
      final includedPaths = ['packages/a'];
      final result = WorkspaceProjectLogic.makeScloudRootPubspecContent(
        rootPubspec,
        includedPaths,
      );
      expect(result, contains('workspace:'));
      expect(result, contains('- "packages/a"'));
      expect(result, isNot(contains('packages/b')));
      expect(result, isNot(contains('dependencies:')));
      expect(result, isNot(contains('dev_dependencies:')));
      expect(result, contains('sdk: ${ProjectFactory.validSdkVersion}'));
      expect(result, isNot(contains('flutter:')));
    });

    test('Given a root pubspec without dependencies or dev_dependencies, '
        'when called, then replaces workspace and does not add them', () {
      final rootPubspec = '''
name: root
workspace:
  - packages/a
''';
      final includedPaths = ['packages/a'];
      final result = WorkspaceProjectLogic.makeScloudRootPubspecContent(
        rootPubspec,
        includedPaths,
      );
      expect(result, contains('workspace:'));
      expect(result, contains('- "packages/a"'));
      expect(result, isNot(contains('dependencies:')));
      expect(result, isNot(contains('dev_dependencies:')));
    });

    test('Given a root pubspec with environment field containing flutter, '
        'when called, then removes flutter from environment', () {
      final rootPubspec =
          '''
name: root
workspace:
  - packages/a
environment:
  sdk: ${ProjectFactory.validSdkVersion}
  flutter: ">=3.0.0 <4.0.0"
''';
      final includedPaths = ['packages/a'];
      final result = WorkspaceProjectLogic.makeScloudRootPubspecContent(
        rootPubspec,
        includedPaths,
      );
      expect(result, contains('sdk: ${ProjectFactory.validSdkVersion}'));
      expect(result, isNot(contains('flutter:')));
    });

    test('Given a root pubspec with workspace field not a list, '
        'when called, then throws WorkspaceException', () {
      final rootPubspec = '''
name: root
workspace: not-a-list
''';
      final includedPaths = ['packages/a'];
      expect(
        () => WorkspaceProjectLogic.makeScloudRootPubspecContent(
          rootPubspec,
          includedPaths,
        ),
        throwsA(isA<WorkspaceException>()),
      );
    });

    test('Given a root pubspec that is not a map, '
        'when called, then throws WorkspaceException', () {
      final rootPubspec = '''
- just
- a
- list
''';
      final includedPaths = ['packages/a'];
      expect(
        () => WorkspaceProjectLogic.makeScloudRootPubspecContent(
          rootPubspec,
          includedPaths,
        ),
        throwsA(isA<WorkspaceException>()),
      );
    });

    test('Given a root pubspec with environment field not a map, '
        'when called, then leaves environment unchanged', () {
      final rootPubspec = '''
name: root
workspace:
  - packages/a
environment: not-a-map
''';
      final includedPaths = ['packages/a'];
      final result = WorkspaceProjectLogic.makeScloudRootPubspecContent(
        rootPubspec,
        includedPaths,
      );
      expect(result, contains('environment: "not-a-map"'));
    });
  });

  group('WorkspaceProject.stripDevDependenciesFromPubspecContent -', () {
    test('Given pubspec content with dev_dependencies, '
        'when called, then removes dev_dependencies', () {
      const pubspecContent =
          '''
name: test_package
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
dev_dependencies:
  test: ^1.0.0
  build_runner: ^2.0.0
''';

      final result = WorkspaceProject.stripDevDependenciesFromPubspecContent(
        pubspecContent,
      );
      expect(result, isNot(contains('dev_dependencies:')));
      expect(result, contains('dependencies:'));
      expect(result, contains('test_package'));
      expect(result, isNot(contains('test: ^1.0.0')));
      expect(result, isNot(contains('build_runner: ^2.0.0')));
    });

    test('Given pubspec content without dev_dependencies, '
        'when called, then returns null', () {
      const originalContent =
          '''
name: test_package
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dependencies:
  serverpod: ${ProjectFactory.validServerpodVersion}
''';

      final result = WorkspaceProject.stripDevDependenciesFromPubspecContent(
        originalContent,
      );
      expect(result, isNull);
    });

    test('Given invalid YAML content, '
        'when called, then returns null', () {
      const invalidContent = 'not valid yaml: [';

      final result = WorkspaceProject.stripDevDependenciesFromPubspecContent(
        invalidContent,
      );
      expect(result, isNull);
    });

    test('Given pubspec content with only dev_dependencies, '
        'when called, then removes dev_dependencies', () {
      const pubspecContent =
          '''
name: test_package
version: 1.0.0
environment:
  sdk: ${ProjectFactory.validSdkVersion}
dev_dependencies:
  test: ^1.0.0
''';

      final result = WorkspaceProject.stripDevDependenciesFromPubspecContent(
        pubspecContent,
      );
      expect(result, isNot(contains('dev_dependencies:')));
      expect(result, contains('test_package'));
    });
  });
}
