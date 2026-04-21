import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/tool_versions_io.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('ToolVersionsIO.readDartVersionFromToolVersions -', () {
    test('Given no .tool-versions file when reading dart version '
        'then returns null', () async {
      await d.dir('project', []).create();
      final dir = Directory(d.sandbox);

      expect(ToolVersionsIO.readDartVersionFromToolVersions([dir]), isNull);
    });

    test('Given .tool-versions with dart entry when reading dart version '
        'then returns the version', () async {
      await d.dir('project', [
        d.file('.tool-versions', 'dart 3.9.5\n'),
      ]).create();
      final dir = Directory(d.path('project'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([dir]),
        equals('3.9.5'),
      );
    });

    test('Given .tool-versions with multiple tools when reading dart version '
        'then returns the dart version', () async {
      await d.dir('project2', [
        d.file(
          '.tool-versions',
          'flutter 3.29.0\ndart 3.10.0\nnodejs 20.0.0\n',
        ),
      ]).create();
      final dir = Directory(d.path('project2'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([dir]),
        equals('3.10.0'),
      );
    });

    test('Given .tool-versions without dart entry when reading dart version '
        'then returns null', () async {
      await d.dir('project3', [
        d.file('.tool-versions', 'flutter 3.29.0\nnodejs 20.0.0\n'),
      ]).create();
      final dir = Directory(d.path('project3'));

      expect(ToolVersionsIO.readDartVersionFromToolVersions([dir]), isNull);
    });

    test('Given .tool-versions with comment lines when reading dart version '
        'then returns the version ignoring comments', () async {
      await d.dir('project4', [
        d.file('.tool-versions', '# dart 3.8.0\ndart 3.9.1\n'),
      ]).create();
      final dir = Directory(d.path('project4'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([dir]),
        equals('3.9.1'),
      );
    });

    test('Given .tool-versions with dart entry and trailing comment '
        'when reading dart version then returns only the version', () async {
      await d.dir('project5', [
        d.file(
          '.tool-versions',
          'dart 3.9.5  https://github.com/dart-lang/sdk\n',
        ),
      ]).create();
      final dir = Directory(d.path('project5'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([dir]),
        equals('3.9.5'),
      );
    });

    test('Given empty .tool-versions file when reading dart version '
        'then returns null', () async {
      await d.dir('project6', [d.file('.tool-versions', '')]).create();
      final dir = Directory(d.path('project6'));

      expect(ToolVersionsIO.readDartVersionFromToolVersions([dir]), isNull);
    });

    test('Given first search root has dart when multiple roots '
        'then returns that version', () async {
      await d.dir('order_first', [
        d.file('.tool-versions', 'dart 3.9.0\n'),
        d.dir('other', [d.file('.tool-versions', 'dart 3.10.0\n')]),
      ]).create();
      final first = Directory(d.path('order_first'));
      final second = Directory(d.path('order_first/other'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([first, second]),
        equals('3.9.0'),
      );
    });

    test('Given first search root has no dart when multiple roots '
        'then returns dart from a later root', () async {
      await d.dir('order_second', [
        d.dir('server', []),
        d.file('.tool-versions', 'dart 3.10.2\n'),
      ]).create();
      final first = Directory(d.path('order_second/server'));
      final second = Directory(d.path('order_second'));

      expect(
        ToolVersionsIO.readDartVersionFromToolVersions([first, second]),
        equals('3.10.2'),
      );
    });

    test(
      'Given duplicate search roots when reading then skips duplicates',
      () async {
        await d.dir('order_dup', [
          d.file('.tool-versions', 'dart 3.8.1\n'),
        ]).create();
        final dir = Directory(d.path('order_dup'));

        expect(
          ToolVersionsIO.readDartVersionFromToolVersions([dir, dir]),
          equals('3.8.1'),
        );
      },
    );
  });

  group('ToolVersionsIO.writeDartVersion -', () {
    test(
      'Given no .tool-versions file when writing then does not create file',
      () async {
        await d.dir('write_no_file').create();
        final dir = Directory(d.path('write_no_file'));

        ToolVersionsIO.writeDartVersion(dir, '3.9.0');

        expect(
          File(
            p.join(d.sandbox, 'write_no_file', '.tool-versions'),
          ).existsSync(),
          isFalse,
        );
      },
    );

    test(
      'Given .tool-versions with dart entry when writing then updates the version',
      () async {
        await d.dir('write_update', [
          d.file('.tool-versions', 'dart 3.8.0\n'),
        ]).create();
        final dir = Directory(d.path('write_update'));

        ToolVersionsIO.writeDartVersion(dir, '3.9.0');

        final content = File(
          p.join(d.sandbox, 'write_update', '.tool-versions'),
        ).readAsStringSync();
        expect(content, contains('dart 3.9.0'));
        expect(content, isNot(contains('dart 3.8.0')));
      },
    );

    test(
      'Given .tool-versions with multiple tools when writing then preserves other tools',
      () async {
        await d.dir('write_preserve', [
          d.file(
            '.tool-versions',
            'flutter 3.29.0\ndart 3.8.0\nnodejs 20.0.0\n',
          ),
        ]).create();
        final dir = Directory(d.path('write_preserve'));

        ToolVersionsIO.writeDartVersion(dir, '3.9.0');

        final content = File(
          p.join(d.sandbox, 'write_preserve', '.tool-versions'),
        ).readAsStringSync();
        expect(content, contains('dart 3.9.0'));
        expect(content, contains('flutter 3.29.0'));
        expect(content, contains('nodejs 20.0.0'));
      },
    );

    test(
      'Given .tool-versions without dart entry when writing then adds dart entry',
      () async {
        await d.dir('write_add', [
          d.file('.tool-versions', 'flutter 3.29.0\n'),
        ]).create();
        final dir = Directory(d.path('write_add'));

        ToolVersionsIO.writeDartVersion(dir, '3.9.0');

        final content = File(
          p.join(d.sandbox, 'write_add', '.tool-versions'),
        ).readAsStringSync();
        expect(content, contains('dart 3.9.0'));
        expect(content, contains('flutter 3.29.0'));
      },
    );
  });
}
