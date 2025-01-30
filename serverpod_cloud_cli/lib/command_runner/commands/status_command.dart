import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';
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
        'View a specific deployment, with uuid or sequence number, 0 for latest. Can be passed as the first argument.',
    valueHelp: '<uuid|integer>',
    defaultsTo: '0',
  );
  static const list = ConfigOption(
    argName: 'list',
    argAbbrev: CommandConfigConstants.listOptionAbbrev,
    isFlag: true,
    defaultsTo: 'false',
    helpText: "List recent deployments.",
    negatable: false,
  );
  static const log = ConfigOption(
    argName: 'build-log',
    argAbbrev: 'b',
    isFlag: true,
    defaultsTo: 'false',
    helpText: "View a deployment's build log, or latest by default.",
    negatable: false,
  );
  static const overallStatus = ConfigOption(
    argName: 'output-overall-status',
    isFlag: true,
    defaultsTo: 'false',
    helpText: "View a deployment's overall status as a single word, one of: "
        "success, failure, awaiting, running, cancelled, unknown.",
    negatable: false,
  );
}

enum StatusOption implements OptionDefinition {
  projectId(_StatusOptions.projectId),
  limit(_StatusOptions.limit),
  utc(_StatusOptions.utc),
  deploy(_StatusOptions.deploy),
  list(_StatusOptions.list),
  log(_StatusOptions.log),
  overallStatus(_StatusOptions.overallStatus);

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
    final overallStatus = commandConfig.flag(StatusOption.overallStatus);

    if (list && log) {
      logger.error('Cannot use --list and --build-log together.');
      throw ErrorExitException();
    }

    if (list) {
      // list recent deployments
      if (deploymentArg != null && deploymentArg != '0') {
        logger.error('Cannot specify deploy id with --list.');
        throw ErrorExitException();
      }
      await handleCommonClientExceptions(logger, () async {
        await StatusCommands.listDeployAttempts(
          runner.serviceProvider.cloudApiClient,
          logger: logger,
          cloudCapsuleId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
      }, (final e) {
        logger.error('Failed to get deployments list: $e');
        throw ErrorExitException();
      });
      return;
    }

    if (log) {
      // view build log
      await handleCommonClientExceptions(logger, () async {
        final attemptId = await _getDeployAttemptId(projectId, deploymentArg);

        await LogsFeature.fetchBuildLog(
          runner.serviceProvider.cloudApiClient,
          writeln: logger.line,
          projectId: projectId,
          attemptId: attemptId,
          inUtc: inUtc,
        );
      }, (final e) {
        logger.error('Failed to get build log: $e');
        throw ErrorExitException();
      });

      return;
    }

    // view a specific deployment
    await handleCommonClientExceptions(logger, () async {
      final attemptId = await _getDeployAttemptId(projectId, deploymentArg);

      await StatusCommands.showDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        cloudCapsuleId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
        outputOverallStatus: overallStatus,
      );
    }, (final e) {
      logger.error('Failed to get deployment status: $e');
      throw ErrorExitException();
    });
  }

  Future<String> _getDeployAttemptId(
    final String projectId,
    String? deploymentArg,
  ) async {
    deploymentArg ??= '0';
    final attemptNumber = int.tryParse(deploymentArg);
    return attemptNumber != null
        ? await StatusFeature.getDeployAttemptId(
            runner.serviceProvider.cloudApiClient,
            cloudCapsuleId: projectId,
            attemptNumber: attemptNumber,
          )
        : deploymentArg;
  }
}
