import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/project_serverpod_cli.dart';
import 'package:serverpod_cloud_cli/util/shell_command.dart';
import 'package:test/test.dart';

void main() {
  group('Given a created project Serverpod CLI', () {
    late ProjectServerpodCli serverpodCli;

    setUp(() async {
      serverpodCli = await ProjectServerpodCli.create();
    });

    tearDown(() async {
      await serverpodCli.delete();
    });

    test('when a shell resolves serverpod with its environment '
        'then the wrapper script is found first', () async {
      final output = await _runShellCommand(
        _resolveServerpodCommand,
        environment: serverpodCli.environment,
      );

      final resolvedPath = LineSplitter.split(output).first.trim();
      expect(p.isWithin(serverpodCli.directory.path, resolvedPath), isTrue);
    });

    test('when reading the wrapper script '
        'then it runs serverpod_cli with dart run', () async {
      final scripts = serverpodCli.directory.listSync().whereType<File>();

      expect(
        scripts.single.readAsStringSync(),
        contains('dart run serverpod_cli'),
      );
    });

    test('when deleted then the wrapper directory is removed', () async {
      await serverpodCli.delete();

      expect(serverpodCli.directory.existsSync(), isFalse);
    });
  });
}

final _resolveServerpodCommand = Platform.isWindows
    ? 'where serverpod'
    : 'command -v serverpod';

Future<String> _runShellCommand(
  String command, {
  required Map<String, String> environment,
}) async {
  final controller = StreamController<List<int>>();
  final output = controller.stream.transform(utf8.decoder).join();
  final sink = IOSink(controller.sink);
  await executeShellCommand(
    command,
    stdout: sink,
    stderr: stderr,
    environment: environment,
  );
  await sink.close();
  return output;
}
