import 'package:serverpod_cloud_cli/util/scloud_version.dart';
import 'package:test/test.dart';
import 'package:cli_tools/package_version.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

import '../test_utils/project_factory.dart';
import '../test_utils/source_helper.dart';

class PubApiClientMock extends Mock implements PubApiClient {}

void main() {
  group('Given the pubspec version parser', () {
    test(
        'and a missing pubspec.yaml file '
        'when getting the version then null is returned', () {
      final pubSpecVersion = getPubSpecVersion(
        pubSpecPath: p.join('nonexistent_directory', 'pubspec.yaml'),
      );
      expect(pubSpecVersion, isNull);
    });

    group('and a pubspec.yaml file with missing version field', () {
      final pubspecFactory = DirectoryFactory()
        ..withPath('test')
        ..addFile(FileFactory(
          withName: 'pubspec.yaml',
          withContents: '''
name: version_test
        ''',
        ));

      setUp(() {
        pubspecFactory.construct();
      });

      tearDown(() {
        pubspecFactory.destruct();
      });

      test('when getting the version then FormatException is thrown', () {
        expect(
          () => getPubSpecVersion(
            pubSpecPath: p.join(pubspecFactory.directory.path, 'pubspec.yaml'),
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('and an adequate pubspec.yaml file', () {
      final pubspecFactory = DirectoryFactory()
        ..withPath('test')
        ..addFile(FileFactory(
          withName: 'pubspec.yaml',
          withContents: '''
name: version_test
version: 0.42.4711
        ''',
        ));

      setUp(() {
        pubspecFactory.construct();
      });

      tearDown(() {
        pubspecFactory.destruct();
      });

      test('when getting the version then the correct value is returned', () {
        final pubSpecVersion = getPubSpecVersion(
          pubSpecPath: p.join(pubspecFactory.directory.path, 'pubspec.yaml'),
        );
        expect(pubSpecVersion, isNotNull);
        expect(pubSpecVersion.toString(), equals('0.42.4711'));
      });
    });
  });

  group('Given the scloud cli source version constant', () {
    group('when comparing against a pubspec with a different version', () {
      final pubspecFactory = DirectoryFactory()
        ..withPath('test')
        ..addFile(FileFactory(
          withName: 'pubspec.yaml',
          withContents: '''
name: integration_test
version: 0.42.4711
        ''',
        ));

      setUp(() {
        pubspecFactory.construct();
      });

      tearDown(() {
        pubspecFactory.destruct();
      });

      test('then the versions mismatch', () {
        final pubSpecVersion = getPubSpecVersion(
          pubSpecPath: p.join(pubspecFactory.directory.path, 'pubspec.yaml'),
        );
        final sourceVersion = cliVersion;
        expect(pubSpecVersion, isNotNull);
        expect(pubSpecVersion, isNot(equals(sourceVersion)));
      });
    });

    group('when comparing against the real pubspec.yaml', () {
      test('then the versions must match', () {
        final pubSpecVersion = getPubSpecVersion();
        final sourceVersion = cliVersion;
        expect(pubSpecVersion, isNotNull);
        expect(pubSpecVersion, equals(sourceVersion));
      });
    });
  });
}
