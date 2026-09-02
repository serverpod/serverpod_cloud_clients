/// A parsed `.dart_tool/package_graph.json` dependency graph.
///
/// Edges can be traversed forwards via [PgPackage.dependencies] /
/// [PgPackage.devDependencies] and backwards via [PgPackage.references] /
/// [PgPackage.devReferences]. The graph may contain cycles.
final class PackageGraph {
  /// Workspace root packages, in the order listed in the file.
  final List<PgPackage> roots;

  PackageGraph({required this.roots});

  /// Returns the names of all packages.
  Set<String> allPackageNames([bool includeDevDependencies = false]) {
    return {
      for (final package in _collectAllPackages(includeDevDependencies))
        package.name,
    };
  }

  /// Returns package names in this graph that are not reachable as regular
  /// dependencies from [packageNames], and package names that remain reachable
  /// but change from a direct root dependency to a transitive-only dependency of
  /// [packageNames].
  ///
  /// Only follows [PgPackage.dependencies] (dev dependencies are ignored).
  /// Throws if any name in [packageNames] is not a root package in this graph.
  (Set<String> unreachable, Set<String> demotedToTransitive)
  unreachablePackages(Iterable<String> packageNames) {
    final rootsByName = {for (final root in roots) root.name: root};

    final startPackages = <PgPackage>[];
    for (final name in packageNames) {
      final root = rootsByName[name];
      if (root == null) {
        throw ArgumentError.value(
          name,
          'packageNames',
          'Package is not a "root" package in the workspace PackageGraph',
        );
      }
      startPackages.add(root);
    }

    final specifiedNames = {for (final package in startPackages) package.name};
    final allPackages = _collectAllPackages(true);
    final reachable = _reachableViaDependencies(startPackages);

    final directDepsOfAnyRoot = {
      for (final root in roots)
        for (final dependency in root.dependencies) dependency.name,
    };
    final directDepsOfSpecified = {
      for (final root in startPackages)
        for (final dependency in root.dependencies) dependency.name,
    };

    return (
      {
        for (final package in allPackages)
          if (!reachable.contains(package.name)) package.name,
      },
      {
        for (final name in reachable)
          if (directDepsOfAnyRoot.contains(name) &&
              !directDepsOfSpecified.contains(name) &&
              !specifiedNames.contains(name))
            name,
      },
    );
  }

  Set<PgPackage> _collectAllPackages(bool includeDevDependencies) {
    final visited = <PgPackage>{};
    final queue = List<PgPackage>.of(roots);

    while (queue.isNotEmpty) {
      final package = queue.removeLast();
      if (!visited.add(package)) {
        continue;
      }
      queue.addAll(package.dependencies);
      if (includeDevDependencies) {
        queue.addAll(package.devDependencies);
      }
    }

    return visited;
  }

  static Set<String> _reachableViaDependencies(List<PgPackage> startPackages) {
    final visited = <PgPackage>{};
    final queue = List<PgPackage>.of(startPackages);

    while (queue.isNotEmpty) {
      final package = queue.removeLast();
      if (!visited.add(package)) {
        continue;
      }
      queue.addAll(package.dependencies);
    }

    return {for (final package in visited) package.name};
  }
}

/// A package node in a [PackageGraph].
final class PgPackage {
  final String name;
  final String version;
  final List<PgPackage> dependencies;
  final List<PgPackage> devDependencies;

  /// Packages that list this package as a regular dependency.
  final List<PgPackage> references;

  /// Packages that list this package as a dev dependency.
  final List<PgPackage> devReferences;

  PgPackage({
    required this.name,
    required this.version,
    required this.dependencies,
    required this.devDependencies,
    required this.references,
    required this.devReferences,
  });
}
