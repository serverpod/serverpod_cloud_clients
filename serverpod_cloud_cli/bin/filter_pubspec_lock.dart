// TODO: Move this to the serverpod_cloud_shared package when available.
// https://linear.app/serverpod/issue/CLD-1129/move-packagesserverpod-cloud-clibinfilter-pubspec-lockdart-into
import 'dart:io';

import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/util/package_graph/package_graph.dart';

enum FilterPubspecLockOption<V> implements OptionDefinition<V> {
  workspaceRoot(
    DirOption(
      argName: 'workspace-root',
      argAbbrev: 'w',
      helpText:
          'Directory containing pubspec.lock and .dart_tool/package_graph.json',
      fromDefault: _defaultWorkspaceRoot,
      mode: PathExistMode.mustExist,
    ),
  ),
  package(
    MultiStringOption.noSplit(
      argName: 'package',
      argAbbrev: 'p',
      helpText:
          'Workspace root package name(s) to retain '
          '(repeatable). Only regular dependencies are followed.',
      mandatory: true,
    ),
  ),
  output(
    FileOption(
      argName: 'output',
      argAbbrev: 'o',
      helpText: 'Path to write the filtered pubspec.lock',
      mandatory: true,
    ),
  ),
  lockfile(
    FileOption(
      argName: 'lockfile',
      argAbbrev: 'l',
      helpText:
          'Input pubspec.lock path '
          '(defaults to <workspace-root>/pubspec.lock)',
      mode: PathExistMode.mustExist,
    ),
  ),
  help(
    FlagOption(
      argName: 'help',
      argAbbrev: 'h',
      helpText: 'Print this usage information.',
      defaultsTo: false,
      negatable: false,
    ),
  );

  const FilterPubspecLockOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

Directory _defaultWorkspaceRoot() => Directory('.');

/// Filters a Dart workspace `pubspec.lock` to the packages reachable as
/// regular dependencies from one or more workspace root packages.
///
/// Uses the same graph walk and lockfile rewrite as `scloud` deploy
/// ([PubspecLockFilter] / [PackageGraph.unreachablePackages]).
///
/// Example (from the monorepo root, after `dart pub get`):
/// ```
/// dart run packages/serverpod_cloud_cli/bin/filter_pubspec_lock.dart \
///   --workspace-root . \
///   --package ground_control_server \
///   --output ground_control/ground_control_server/pubspec_ws_root.lock
/// ```
void main(final List<String> arguments) {
  final config = Configuration.resolveNoExcept(
    options: FilterPubspecLockOption.values,
    args: arguments,
    env: Platform.environment,
  );

  if (config.optionalValue(FilterPubspecLockOption.help) ?? false) {
    stdout.writeln(config.usage);
    exit(0);
  }

  try {
    config.throwExceptionOnErrors();
  } on UsageException catch (e) {
    stderr.writeln('$e');
    exit(64);
  }

  final packages = config.value(FilterPubspecLockOption.package);
  final outputFile = config.value(FilterPubspecLockOption.output);
  final workspaceRoot = p.normalize(
    p.absolute(config.value(FilterPubspecLockOption.workspaceRoot).path),
  );
  final lockfileOption = config.optionalValue(FilterPubspecLockOption.lockfile);
  final inputLockfile = lockfileOption != null
      ? p.normalize(p.absolute(lockfileOption.path))
      : p.join(workspaceRoot, 'pubspec.lock');

  try {
    final graph = PackageGraphParser.fromProjectDirectory(
      Directory(workspaceRoot),
    );
    final allPackages = graph.allPackageNames();
    final (unreachable, demotedToTransitive) = graph.unreachablePackages(
      packages,
    );
    final expectedRemainingPackages = allPackages.difference(unreachable);

    final lockContent = File(inputLockfile).readAsStringSync();
    final (filteredContent, unexpectedPackages) = PubspecLockFilter.filter(
      content: lockContent,
      packagesToRemove: unreachable,
      packagesToDemote: demotedToTransitive,
      expectedRemainingPackages: expectedRemainingPackages,
      scriptName: 'filter_pubspec_lock.dart',
    );

    if (unexpectedPackages.isNotEmpty) {
      stderr.writeln(
        'Filtered lockfile still contains unexpected packages: '
        '${unexpectedPackages.join(', ')}',
      );
      exit(1);
    }

    final resolvedOutput = File(p.normalize(p.absolute(outputFile.path)));
    resolvedOutput.parent.createSync(recursive: true);
    resolvedOutput.writeAsStringSync(filteredContent);

    stdout.writeln(
      'Wrote filtered pubspec.lock for ${packages.join(', ')} '
      'to ${resolvedOutput.path} '
      '(removed ${unreachable.length} packages, '
      'demoted ${demotedToTransitive.length}).',
    );
  } on PackageGraphFileNotFoundException catch (e) {
    stderr.writeln(
      'Package graph not found at `${e.projectPath}`. Run "dart pub get".',
    );
    exit(1);
  } on FileSystemException catch (e) {
    stderr.writeln('File error: $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exit(1);
  } on ArgumentError catch (e) {
    stderr.writeln(e.message);
    exit(1);
  }
}
