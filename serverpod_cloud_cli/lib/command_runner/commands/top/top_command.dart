import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart' show Client;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_snapshot.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/top/top_tui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart'
    show ProjectIdOption, UtcOption;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show FailureException;
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

enum TopOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption()),
  utc(UtcOption()),
  interval(
    DurationOption(
      argName: 'interval',
      helpText: 'How often the status and deployments refresh.',
      defaultsTo: Duration(seconds: 5),
      min: Duration(seconds: 1),
    ),
  );

  const TopOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudTopCommand extends CloudCliCommand<TopOption> {
  static const Duration _metricsInterval = Duration(seconds: 30);
  static const int _deploymentLimit = 4;
  static const int _logLimit = 200;

  @override
  final String name = 'top';

  @override
  final String description = '''
Show a live overview of a project.

The overview shows the status, the CPU and memory of the podlets, the
traffic, the database, the latest deployments and the logs of the project,
and keeps them up to date until you quit.
''';

  @override
  String get category {
    return CommandCategories.control;
  }

  @override
  String get usageExamples {
    return '''\n
Examples

  Show the live overview of the project.

    \$ $baseCommand top


  Show the live overview of a specific project.

    \$ $baseCommand top --project my-project


  Refresh the status every 30 seconds.

    \$ $baseCommand top --interval 30s

''';
  }

  CloudTopCommand({required super.logger}) : super(options: TopOption.values);

  @override
  bool get interactiveOnly {
    return true;
  }

  @override
  String get nonInteractiveHint {
    return 'Use `$baseCommand status live` and `$baseCommand log` '
        'in a non-interactive environment.';
  }

  @override
  Future<void> runWithOutput(
    final Configuration<TopOption> commandConfig,
    final CommandOutput output,
  ) async {
    final String projectId = commandConfig.value(TopOption.projectId);
    final bool inUtc = commandConfig.value(TopOption.utc);
    final Duration interval = commandConfig.value(TopOption.interval);
    final Client client = runner.serviceProvider.cloudApiClient;

    if (!logger.inlineTerminal.hasTerminal) {
      throw FailureException(
        error: 'The top command needs an interactive terminal.',
        hint: nonInteractiveHint,
      );
    }

    late final TopSnapshot initial;
    await logger.progress('Loading $projectId', () async {
      initial = await TopOperations.fetchSnapshot(
        client,
        projectId: projectId,
        deploymentLimit: _deploymentLimit,
        logLimit: _logLimit,
      );
      return true;
    });

    await runTopTui(
      baseCommand: baseCommand,
      projectId: projectId,
      initial: initial,
      snapshots: TopOperations.watchSnapshots(
        client,
        initial: initial,
        projectId: projectId,
        interval: interval,
        metricsInterval: _metricsInterval,
        deploymentLimit: _deploymentLimit,
        logLimit: _logLimit,
      ),
      utc: inUtc,
      interval: interval,
    );
  }
}
