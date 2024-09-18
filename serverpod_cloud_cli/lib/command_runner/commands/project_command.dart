import 'package:cli_tools/cli_tools.dart';
import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudProjectCommand extends CloudCliCommand {
  @override
  final name = 'project';

  @override
  final description = 'Manage Serverpod Cloud tenant projects.';

  CloudProjectCommand({required super.logger}) {
    // Subcommands
    addSubcommand(CloudProjectCreateCommand(logger: logger));
    addSubcommand(CloudProjectDeleteCommand(logger: logger));
    addSubcommand(CloudProjectListCommand(logger: logger));
  }
}

class ProjectCommandConfig extends Configuration {
  static const projectIdOpt = ConfigOption(
    argName: 'project-id',
    argAbbrev: 'i',
    helpText: 'The ID of the project.',
    mandatory: true,
    envName: 'SERVERPOD_CLOUD_PROJECT_ID',
  );

  ProjectCommandConfig({
    super.args,
    super.env,
  }) : super.fromEnvAndArgs(options: [projectIdOpt]);
}

class CloudProjectCreateCommand extends CloudCliCommand {
  @override
  final name = 'create';

  @override
  final description = 'Create a Serverpod Cloud tenant project.';

  @override
  final bool takesArguments = false;

  CloudProjectCreateCommand({required super.logger})
      : super(options: [ProjectCommandConfig.projectIdOpt]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(ProjectCommandConfig.projectIdOpt);

    final cloudClient = await runner.getClient();
    try {
      await cloudClient.tenantProjects
          .createTenantProject(canonicalName: projectId);
    } catch (e) {
      logger.error(
        'Request to create a new tenant project failed: $e',
      );
      throw ExitException();
    }

    logger.info("Successfully created the new tenant project '$projectId'.");
  }
}

class CloudProjectDeleteCommand extends CloudCliCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a Serverpod Cloud tenant project.';

  @override
  final bool takesArguments = false;

  CloudProjectDeleteCommand({required super.logger})
      : super(options: [ProjectCommandConfig.projectIdOpt]);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final projectId = commandConfig.value(ProjectCommandConfig.projectIdOpt);

    final cloudClient = await runner.getClient();
    try {
      await cloudClient.tenantProjects
          .deleteTenantProject(canonicalName: projectId);
    } catch (e) {
      logger.error(
        'Request to delete a new tenant project failed: $e',
      );
      throw ExitException();
    }

    logger.info("Successfully deleted the tenant project '$projectId'.");
  }
}

class CloudProjectListCommand extends CloudCliCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the Serverpod Cloud tenant projects.';

  @override
  final bool takesArguments = false;

  CloudProjectListCommand({required super.logger}) : super(options: []);

  @override
  Future<void> runWithConfig(final Configuration commandConfig) async {
    final cloudClient = await runner.getClient();
    late List<TenantProject> projects;
    try {
      projects = await cloudClient.tenantProjects.listTenantProjects();
    } catch (e) {
      logger.error(
        'Request to list tenant projects failed: $e',
      );
      throw ExitException();
    }
    if (projects.isEmpty) {
      logger.info('No tenant projects available.');
      return;
    }
    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders(['Project Canonical Name', 'Created At']);
    for (final project in projects.sortedBy((final p) => p.createdAt)) {
      tablePrinter.addRow([
        project.canonicalName,
        project.createdAt.toString().substring(0, 19),
      ]);
    }
    tablePrinter.toString().split('\n').forEach(logger.info);
  }
}
