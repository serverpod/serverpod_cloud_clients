import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/package_graph/package_graph.dart';
import 'package:test/test.dart';

void main() {
  group('PackageGraphParser.fromJson -', () {
    test('Given a valid package_graph.json '
        'when parsed '
        'then roots and dependency edges are populated', () {
      final graph = PackageGraphParser.fromJson({
        'configVersion': 1,
        'roots': ['app'],
        'packages': [
          {
            'name': 'app',
            'version': '1.0.0',
            'dependencies': ['foo'],
            'devDependencies': ['test'],
          },
          {
            'name': 'foo',
            'version': '2.0.0',
            'dependencies': ['bar'],
          },
          {'name': 'bar', 'version': '3.0.0', 'dependencies': <String>[]},
          {'name': 'test', 'version': '1.25.0', 'dependencies': <String>[]},
        ],
      });

      expect(graph.roots, hasLength(1));
      final app = graph.roots.single;
      expect(app.name, 'app');
      expect(app.version, '1.0.0');
      expect(app.dependencies.map((final p) => p.name), ['foo']);
      expect(app.devDependencies.map((final p) => p.name), ['test']);

      final foo = app.dependencies.single;
      expect(foo.version, '2.0.0');
      expect(foo.dependencies.map((final p) => p.name), ['bar']);
      expect(foo.devDependencies, isEmpty);

      final bar = foo.dependencies.single;
      expect(bar.version, '3.0.0');
      expect(bar.dependencies, isEmpty);
    });

    test('Given packages with dependencies '
        'when parsed '
        'then references and devReferences point back to dependents', () {
      final graph = PackageGraphParser.fromJson({
        'configVersion': 1,
        'roots': ['app'],
        'packages': [
          {
            'name': 'app',
            'version': '1.0.0',
            'dependencies': ['foo'],
            'devDependencies': ['test'],
          },
          {'name': 'foo', 'version': '2.0.0', 'dependencies': <String>[]},
          {'name': 'test', 'version': '1.25.0', 'dependencies': <String>[]},
        ],
      });

      final app = graph.roots.single;
      final foo = app.dependencies.single;
      final testPackage = app.devDependencies.single;

      expect(foo.references, [same(app)]);
      expect(foo.devReferences, isEmpty);
      expect(testPackage.references, isEmpty);
      expect(testPackage.devReferences, [same(app)]);
      expect(app.references, isEmpty);
      expect(app.devReferences, isEmpty);
    });

    test('Given a cyclic dependency graph '
        'when parsed '
        'then both packages reference each other without hanging', () {
      final graph = PackageGraphParser.fromJson({
        'configVersion': 1,
        'roots': ['a'],
        'packages': [
          {
            'name': 'a',
            'version': '1.0.0',
            'dependencies': ['b'],
          },
          {
            'name': 'b',
            'version': '1.0.0',
            'dependencies': ['a'],
          },
        ],
      });

      final a = graph.roots.single;
      final b = a.dependencies.single;

      expect(identical(b.dependencies.single, a), isTrue);
      expect(a.references, [same(b)]);
      expect(a.devReferences, isEmpty);
      expect(b.references, [same(a)]);
      expect(b.devReferences, isEmpty);
    });

    test('Given multiple workspace roots '
        'when parsed '
        'then roots are returned in file order', () {
      final graph = PackageGraphParser.fromJson({
        'configVersion': 1,
        'roots': ['pkg_b', 'pkg_a'],
        'packages': [
          {'name': 'pkg_a', 'version': '0.0.0', 'dependencies': <String>[]},
          {'name': 'pkg_b', 'version': '0.0.0', 'dependencies': <String>[]},
        ],
      });

      expect(graph.roots.map((final p) => p.name), ['pkg_b', 'pkg_a']);
    });

    test('Given omitted optional dependency lists '
        'when parsed '
        'then empty lists are used', () {
      final graph = PackageGraphParser.fromJson({
        'configVersion': 1,
        'roots': ['leaf'],
        'packages': [
          {'name': 'leaf', 'version': '1.0.0'},
        ],
      });

      final leaf = graph.roots.single;
      expect(leaf.dependencies, isEmpty);
      expect(leaf.devDependencies, isEmpty);
      expect(leaf.references, isEmpty);
      expect(leaf.devReferences, isEmpty);
    });

    test('Given an unsupported configVersion '
        'when parsed '
        'then a FormatException is thrown', () {
      expect(
        () => PackageGraphParser.fromJson({
          'configVersion': 99,
          'roots': <String>[],
          'packages': <Map<String, Object>>[],
        }),
        throwsA(
          isA<FormatException>().having(
            (final e) => e.message,
            'message',
            contains('configVersion'),
          ),
        ),
      );
    });

    test('Given a dependency on an unknown package '
        'when parsed '
        'then a FormatException is thrown', () {
      expect(
        () => PackageGraphParser.fromJson({
          'configVersion': 1,
          'roots': ['app'],
          'packages': [
            {
              'name': 'app',
              'version': '1.0.0',
              'dependencies': ['missing'],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PackageGraphParser.fromFile / fromProjectDirectory -', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('package_graph_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('Given a project with .dart_tool/package_graph.json '
        'when loaded from the project directory '
        'then the graph is populated', () {
      final dartTool = Directory(p.join(tempDir.path, '.dart_tool'))
        ..createSync();
      File(p.join(dartTool.path, 'package_graph.json')).writeAsStringSync('''
{
  "configVersion": 1,
  "roots": ["app"],
  "packages": [
    {
      "name": "app",
      "version": "1.0.0",
      "dependencies": [],
      "devDependencies": []
    }
  ]
}
''');

      final graph = PackageGraphParser.fromProjectDirectory(tempDir);

      expect(graph.roots.single.name, 'app');
      expect(graph.roots.single.version, '1.0.0');
    });

    test('Given an invalid package_graph.json '
        'when loaded from file '
        'then a FormatException is thrown', () {
      final dartTool = Directory(p.join(tempDir.path, '.dart_tool'))
        ..createSync();
      File(p.join(dartTool.path, 'package_graph.json')).writeAsStringSync('''
{
  "configVersion": 1,
  "roots": ["app"],
  "packages": [
}
''');
      expect(
        () => PackageGraphParser.fromProjectDirectory(tempDir),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given a missing package_graph.json '
        'when loaded from file '
        'then a PackageGraphFileNotFoundException is thrown', () {
      final missing = File(p.join(tempDir.path, 'missing.json'));
      expect(
        () => PackageGraphParser.fromFile(missing),
        throwsA(isA<PackageGraphFileNotFoundException>()),
      );
    });
  });
}
