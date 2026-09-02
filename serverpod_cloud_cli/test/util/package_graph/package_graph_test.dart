import 'package:serverpod_cloud_cli/util/package_graph/package_graph.dart';
import 'package:test/test.dart';

void main() {
  group('PackageGraph.allPackageNames -', () {
    test('Given a graph with regular dependencies '
        'when collecting package names '
        'then roots and transitive dependencies are included', () {
      final bar = _package('bar');
      final foo = _package('foo', dependencies: [bar]);
      final app = _package('app', dependencies: [foo]);
      final graph = PackageGraph(roots: [app]);

      expect(graph.allPackageNames(), {'app', 'foo', 'bar'});
    });

    test('Given a package reachable only via a dev dependency '
        'when collecting package names without including them '
        'then that package is omitted', () {
      final testPkg = _package('test');
      final foo = _package('foo');
      final app = _package(
        'app',
        dependencies: [foo],
        devDependencies: [testPkg],
      );
      final graph = PackageGraph(roots: [app]);

      expect(graph.allPackageNames(), {'app', 'foo'});
      expect(graph.allPackageNames(false), {'app', 'foo'});
    });

    test('Given a package reachable only via a dev dependency '
        'when collecting package names including them '
        'then that package is included', () {
      final testPkg = _package('test');
      final foo = _package('foo');
      final app = _package(
        'app',
        dependencies: [foo],
        devDependencies: [testPkg],
      );
      final graph = PackageGraph(roots: [app]);

      expect(graph.allPackageNames(true), {'app', 'foo', 'test'});
    });

    test('Given multiple roots '
        'when collecting package names '
        'then packages from all roots are included', () {
      final shared = _package('shared');
      final appA = _package('app_a', dependencies: [shared]);
      final appB = _package('app_b', dependencies: [shared]);
      final graph = PackageGraph(roots: [appA, appB]);

      expect(graph.allPackageNames(), {'app_a', 'app_b', 'shared'});
    });

    test('Given a cyclic dependency graph '
        'when collecting package names '
        'then all packages are returned without hanging', () {
      final a = _package('a');
      final b = _package('b', dependencies: [a]);
      a.dependencies.add(b);
      final graph = PackageGraph(roots: [a]);

      expect(graph.allPackageNames(), {'a', 'b'});
    });

    test('Given a graph with no roots '
        'when collecting package names '
        'then an empty set is returned', () {
      final graph = PackageGraph(roots: []);

      expect(graph.allPackageNames(), isEmpty);
      expect(graph.allPackageNames(true), isEmpty);
    });
  });

  group('PackageGraph.unreachablePackages -', () {
    test('Given a retained root with exclusive and shared dependencies '
        'when computing unreachable packages '
        'then packages only needed by other roots are unreachable', () {
      final shared = _package('shared');
      final onlyA = _package('only_a');
      final onlyB = _package('only_b');
      final appA = _package('app_a', dependencies: [onlyA, shared]);
      final appB = _package('app_b', dependencies: [onlyB, shared]);
      final graph = PackageGraph(roots: [appA, appB]);

      final (unreachable, demoted) = graph.unreachablePackages(['app_a']);

      expect(unreachable, {'app_b', 'only_b'});
      expect(demoted, isEmpty);
    });

    test('Given a package that is a direct dependency of another root '
        'but only transitive for the retained root '
        'when computing unreachable packages '
        'then that package is demoted to transitive', () {
      final bar = _package('bar');
      final foo = _package('foo', dependencies: [bar]);
      final appA = _package('app_a', dependencies: [foo]);
      final appB = _package('app_b', dependencies: [bar]);
      final graph = PackageGraph(roots: [appA, appB]);

      final (unreachable, demoted) = graph.unreachablePackages(['app_a']);

      expect(unreachable, {'app_b'});
      expect(demoted, {'bar'});
    });

    test('Given a package that remains a direct dependency of a retained root '
        'when computing unreachable packages '
        'then that package is not demoted', () {
      final shared = _package('shared');
      final appA = _package('app_a', dependencies: [shared]);
      final appB = _package('app_b', dependencies: [shared]);
      final graph = PackageGraph(roots: [appA, appB]);

      final (unreachable, demoted) = graph.unreachablePackages(['app_a']);

      expect(unreachable, {'app_b'});
      expect(demoted, isEmpty);
    });

    test('Given a package reachable only via a retained root dev dependency '
        'when computing unreachable packages '
        'then that package is unreachable', () {
      final testPkg = _package('test');
      final foo = _package('foo');
      final app = _package(
        'app',
        dependencies: [foo],
        devDependencies: [testPkg],
      );
      final graph = PackageGraph(roots: [app]);

      final (unreachable, demoted) = graph.unreachablePackages(['app']);

      expect(unreachable, {'test'});
      expect(demoted, isEmpty);
    });

    test('Given multiple retained roots '
        'when computing unreachable packages '
        'then packages reachable from any retained root remain', () {
      final onlyA = _package('only_a');
      final onlyB = _package('only_b');
      final onlyC = _package('only_c');
      final appA = _package('app_a', dependencies: [onlyA]);
      final appB = _package('app_b', dependencies: [onlyB]);
      final appC = _package('app_c', dependencies: [onlyC]);
      final graph = PackageGraph(roots: [appA, appB, appC]);

      final (unreachable, demoted) = graph.unreachablePackages([
        'app_a',
        'app_b',
      ]);

      expect(unreachable, {'app_c', 'only_c'});
      expect(demoted, isEmpty);
    });

    test('Given all roots are retained '
        'when computing unreachable packages '
        'then nothing is unreachable or demoted', () {
      final shared = _package('shared');
      final appA = _package('app_a', dependencies: [shared]);
      final appB = _package('app_b', dependencies: [shared]);
      final graph = PackageGraph(roots: [appA, appB]);

      final (unreachable, demoted) = graph.unreachablePackages([
        'app_a',
        'app_b',
      ]);

      expect(unreachable, isEmpty);
      expect(demoted, isEmpty);
    });

    test('Given an empty retained package list '
        'when computing unreachable packages '
        'then every package is unreachable', () {
      final foo = _package('foo');
      final app = _package('app', dependencies: [foo]);
      final graph = PackageGraph(roots: [app]);

      final (unreachable, demoted) = graph.unreachablePackages([]);

      expect(unreachable, {'app', 'foo'});
      expect(demoted, isEmpty);
    });

    test('Given a cyclic dependency among retained packages '
        'when computing unreachable packages '
        'then cycles are handled without hanging', () {
      final a = _package('a');
      final b = _package('b', dependencies: [a]);
      a.dependencies.add(b);
      final other = _package('other');
      final graph = PackageGraph(roots: [a, other]);

      final (unreachable, demoted) = graph.unreachablePackages(['a']);

      expect(unreachable, {'other'});
      expect(demoted, isEmpty);
    });

    test('Given a package name that is not a root '
        'when computing unreachable packages '
        'then an ArgumentError is thrown', () {
      final foo = _package('foo');
      final app = _package('app', dependencies: [foo]);
      final graph = PackageGraph(roots: [app]);

      expect(
        () => graph.unreachablePackages(['foo']),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('not a "root" package'),
          ),
        ),
      );
    });

    test('Given a retained root that is also a direct dependency of another '
        'root '
        'when computing unreachable packages '
        'then the retained root is not demoted', () {
      final appA = _package('app_a');
      final appB = _package('app_b', dependencies: [appA]);
      final graph = PackageGraph(roots: [appA, appB]);

      final (unreachable, demoted) = graph.unreachablePackages(['app_a']);

      expect(unreachable, {'app_b'});
      expect(demoted, isEmpty);
    });
  });
}

PgPackage _package(
  String name, {
  List<PgPackage> dependencies = const [],
  List<PgPackage> devDependencies = const [],
}) {
  return PgPackage(
    name: name,
    version: '1.0.0',
    dependencies: List.of(dependencies),
    devDependencies: List.of(devDependencies),
    references: [],
    devReferences: [],
  );
}
