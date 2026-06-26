// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

/// Manual demo for the inline_tui scrolling section.
///
/// Runs a short-lived subprocess whose output is tailed within a fixed number
/// of rows, then demonstrates both completion options (clear and keep).
///
/// Run with: `dart run example/inline_tui_scrolling_section_demo.dart`
Future<void> main() async {
  final tempDir = Directory.systemTemp.createTempSync('scrolling_demo');
  final scriptFile = File(p.join(tempDir.path, 'emitter.dart'))
    ..writeAsStringSync(_emitterScript);

  final terminal = StdioTerminal();
  try {
    print('Building (output scrolls within 5 rows):');
    final success = await ScrollingProcess.run(Platform.resolvedExecutable, [
      scriptFile.path,
      '20',
    ], terminal: terminal);
    // On success, clear the scrolling output and show a summary instead.
    if (success.succeeded) {
      success.clear();
      print('Build finished successfully.');
    } else {
      // On failure, keep the last output lines visible to aid debugging.
      success.keep();
      print('Build failed with exit code ${success.exitCode}.');
    }

    print('\nRunning again, keeping the tail this time:');
    final result = await ScrollingProcess.run(
      Platform.resolvedExecutable,
      [scriptFile.path, '12'],
      rows: 5,
      terminal: terminal,
    );
    result.keep();
    print('Done.');
  } finally {
    await terminal.dispose();
    tempDir.deleteSync(recursive: true);
  }
}

const String _emitterScript = r'''
import 'dart:io';

Future<void> main(final List<String> args) async {
  final count = args.isEmpty ? 20 : int.parse(args.first);
  for (var i = 1; i <= count; i++) {
    stdout.writeln('[$i/$count] processing step ...');
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}
''';
