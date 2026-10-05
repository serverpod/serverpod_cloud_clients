import 'dart:io';

import 'package:async/async.dart';

/// Executes [command] in a child process shell and returns the exit code.
///
/// Works like `execute` from `package:cli_tools`, and also accepts an
/// [environment] that is added to the parent process environment.
///
/// The child output is forwarded to [stdout] and [stderr], and SIGINT and
/// SIGTERM received by the parent are forwarded to the child while it runs.
Future<int> executeShellCommand(
  String command, {
  required IOSink stdout,
  required IOSink stderr,
  Directory? workingDirectory,
  Map<String, String>? environment,
}) async {
  final shell = Platform.isWindows ? 'cmd' : 'bash';
  final shellArg = Platform.isWindows ? '/c' : '-c';

  final process = await Process.start(
    shell,
    [shellArg, command],
    workingDirectory: (workingDirectory ?? Directory.current).path,
    environment: environment,
  );

  final sigSubscription = StreamGroup.merge(
    [
      ProcessSignal.sigint,
      if (!Platform.isWindows) ProcessSignal.sigterm,
    ].map((s) => s.watch()),
  ).listen(process.kill);

  await [
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ].wait;
  await process.stdin.close();
  await sigSubscription.cancel();

  return process.exitCode;
}
