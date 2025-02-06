import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:test/test.dart';

import '../test_utils/project_factory.dart';

void main() {
  group('Given ProjectIdOption', () {
    const projectIdOption = ProjectIdOption();

    test(
        'and no scloud.yaml exists when retrieving default value '
        'then the default value should be null', () {
      final defaultValue = projectIdOption.defaultValue();

      expect(defaultValue, null);
    });

    group('and valid scloud.yaml exists in the current directory', () {
      final dirFactory = DirectoryFactory.serverpodServerDir()
        ..withPath('test_integration')
        ..addFile(
          FileFactory(
            withName: 'scloud.yaml',
            withContents: jsonToYaml({
              'project': {
                'projectId': 'someProjectId',
              },
            }),
          ),
        );

      setUp(() async {
        dirFactory.construct(pushCurrentDirectory: true);
      });

      tearDown(() {
        dirFactory.destruct();
      });

      test(
          'when retrieving default value '
          'then the default value should be the project id', () {
        final defaultValue = projectIdOption.defaultValue();

        expect(defaultValue, 'someProjectId');
      });
    });

    group('and invalid scloud.yaml exists in the current directory', () {
      final dirFactory = DirectoryFactory.serverpodServerDir()
        ..withPath('test_integration')
        ..addFile(
          FileFactory(
            withName: 'scloud.yaml',
            withContents: jsonToYaml({
              'project': {
                'invalidKey': 'someValue',
              },
            }),
          ),
        );

      setUp(() async {
        dirFactory.construct(pushCurrentDirectory: true);
      });

      tearDown(() {
        dirFactory.destruct();
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
