import 'dart:io';

import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'package:serverpod_cloud_cli/util/tool_versions_reader.dart';

void main() {
  group('ToolVersionsReader.readDartVersion -', () {
    test(
      'Given no .tool-versions file when reading dart version '
      'then returns null',
      () async {
        await d.dir('project', []).create();
        final dir = Directory(d.sandbox);

        expect(ToolVersionsReader.readDartVersion(dir), isNull);
      },
    );

    test(
      'Given .tool-versions with dart entry when reading dart version '
      'then returns the version',
      () async {
        await d.dir('project', [
          d.file('.tool-versions', 'dart 3.9.5\n'),
        ]).create();
        final dir = Directory(d.path('project'));

        expect(ToolVersionsReader.readDartVersion(dir), equals('3.9.5'));
      },
    );

    test(
      'Given .tool-versions with multiple tools when reading dart version '
      'then returns the dart version',
      () async {
        await d.dir('project2', [
          d.file('.tool-versions', 'flutter 3.29.0\ndart 3.10.0\nnodejs 20.0.0\n'),
        ]).create();
        final dir = Directory(d.path('project2'));

        expect(ToolVersionsReader.readDartVersion(dir), equals('3.10.0'));
      },
    );

    test(
      'Given .tool-versions without dart entry when reading dart version '
      'then returns null',
      () async {
        await d.dir('project3', [
          d.file('.tool-versions', 'flutter 3.29.0\nnodejs 20.0.0\n'),
        ]).create();
        final dir = Directory(d.path('project3'));

        expect(ToolVersionsReader.readDartVersion(dir), isNull);
      },
    );

    test(
      'Given .tool-versions with comment lines when reading dart version '
      'then returns the version ignoring comments',
      () async {
        await d.dir('project4', [
          d.file('.tool-versions', '# dart 3.8.0\ndart 3.9.1\n'),
        ]).create();
        final dir = Directory(d.path('project4'));

        expect(ToolVersionsReader.readDartVersion(dir), equals('3.9.1'));
      },
    );

    test(
      'Given .tool-versions with dart entry and trailing comment '
      'when reading dart version then returns only the version',
      () async {
        await d.dir('project5', [
          d.file(
            '.tool-versions',
            'dart 3.9.5  https://github.com/dart-lang/sdk\n',
          ),
        ]).create();
        final dir = Directory(d.path('project5'));

        expect(ToolVersionsReader.readDartVersion(dir), equals('3.9.5'));
      },
    );

    test(
      'Given empty .tool-versions file when reading dart version '
      'then returns null',
      () async {
        await d.dir('project6', [
          d.file('.tool-versions', ''),
        ]).create();
        final dir = Directory(d.path('project6'));

        expect(ToolVersionsReader.readDartVersion(dir), isNull);
      },
    );
  });
}
