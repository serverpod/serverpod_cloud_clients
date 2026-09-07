import 'dart:async';
import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart';

import 'mock_stdin.dart';
import 'mock_stdout.dart';

Future<({String stdout, String stderr})> captureStdio(
  final FutureOr<void> Function() body,
) async {
  final stdout = MockStdout();
  final stderr = MockStdout();
  await IOOverrides.runZoned(
    () async {
      await body();
    },
    stdout: () => stdout,
    stderr: () => stderr,
    stdin: () => MockStdin([]),
  );
  return (stdout: stdout.output, stderr: stderr.output);
}

Future<({String stdout, String stderr})> renderCommandUi(
  final OutputWidget ui, {
  final Object? data,
}) {
  return captureStdio(() async {
    await ui
        .buildTree(OutputContext(OutputFormat.text, data))
        .renderTree(logger: CommandLogger.create());
  });
}
