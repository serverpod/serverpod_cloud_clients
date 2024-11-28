import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/features/status/status.dart';
import 'package:serverpod_cloud_cli/features/logs/logs.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

abstract final class _StatusOptions {
  static const projectId = ProjectIdOption();
  static const limit = ConfigOption(
    argName: 'limit',
    helpText: 'The maximum number of records to fetch.',
    defaultsTo: '10',
  );
  static const utc = ConfigOption(
    argName: 'utc',
    argAbbrev: 'u',
    helpText: 'Display timestamps in UTC timezone instead of local.',
    isFlag: true,
    negatable: true,
    defaultsTo: "false",
    envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
  );

  static const deploy = ConfigOption(
    argName: 'deploy',
    argPos: 0,
    helpText:
        'View a specific deployment, with uuid or sequence number, 0 for latest.',
    valueHelp: '<uuid|integer>',
    defaultsTo: '0',
  );
  static const list = ConfigOption(
    argName: 'list',
    argAbbrev: CommandConfigConstants.listOptionAbbrev,
    isFlag: true,
    defaultsTo: 'false',
    helpText: "List recent deployments.",
  );
  static const log = ConfigOption(
    argName: 'build-log',
    argAbbrev: 'b',
    isFlag: true,
    defaultsTo: 'false',
    helpText: "View a deployment's build log, or latest by default.",
  );
}

enum StatusOption implements OptionDefinition {
  projectId(_StatusOptions.projectId),
  limit(_StatusOptions.limit),
  utc(_StatusOptions.utc),
  deploy(_StatusOptions.deploy),
  list(_StatusOptions.list),
  log(_StatusOptions.log);

  const StatusOption(this.option);

  @override
  final ConfigOption option;
}

class CloudStatusCommand extends CloudCliCommand<StatusOption> {
  @override
  String get description => 'Show the deploy status.';

  @override
  String get name => 'status';

  CloudStatusCommand({required super.logger})
      : super(options: StatusOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<StatusOption> commandConfig) async {
    final projectId = commandConfig.value(StatusOption.projectId);
    final limit = int.tryParse(commandConfig.value(StatusOption.limit)) ?? 10;
    final inUtc = commandConfig.flag(StatusOption.utc);
    final deploymentArg = commandConfig.valueOrNull(StatusOption.deploy);
    final list = commandConfig.flag(StatusOption.list);
    final log = commandConfig.flag(StatusOption.log);

    if (list && log) {
      logger.error('Cannot use --list and --build-log together.');
      throw ExitException();
    }

    if (list) {
      // list recent deployments
      try {
        final outputTable = await StatusFeature.getBuildsList(
          runner.serviceProvider.cloudApiClient,
          projectId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
        logger.info(outputTable.toString());
      } catch (e) {
        logger.error('Failed to get deployments list: $e');
        throw ExitException();
      }
      return;
    }

    if (log) {
      // view log
      try {
        final buildUuid = await _getBuildUuid(projectId, deploymentArg);

        await LogsFeature.fetchBuildLog(
          runner.serviceProvider.cloudApiClient,
          writeln: logger.info,
          projectId: projectId,
          buildId: buildUuid,
          inUtc: inUtc,
        );
      } catch (e) {
        logger.error('Failed to get build log: $e');
        throw ExitException();
      }
      return;
    }

    // view a specific deployment
    try {
      final buildUuid = await _getBuildUuid(projectId, deploymentArg);

      final output = await StatusFeature.getDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        buildId: buildUuid,
        inUtc: inUtc,
      );
      logger.info(output.toString());
    } catch (e) {
      logger.error('Failed to get deployment status: $e');
      throw ExitException();
    }
  }

  Future<String> _getBuildUuid(final String projectId, String? buildArg) async {
    buildArg ??= '0';
    final buildNumber = int.tryParse(buildArg);
    return buildNumber != null
        ? await StatusFeature.getBuildId(
            runner.serviceProvider.cloudApiClient,
            projectId: projectId,
            buildNumber: buildNumber,
          )
        : buildArg;
  }
}
