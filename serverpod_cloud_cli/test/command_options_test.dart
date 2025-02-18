import 'dart:io';

import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

void main() {
  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );
  late Directory originalDirectory;

  setUp(() {
    Directory(testCacheFolderPath).createSync(recursive: true);
    originalDirectory = Directory.current;
    Directory.current = testCacheFolderPath;
  });

  tearDown(() {
    Directory.current = originalDirectory;

    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });

  group('Given ProjectIdOption', () {
    const projectIdOption = ProjectIdOption();

    test(
        'and no scloud.yaml exists when retrieving default value '
        'then the default value should be null', () {
      final defaultValue = projectIdOption.defaultValue();

      expect(defaultValue, null);
    });

    group('and valid scloud.yaml exists', () {
      setUp(() async {
        File('scloud.yaml').writeAsStringSync(jsonToYaml({
          'project': {'projectId': 'someProjectId'},
        }));

        // Simulate Serverpod server directory
        File('pubspec.yaml').writeAsStringSync(jsonToYaml({
          'name': 'my_project_server',
          'dependencies': {
            'serverpod': '2.1',
          },
        }));
      });

      test(
          'when retrieving default value '
          'then the default value should be the project id', () {
        final defaultValue = projectIdOption.defaultValue();

        expect(defaultValue, 'someProjectId');
      });
    });

    group('and invalid scloud.yaml exists', () {
      setUp(() async {
        File('scloud.yaml').writeAsStringSync(jsonToYaml({
          'project': {'invalidKey': 'someValue'},
        }));

        // Simulate Serverpod server directory
        File('pubspec.yaml').writeAsStringSync(jsonToYaml({
          'name': 'my_project_server',
          'dependencies': {
            'serverpod': '2.1',
          },
        }));
      });

      test(
          'when retrieving default value '
          'then the default value should be null', () {
        final defaultValue = projectIdOption.defaultValue();

        expect(defaultValue, isNull);
      });
    });
  });
}
