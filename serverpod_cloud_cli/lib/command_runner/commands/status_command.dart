import 'package:cli_tools/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/status/status.dart';
import 'package:serverpod_cloud_cli/commands/logs/logs.dart';
import 'package:serverpod_cloud_cli/commands/status/status_feature.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';

import 'categories.dart';

class CloudStatusCommand extends CloudCliCommand {
  @override
  final name = 'status';

  @override
  final description = 'Show status information.';

  @override
  String get category => CommandCategories.observe;

  CloudStatusCommand({required super.logger}) {
    addSubcommand(CloudDeployStatusCommand(logger: logger));
  }
}

abstract final class _DeployStatusOptions {
  static const projectId = ProjectIdOption();
  static const limit = IntOption(
    argName: 'limit',
    helpText: 'The maximum number of records to fetch.',
    defaultsTo: 10,
    min: 1,
  );
  static const utc = FlagOption(
    argName: 'utc',
    argAbbrev: 'u',
    helpText: 'Display timestamps in UTC timezone instead of local.',
    negatable: true,
    defaultsTo: false,
    envName: 'SERVERPOD_CLOUD_DISPLAY_UTC',
  );

  static const deploy = StringOption(
    argName: 'deploy',
    argPos: 0,
    helpText:
        'View a specific deployment, with uuid or sequence number, 0 for latest. Can be passed as the first argument.',
    valueHelp: '<uuid|integer>',
    defaultsTo: '0',
  );

  static const _modeGroup = MutuallyExclusive(
    'Mode',
    mode: MutuallyExclusiveMode.allowDefaults,
  );

  static const list = FlagOption(
    argName: 'list',
    argAbbrev: CommandConfigConstants.listOptionAbbrev,
    defaultsTo: false,
    helpText: "List recent deployments.",
    group: _modeGroup,
    negatable: false,
  );
  static const log = FlagOption(
    argName: 'build-log',
    argAbbrev: 'b',
    defaultsTo: false,
    helpText: "View a deployment's build log, or latest by default.",
    group: _modeGroup,
    negatable: false,
  );
  static const overallStatus = FlagOption(
    argName: 'output-overall-status',
    defaultsTo: false,
    helpText: "View a deployment's overall status as a single word, one of: "
        "success, failure, awaiting, running, cancelled, unknown.",
    group: _modeGroup,
    negatable: false,
  );
}

enum DeployStatusOption<V> implements OptionDefinition<V> {
  projectId(_DeployStatusOptions.projectId),
  limit(_DeployStatusOptions.limit),
  utc(_DeployStatusOptions.utc),
  deploy(_DeployStatusOptions.deploy),
  list(_DeployStatusOptions.list),
  log(_DeployStatusOptions.log),
  overallStatus(_DeployStatusOptions.overallStatus);

  const DeployStatusOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDeployStatusCommand extends CloudCliCommand<DeployStatusOption> {
  @override
  String get name => 'deploy';

  @override
  String get description => 'Show the deploy status.';

  CloudDeployStatusCommand({required super.logger})
      : super(options: DeployStatusOption.values);

  @override
  Future<void> runWithConfig(
      final Configuration<DeployStatusOption> commandConfig) async {
    final projectId = commandConfig.value(DeployStatusOption.projectId);
    final limit = commandConfig.value(DeployStatusOption.limit);
    final inUtc = commandConfig.value(DeployStatusOption.utc);
    final deploymentArg =
        commandConfig.optionalValue(DeployStatusOption.deploy);
    final list = commandConfig.value(DeployStatusOption.list);
    final log = commandConfig.value(DeployStatusOption.log);
    final overallStatus = commandConfig.value(DeployStatusOption.overallStatus);

    if (list) {
      // list recent deployments
      if (deploymentArg != null && deploymentArg != '0') {
        throw CloudCliUsageException('Cannot specify deploy id with --list.');
      }
      try {
        await StatusCommands.listDeployAttempts(
          runner.serviceProvider.cloudApiClient,
          logger: logger,
          cloudCapsuleId: projectId,
          limit: limit,
          inUtc: inUtc,
        );
      } on Exception catch (e, s) {
        throw FailureException.nested(e, s, 'Failed to get deployments list');
      }
      return;
    }

    if (log) {
      // view build log
      try {
        final attemptId = await _getDeployAttemptId(projectId, deploymentArg);

        await LogsFeature.fetchBuildLog(
          runner.serviceProvider.cloudApiClient,
          writeln: logger.line,
          projectId: projectId,
          attemptId: attemptId,
          inUtc: inUtc,
        );
      } on Exception catch (e, s) {
        throw FailureException.nested(e, s, 'Failed to get build log');
      }

      return;
    }

    // view a specific deployment
    try {
      final attemptId = await _getDeployAttemptId(projectId, deploymentArg);

      await StatusCommands.showDeploymentStatus(
        runner.serviceProvider.cloudApiClient,
        logger: logger,
        cloudCapsuleId: projectId,
        attemptId: attemptId,
        inUtc: inUtc,
        outputOverallStatus: overallStatus,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to get deployment status');
    }
  }

  Future<String> _getDeployAttemptId(
    final String projectId,
    String? deploymentArg,
  ) async {
    deploymentArg ??= '0';
    final attemptNumber = int.tryParse(deploymentArg);
    if (attemptNumber == null) {
      return deploymentArg;
    }
    try {
      return await StatusFeature.getDeployAttemptId(
        runner.serviceProvider.cloudApiClient,
        cloudCapsuleId: projectId,
        attemptNumber: attemptNumber,
      );
    } on NotFoundException catch (_) {
      if (deploymentArg == '0') {
        throw FailureException(
          error: 'No deployment status found.',
          hint: 'Run this command to deploy: scloud deploy',
        );
      }
      throw FailureException(
        error: 'No such deployment status found.',
        hint: 'Run this command to see recent deployments: '
            'scloud status deploy --list',
      );
    }
  }
}
