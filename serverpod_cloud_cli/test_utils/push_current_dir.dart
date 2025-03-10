import 'dart:io';

import 'package:test/test.dart';

/// Pushes the current directory to a new path
/// and restores (pops) the original value after the test.
void pushCurrentDirectory(final String path) {
  final pushed = Directory(path);
  final original = Directory.current;
  Directory.current = pushed;

  addTearDown(() {
    Directory.current = original;
  });
}
