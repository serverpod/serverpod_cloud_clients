import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:test/test.dart';

import '../../test_utils/mock_stdout.dart';
import '../../test_utils/test_command_logger.dart';

void main() {
  final commandLogger = CommandLogger.create(LogLevel.debug);

  test(
      'Given empty standard out '
      'when calling debug '
      'then debug message is logged correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.debug('Debugging information');
    });

    expect(
      stdout.output,
      'DEBUG: Debugging information\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling debug with newParagraph enabled '
      'then output starts with a new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.debug('Debugging information', newParagraph: true);
    });

    expect(
      stdout.output,
      '\nDEBUG: Debugging information\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling error with hint property '
      'then both error and hint are logged correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.error(
        'An error occurred',
        hint: 'Try running the command with different arguments.',
      );
    });

    expect(
      stdout.output,
      stringContainsInOrder([
        'ERROR: An error occurred',
        'Try running the command with different arguments.',
      ]),
    );
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling error with hint property and newParagraph enabled '
      'then error output starts with a new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.error(
        'An error occurred',
        hint: 'Try running the command with different arguments.',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      stringContainsInOrder([
        'ERROR: An error occurred',
        'Try running the command with different arguments.',
      ]),
    );
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling error without hint property '
      'then only error is printed', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.error(
        'An error occurred',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      '\nERROR: An error occurred\n',
    );
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling info '
      'then logs message correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.info(
        'Some info',
      );
    });

    expect(stderr.output, '');
    expect(
      stdout.output,
      'Some info\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling info with newParagraph enabled '
      'then logs message correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.info(
        'Some info',
        newParagraph: true,
      );
    });

    expect(stderr.output, '');
    expect(
      stdout.output,
      '\nSome info\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling list with title property'
      'then output is formatted correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.list(['first', 'second'], title: 'Follow these steps:');
    });

    expect(
      stdout.output,
      'Follow these steps:\n'
      ' • first\n'
      ' • second\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling list without title property'
      'then output is formatted correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.list(['first', 'second']);
    });

    expect(
      stdout.output,
      ' • first\n'
      ' • second\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling list with title property and newParagraph enabled'
      'then title starts with new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.list(
        ['first', 'second'],
        newParagraph: true,
        title: 'Follow these steps:',
      );
    });

    expect(
      stdout.output,
      '\nFollow these steps:\n'
      ' • first\n'
      ' • second\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling list without title property and newParagraph enabled'
      'then output starts with new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.list(['first', 'second'], newParagraph: true);
    });

    expect(
      stdout.output,
      '\n'
      ' • first\n'
      ' • second\n',
    );
  });

  test(
    'Given empty standard out '
    'when calling success with trailingRocket enabled '
    'then output is formatted with a rocket at the end if platform is not Windows',
    () async {
      final (:stdout, :stderr, :stdin) = await collectOutput(() {
        commandLogger.success('Operation successful', trailingRocket: true);
      });

      expect(stdout.output, startsWith('Operation successful'));
    },
  );

  test(
      'Given empty standard out '
      'when calling success with trailingRocket disabled '
      'then output is not formatted with a rocket at the end', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.success('Operation successful', trailingRocket: false);
    });

    expect(
      stdout.output,
      'Operation successful\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling success with newParagraph enabled'
      'then output starts with a new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.success(
        'Operation successful',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      '\nOperation successful\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling success with followUp property'
      'then output starts with a new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.success(
        'Operation successful',
        followUp: 'You can now proceed to the next step.',
      );
    });

    expect(
      stdout.output,
      'Operation successful\n'
      'You can now proceed to the next step.\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling terminalCommand without message property'
      'then output is formatted correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.terminalCommand('echo "Hello, World!"');
    });

    expect(
      stdout.output,
      '   \$ echo "Hello, World!"\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling terminalCommand without message property and newParagraph enabled'
      'then output starts with new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.terminalCommand(
        'echo "Hello, World!"',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      '\n'
      '   \$ echo "Hello, World!"\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling terminalCommand with message property'
      'then message is output before the command', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.terminalCommand(
        'echo "Hello, World!"',
        message: 'Run this command:',
      );
    });

    expect(
      stdout.output,
      'Run this command:\n'
      '   \$ echo "Hello, World!"\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling terminalCommand with message property and newParagraph enabled'
      'then message starts with a new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.terminalCommand(
        'echo "Hello, World!"',
        message: 'Run this command:',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      '\nRun this command:\n'
      '   \$ echo "Hello, World!"\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling warning '
      'then logs message correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.warning(
        'Invalid value found in config',
      );
    });

    expect(stdout.output, 'WARNING: Invalid value found in config\n');
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling warning with newParagraph enabled '
      'then output starts with new paragraph', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.warning(
        'Invalid value found in config',
        newParagraph: true,
      );
    });

    expect(
        stdout.output,
        stringContainsInOrder([
          '\n',
          'WARNING: Invalid value found in config\n',
        ]));
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling warning with hint property '
      'then both warning and hint are logged correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.warning('Invalid value found in config',
          hint: 'Try removing the value.');
    });

    expect(
      stdout.output,
      stringContainsInOrder([
        'WARNING: Invalid value found in config',
        'Try removing the value.',
      ]),
    );
    expect(stderr.output, '');
  });

  test(
      'Given empty standard out '
      'when calling box '
      'then is logged correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.box(
        'Some information.',
      );
    });

    expect(
      stdout.output,
      '┌───────────────────┐\n'
      '│ Some information. │\n'
      '└───────────────────┘\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling box with newParagraph true '
      'then is logged correctly', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.box(
        'Some information.',
        newParagraph: true,
      );
    });

    expect(
      stdout.output,
      '\n'
      '┌───────────────────┐\n'
      '│ Some information. │\n'
      '└───────────────────┘\n',
    );
  });

  test(
      'Given empty standard out '
      'when calling raw '
      'then output is printed as is', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(() {
      commandLogger.raw('Some raw text');
    });

    expect(stdout.output, 'Some raw text');
  });

  test(
      'Given empty standard out that supports ANSI escapes '
      'when calling raw without a style '
      'then output is printed as is', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdout: MockStdout(supportsAnsiEscapes: true),
      () {
        commandLogger.raw('Some raw text');
      },
    );

    expect(stdout.output, 'Some raw text');
  });

  test(
      'Given empty standard out that does not support ANSI escapes '
      'when calling raw with style dark gray '
      'then output is printed as is', () async {
    final (:stdout, :stderr, :stdin) = await collectOutput(
      stdout: MockStdout(supportsAnsiEscapes: false),
      () {
        commandLogger.raw('Some raw text', style: AnsiStyle.darkGray);
      },
    );

    expect(stdout.output, 'Some raw text');
  });
}
