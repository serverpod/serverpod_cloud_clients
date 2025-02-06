import 'dart:io';

import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  final tempDir = Directory.systemTemp.createTempSync();
  final tempPath = tempDir.path;

  tearDown(() {
    tempDir.listSync().forEach((final file) => file.deleteSync());
  });

  test(
      'Given path does not exist '
      'when calling isServerpodServerDirectory '
      'then returns false', () async {
    expect(
      isServerpodServerDirectory(Directory('non_existing_path')),
      isFalse,
    );
  });

  group('Given path exists and pubspec is not a yaml map ', () {
    setUp(() async {
      final pubspecFile = File(path.join(tempPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('not a yaml map');
    });

    test(
        'when calling isServerpodServerDirectory '
        'then returns false', () async {
      expect(
        isServerpodServerDirectory(tempDir),
        isFalse,
      );
    });
  });

  group(
      'Given path exists and pubspec is valid yaml but does not contain dependencies ',
      () {
    setUp(() async {
      final pubspecFile = File(path.join(tempPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: myproject
''');
    });

    test(
        'when calling isServerpodServerDirectory '
        'then returns false', () async {
      expect(
        isServerpodServerDirectory(tempDir),
        isFalse,
      );
    });
  });

  group(
      'Given path exists and pubspec is valid yaml but does not contain serverpod dependency ',
      () {
    setUp(() async {
      final pubspecFile = File(path.join(tempPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: myproject
dependencies:
  test: ^1.0.0
''');
    });

    test(
        'when calling isServerpodServerDirectory '
        'then returns false', () async {
      expect(
        isServerpodServerDirectory(tempDir),
        isFalse,
      );
    });
  });

  group(
      'Given path exists and pubspec is valid yaml and contains serverpod dependency ',
      () {
    setUp(() async {
      final pubspecFile = File(path.join(tempPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: myproject
dependencies:
  serverpod: ^2.0.0
''');
    });

    test(
        'when calling isServerpodServerDirectory '
        'then returns true', () async {
      expect(
        isServerpodServerDirectory(tempDir),
        isTrue,
      );
    });
  });
}
