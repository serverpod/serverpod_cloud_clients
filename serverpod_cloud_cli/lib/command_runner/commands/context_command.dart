import 'package:config/config.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/project/project.dart';

class CloudContextCommand extends CloudCliCommand {
  @override
  final name = 'context';

  @override
  final description =
      'Manage the global project context.\n'
      '\n'
      'The global project context is a locally stored setting that selects '
      'the project to use when it is not specified by other means. '
      'Commands that act on a project use it as a last resort, '
      'after command line arguments, environment variables, '
      'and the scloud.yaml project configuration file.';

  CloudContextCommand({required super.logger}) {
    addSubcommand(CloudContextListCommand(logger: logger));
    addSubcommand(CloudContextShowCommand(logger: logger));
    addSubcommand(CloudContextSetCommand(logger: logger));
    addSubcommand(CloudContextUnsetCommand(logger: logger));
  }
}

class CloudContextListCommand extends CloudCliCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the Serverpod Cloud projects available as context.';

  @override
  final bool takesArguments = false;

  CloudContextListCommand({required super.logger});

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    await ProjectCommands.listProjects(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
    );
  }
}

class CloudContextShowCommand extends CloudCliCommand {
  @override
  bool get requireLogin => false;

  @override
  final name = 'show';

  @override
  final description = 'Show the current global project context.';

  @override
  final bool takesArguments = false;

  CloudContextShowCommand({required super.logger});

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final settings = runner.serviceProvider.scloudSettings;
    final projectContext = await settings.projectContext;

    if (projectContext == null) {
      logger.info('No global project context is set.');
    } else {
      logger.info(projectContext);
    }
  }
}

enum ContextSetOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption.argsOnly(asFirstArg: true));

  const ContextSetOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudContextSetCommand extends CloudCliCommand<ContextSetOption> {
  @override
  bool get requireLogin => false;

  @override
  final name = 'set';

  @override
  final description = 'Set the global project context to the given project ID.';

  CloudContextSetCommand({required super.logger})
    : super(options: ContextSetOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ContextSetOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ContextSetOption.projectId);

    final settings = runner.serviceProvider.scloudSettings;
    await settings.setProjectContext(projectId);

    logger.success('Set the global project context to "$projectId".');
  }
}

class CloudContextUnsetCommand extends CloudCliCommand {
  @override
  bool get requireLogin => false;

  @override
  final name = 'unset';

  @override
  final description = 'Unset the global project context.';

  @override
  final bool takesArguments = false;

  CloudContextUnsetCommand({required super.logger});

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final settings = runner.serviceProvider.scloudSettings;
    await settings.setProjectContext(null);

    logger.success('Unset the global project context.');
  }
}
