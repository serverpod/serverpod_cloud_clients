import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:test/test.dart';

import '../../test_utils/test_command_logger.dart';

void main() {
  final commandLogger = CommandLogger.create(LogLevel.debug);

  test(
      'Given empty standard out '
      'when calling confirm with valid input "yes" '
      'then should return true', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['yes'],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with valid input "y" '
      'then should return true', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['y'],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with valid input capital "Y" '
      'then should return true', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['Y'],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with valid input "no" '
      'then should return false', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['no'],
      () async {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isFalse),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with valid input "n" '
      'then should return false', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['n'],
      () async {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isFalse),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with valid input capital "N" '
      'then should return false', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['N'],
      () async {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    await expectLater(
      result,
      completion(isFalse),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with invalid input "invalid" and then valid input "yes" '
      'then should prompt again and return true', () async {
    late final Future<bool> result;
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdinLines: ['invalid', 'yes'],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    expect(
      stdout.output,
      'Are you sure? [y/n]: '
      'Invalid input. Please enter "y" or "n".\n'
      'Are you sure? [y/n]: ',
    );

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with empty input with default value false '
      'then should return false', () async {
    late final bool result;
    await collectOutput(
      stdinLines: ['  '],
      () async {
        result = await commandLogger.confirm(
          'Are you sure?',
          defaultValue: false,
        );
      },
    );

    await expectLater(
      result,
      isFalse,
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with empty input with default value true '
      'then should return true', () async {
    late final Future<bool> result;
    await collectOutput(
      stdinLines: ['  '],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
          defaultValue: true,
        );
      },
    );

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm with empty input and then "yes" without default value '
      'then should prompt again and return true', () async {
    late final Future<bool> result;
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdinLines: ['  ', 'yes'],
      () {
        result = commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    expect(
        stdout.output,
        'Are you sure? [y/n]: '
        'Please enter "y" or "n".\n'
        'Are you sure? [y/n]: ');

    await expectLater(
      result,
      completion(isTrue),
    );
  });

  test(
      'Given empty standard out '
      'when calling confirm without default value '
      'then should prompt with lowercase "y" and "n"', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdinLines: ['yes'],
      () async {
        await commandLogger.confirm(
          'Are you sure?',
        );
      },
    );

    expect(stdout.output, 'Are you sure? [y/n]: ');
  });

  test(
      'Given empty standard out '
      'when calling confirm with default value true '
      'then should prompt with uppercase "Y" and lowercase "n"', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdinLines: ['yes'],
      () async {
        await commandLogger.confirm(
          'Are you sure?',
          defaultValue: true,
        );
      },
    );

    expect(stdout.output, 'Are you sure? [Y/n]: ');
  });

  test(
      'Given empty standard out '
      'when calling confirm with default value true '
      'then should prompt with lowercase "y" and uppercase "N"', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdinLines: ['yes'],
      () async {
        await commandLogger.confirm(
          'Are you sure?',
          defaultValue: false,
        );
      },
    );

    expect(stdout.output, 'Are you sure? [y/N]: ');
  });

  test(
      'Given empty standard out '
      'when calling confirm with skip-confirmation option set '
      'then should immediately return true', () async {
    commandLogger.configuration = GlobalConfiguration.resolve(
      args: ['--skip-confirmation'],
    );

    late final bool result;

    final (:stdout, :stderr, :stdin) = await collectOutput(
      () async {
        result = await commandLogger.confirm(
          'Are you sure?',
          defaultValue: false,
        );
      },
    );

    expect(stdout.output, 'Are you sure?: y\n');
    expect(result, isTrue);
  });
}
