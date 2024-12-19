import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
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
      if (deploymentArg != null && deploymentArg != '0') {
        logger.error('Cannot specify deploy id with --list.');
        throw ExitException();
      }
      await handleCommonClientExceptions(logger, () async {
        final outputTable = await StatusFeature.getDeployAttemptsList(
          runner.serviceProvider.cloudApiClient,
          environmentId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
        outputTable.writeLines(logger.line);
      }, (final e) {
        logger.error('Failed to get deployments list: $e');
        throw ExitException();
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
        throw ExitException();
      });

      return;
    }

    // view a specific deployment
    await handleCommonClientExceptions(logger, () async {
      final attemptId = await _getDeployAttemptId(projectId, deploymentArg);

      final output = await StatusFeature.getDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        environmentId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
      );
      logger.info(output.toString());
    }, (final e) {
      logger.error('Failed to get deployment status: $e');
      throw ExitException();
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
            environmentId: projectId,
            attemptNumber: attemptNumber,
          )
        : deploymentArg;
  }
}
