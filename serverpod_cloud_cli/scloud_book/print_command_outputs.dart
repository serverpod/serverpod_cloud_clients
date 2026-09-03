/// Prints markdown showing the outputs of the main scloud subcommands.
///
/// Invokes [CloudCliCommandRunner] in-process with a mocked API client, the
/// same way as the CLI integration tests. No backend or child process is used.
/// Interactive or long-running commands such as deploy, launch, auth login,
/// log --tail, and deployment show with --await are omitted.
///
/// Usage, from `packages/serverpod_cloud_cli`:
///
/// ```sh
/// dart run scloud_book/print_command_outputs.dart
/// dart run scloud_book/print_command_outputs.dart --format json
/// dart run scloud_book/print_command_outputs.dart --format yaml
/// ```
library;

import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_auth_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_cloud_cli/shared/base_command.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show OutputFormat;
import 'package:serverpod_cloud_cli/util/scloud_version.dart';

import '../test_utils/render_command_ui.dart';
import 'stub_cloud_client.dart';

const _projectId = 'my-project';

class _Scenario {
  const _Scenario(this.heading, this.args);

  final String heading;
  final List<String> args;
}

const _scenarios = [
  _Scenario('version', ['version']),
  _Scenario('settings', ['settings']),
  _Scenario('settings', ['settings', '--no-analytics']),
  _Scenario('context show', ['context', 'show']),
  _Scenario('context set', ['context', 'set', _projectId]),
  _Scenario('context list', ['context', 'list']),
  _Scenario('context unset', ['context', 'unset']),
  _Scenario('me', ['me']),
  _Scenario('auth list', ['auth', 'list']),
  _Scenario('auth create-token', ['auth', 'create-token']),
  _Scenario('auth logout', ['auth', 'logout']),
  _Scenario('project list', ['project', 'list']),
  _Scenario('project list', ['project', 'list', '--all']),
  _Scenario('project delete', ['project', 'delete', _projectId]),
  _Scenario('project user list', [
    'project',
    'user',
    'list',
    '--project',
    _projectId,
  ]),
  _Scenario('project user invite', [
    'project',
    'user',
    'invite',
    'user@example.com',
    '--project',
    _projectId,
  ]),
  _Scenario('variable list', ['variable', 'list', '--project', _projectId]),
  _Scenario('variable set', [
    'variable',
    'set',
    'LOG_LEVEL',
    'debug',
    '--project',
    _projectId,
  ]),
  _Scenario('password list', ['password', 'list', '--project', _projectId]),
  _Scenario('password set', [
    'password',
    'set',
    'database',
    'secret-value',
    '--project',
    _projectId,
  ]),
  _Scenario('domain list', ['domain', 'list', '--project', _projectId]),
  _Scenario('domain attach', [
    'domain',
    'attach',
    'example.com',
    'api',
    '--project',
    _projectId,
  ]),
  _Scenario('log', ['log', '--project', _projectId]),
  _Scenario('log', ['log', '--project', _projectId, '--utc']),
  _Scenario('status', ['status', '--project', _projectId]),
  _Scenario('deployment list', ['deployment', 'list', '--project', _projectId]),
  _Scenario('deployment show', [
    'deployment',
    'show',
    '--no-await',
    '--project',
    _projectId,
  ]),
  _Scenario('deployment build-secret list', [
    'deployment',
    'build-secret',
    'list',
    '--project',
    _projectId,
  ]),
  _Scenario('db connection', ['db', 'connection', '--project', _projectId]),
  _Scenario('db backup list', [
    'db',
    'backup',
    'list',
    '--project',
    _projectId,
  ]),
  _Scenario('db schedule show', [
    'db',
    'schedule',
    'show',
    '--project',
    _projectId,
  ]),
  _Scenario('admin list-users', ['admin', 'list-users']),
  _Scenario('admin project list', ['admin', 'project', 'list']),
  _Scenario('admin product list-procured', [
    'admin',
    'product',
    'list-procured',
    'user@example.com',
  ]),
  _Scenario('admin plan list', ['admin', 'plan', 'list']),
  _Scenario('admin redeploy', ['admin', 'redeploy', _projectId]),
];

