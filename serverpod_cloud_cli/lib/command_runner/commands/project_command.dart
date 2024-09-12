import 'package:cli_tools/cli_tools.dart';
import 'package:collection/collection.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
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

class CloudProjectCreateCommand extends CloudCliCommand {
  @override
  final name = 'create';

  @override
  final description = 'Create a Serverpod Cloud tenant project.';

  CloudProjectCreateCommand({required super.logger}) {
    argParser.addOption(
      'project-id',
      abbr: 'i',
      help: 'The ID for the new project.',
      mandatory: true,
    );

    argParser.addOption(
      'auth-dir',
      abbr: 'd',
      help:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    // Developer options and flags
    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    );
  }

  @override
  void run() async {
    final projectName = argResults!['project-id'] as String;

    final cloudClient = await getClient(
        localStoragePath: argResults!['auth-dir'] as String,
        serverAddress: argResults!['server'] as String);

    try {
      await cloudClient.tenantProjects
          .createTenantProject(canonicalName: projectName);
    } catch (e, stackTrace) {
      logger.error(
        'Request to create a new tenant project failed: $e',
        stackTrace: stackTrace,
      );
      throw ExitException();
    }

    logger.info("Successfully created the new tenant project '$projectName'.");
  }
}

class CloudProjectDeleteCommand extends CloudCliCommand {
  @override
  final name = 'delete';

  @override
  final description = 'Delete a Serverpod Cloud tenant project.';

  CloudProjectDeleteCommand({required super.logger}) {
    argParser.addOption(
      'project-id',
      abbr: 'i',
      help: 'The ID of the project to delete.',
      mandatory: true,
    );

    argParser.addOption(
      'auth-dir',
      abbr: 'd',
      help:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    // Developer options and flags
    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    );
  }

  @override
  void run() async {
    final projectName = argResults!['project-id'] as String;

    final cloudClient = await getClient(
        localStoragePath: argResults!['auth-dir'] as String,
        serverAddress: argResults!['server'] as String);

    try {
      await cloudClient.tenantProjects
          .deleteTenantProject(canonicalName: projectName);
    } catch (e, stackTrace) {
      logger.error(
        'Request to delete a new tenant project failed: $e',
        stackTrace: stackTrace,
      );
      throw ExitException();
    }

    logger.info("Successfully deleted the tenant project '$projectName'.");
  }
}

class CloudProjectListCommand extends CloudCliCommand {
  @override
  final name = 'list';

  @override
  final description = 'List the Serverpod Cloud tenant projects.';

  CloudProjectListCommand({required super.logger}) {
    argParser.addOption(
      'auth-dir',
      abbr: 'd',
      help:
          'Override the directory path where the serverpod cloud authentication file is stored.',
      defaultsTo: ResourceManager.localStorageDirectory.path,
    );

    // Developer options and flags
    argParser.addOption(
      'server',
      abbr: 's',
      help: 'The URL to the Serverpod cloud api server.',
      hide: true,
      defaultsTo: HostConstants.serverpodCloudApi,
    );
  }

  @override
  void run() async {
    final cloudClient = await getClient(
        localStoragePath: argResults!['auth-dir'] as String,
        serverAddress: argResults!['server'] as String);

    late List<TenantProject> projects;
    try {
      projects = await cloudClient.tenantProjects.listTenantProjects();
    } catch (e, stackTrace) {
      logger.error(
        'Request to list tenant projects failed: $e',
        stackTrace: stackTrace,
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