Future<void> main(final List<String> args) async {
  final format = _parseFormat(args);
  final configDir = Directory.systemTemp.createTempSync('scloud-output-');

  try {
    await _prepareConfigDir(configDir);
    await _printOutputs(configDir: configDir, format: format);
  } finally {
    if (configDir.existsSync()) {
      configDir.deleteSync(recursive: true);
    }
  }
}

OutputFormat _parseFormat(final List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--format') {
      if (i + 1 >= args.length) {
        stderr.writeln(
          'Missing value for --format. Use ${OutputFormat.values.map((final f) => f.name).join('|')}.',
        );
        exit(64);
      }
      final value = args[i + 1];
      for (final format in OutputFormat.values) {
        if (format.name == value) {
          return format;
        }
      }
      stderr.writeln(
        'Unknown format "$value". Use ${OutputFormat.values.map((final f) => f.name).join('|')}.',
      );
      exit(64);
    }
  }
  return OutputFormat.text;
}

Future<void> _prepareConfigDir(final Directory configDir) async {
  final logger = CommandLogger.create();
  await ResourceManager.storeServerpodCloudAuthData(
    authData: ServerpodCloudAuthData('test-token'),
    localStoragePath: configDir.path,
  );
  await ResourceManager.storeLatestCliVersion(
    cliVersionData: PackageVersionData(
      cliVersion,
      DateTime.now().add(const Duration(days: 1)),
    ),
    logger: logger,
    localStoragePath: configDir.path,
  );
}

Future<void> _printOutputs({
  required final Directory configDir,
  required final OutputFormat format,
}) async {
  final logger = CommandLogger.create();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  stubCloudClient(client, projectId: _projectId);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final _) => client,
    ),
    adminUserMode: true,
    baseCommand: defaultBaseCommand,
  );

  String? lastHeading;
  for (final scenario in _scenarios) {
    if (lastHeading != scenario.heading) {
      if (lastHeading != null) {
        stdout.writeln();
      }
      stdout.writeln('## ${scenario.heading}');
      lastHeading = scenario.heading;
    }

    final captured = await _runScenario(
      cli: cli,
      configDir: configDir,
      format: format,
      args: scenario.args,
    );

    if (scenario.heading == 'auth logout') {
      await ResourceManager.storeServerpodCloudAuthData(
        authData: ServerpodCloudAuthData('test-token'),
        localStoragePath: configDir.path,
      );
    }

    stdout.writeln();
    stdout.writeln('```');
    stdout.writeln(_displayedCommand(scenario.args, format: format));
    if (captured.isNotEmpty) {
      stdout.write(captured);
      if (!captured.endsWith('\n')) {
        stdout.writeln();
      }
    }
    stdout.writeln('```');
  }
}

Future<String> _runScenario({
  required final CloudCliCommandRunner cli,
  required final Directory configDir,
  required final OutputFormat format,
  required final List<String> args,
}) async {
  final runArgs = [
    '--config-dir',
    configDir.path,
    '--no-warn-billing-overdue',
    '--no-breaking-version-check',
    ..._visibleGlobalFlags(format),
    ...args,
  ];

  final io = await captureStdio(() async {
    try {
      await cli.run(runArgs);
    } on Object catch (error) {
      stderr.writeln(error);
    }
  });

  final buffer = StringBuffer();
  if (io.stdout.isNotEmpty) {
    buffer.write(io.stdout);
  }
  if (io.stderr.isNotEmpty) {
    if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
      buffer.writeln();
    }
    buffer.write(io.stderr);
  }
  return buffer.toString();
}

String _displayedCommand(
  final List<String> args, {
  required final OutputFormat format,
}) {
  return '\$ $defaultBaseCommand ${[..._visibleGlobalFlags(format), ...args].join(' ')}';
}

List<String> _visibleGlobalFlags(final OutputFormat format) {
  return [
    if (format != OutputFormat.text) ...['--format', format.name],
    '--yes',
  ];
}
