import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/commands/deploy/prepare_workspace.dart'
    show WorkspaceProject;
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_file.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

abstract class ProjectCommands {
  /// Subcommand to create a new tenant project.
  static Future<void> createProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final bool enableDb,
    required final String projectDir,
    required final String configFilePath,
  }) async {
    logger.init('Creating Serverpod Cloud project "$projectId".');

    try {
      await logger.progress(
        'Registering Serverpod Cloud project.',
        newParagraph: true,
        () async {
          await cloudApiClient.projects.createProject(
            cloudProjectId: projectId,
          );
          return true;
        },
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
          e, s, 'Request to create a new project failed');
    }

    if (enableDb) {
      await logger.progress(
        'Requesting database creation.',
        () async {
          try {
            await cloudApiClient.infraResources
                .enableDatabase(cloudCapsuleId: projectId);
            return true;
          } on Exception catch (e, s) {
            throw FailureException.nested(e, s,
                'Request to create a database for the new project failed');
          }
        },
      );
    }

    if (isServerpodServerDirectory(Directory(projectDir))) {
      // write scloud project files unless the config file already exists

      final scloudYamlFile = File(configFilePath);
      if (scloudYamlFile.existsSync()) {
        logger.success(
          'Serverpod Cloud project created.',
          newParagraph: true,
        );

        return;
      }

      final projectConfig = await _fetchProjectConfig(
        logger,
        cloudApiClient,
        projectId,
      );

      await logger.progress(
        'Writing cloud project configuration files.',
        () async {
          _writeProjectFiles(
            logger,
            projectConfig,
            projectDir,
            configFilePath,
          );
          return true;
        },
      );
    } else {
      logger.terminalCommand(
        message: 'Since no Serverpod server directory was identified, '
            'an scloud.yaml configuration file has not been created. '
            'Use the link command to create it in the server '
            'directory of this project:',
        newParagraph: true,
        'scloud project link --project $projectId',
      );
    }

    logger.success(
      'Serverpod Cloud project created.',
      newParagraph: true,
    );
  }

  static Future<void> deleteProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the project "$projectId"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    try {
      await cloudApiClient.projects.deleteProject(cloudProjectId: projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(
          e, s, 'Request to delete the project failed');
    }

    logger.success(
      'Deleted the project "$projectId".',
      newParagraph: true,
    );
  }

  static Future<void> listProjects(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final bool showArchived = false,
  }) async {
    late List<Project> projects;
    try {
      projects = await cloudApiClient.projects.listProjects();
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Request to list projects failed');
    }

    final activeProjects = showArchived
        ? projects
        : projects.where((final p) => p.archivedAt == null);

    if (activeProjects.isEmpty) {
      logger.info('No projects available.');
      return;
    }

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders([
      'Project Id',
      'Created At',
      if (showArchived) 'Deleted At',
    ]);
    for (final project in activeProjects.sortedBy((final p) => p.createdAt)) {
      tablePrinter.addRow([
        project.cloudProjectId,
        project.createdAt.toString().substring(0, 19),
        if (showArchived) project.archivedAt?.toString().substring(0, 19),
      ]);
    }
    tablePrinter.writeLines(logger.line);
  }

  static Future<void> linkProject(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String projectDirectory,
    required final String configFilePath,
  }) async {
    final projectConfig = await _fetchProjectConfig(
      logger,
      cloudApiClient,
      projectId,
    );

    await logger.progress(
      'Writing cloud project configuration files.',
      () async {
        _writeProjectFiles(
          logger,
          projectConfig,
          projectDirectory,
          configFilePath,
        );
        return true;
      },
    );

    logger.success(
      'Linked Serverpod Cloud project.',
      newParagraph: true,
    );
  }

  /// Fetches the project config from the server.
  static Future<ProjectConfig> _fetchProjectConfig(
    final CommandLogger logger,
    final Client cloudApiClient,
    final String projectId,
  ) async {
    try {
      return await cloudApiClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to fetch project config');
    }
  }

  static void _writeProjectFiles(
    final CommandLogger logger,
    final ProjectConfig projectConfig,
    final String projectDirectory,
    final String configFilePath,
  ) {
    final workspaceRootDir = _findWorkspaceRootDir(
      logger,
      Directory(projectDirectory),
    );

    try {
      ScloudConfigFile.writeToFile(
        projectConfig,
        configFilePath,
      );
      final relativePath = p.relative(configFilePath);
      logger.debug(
        "Wrote the '$relativePath' configuration file for '${projectConfig.projectId}'.",
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
          e, s, 'Failed to write to the $configFilePath file');
    }

    try {
      ScloudIgnore.writeTemplateIfNotExists(
        rootFolder: workspaceRootDir?.path ?? projectDirectory,
      );
      logger.debug("Wrote the '${ScloudIgnore.fileName}' file.");
    } on Exception catch (e, s) {
      throw FailureException.nested(
          e, s, 'Failed to write to ${ScloudIgnore.fileName} file');
    }

    if (workspaceRootDir != null) {
      try {
        final updated = _updateGitIgnore(workspaceRootDir);
        if (updated) {
          logger.debug(
            "Added '${ScloudIgnore.scloudDirName}/' to '.gitignore' in the workspace directory.",
          );
        }
      } on Exception catch (e, s) {
        throw FailureException.nested(
            e, s, 'Failed to write to the .gitignore file');
      }
    }
  }

  static Directory? _findWorkspaceRootDir(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
    final projectPubspec = TenantProjectPubspec.fromProjectDir(
      projectDir,
    );

    if (projectPubspec.isWorkspaceResolved()) {
      final (workspaceRootDir, workspacePubspec) =
          WorkspaceProject.findWorkspaceRoot(projectDir);
      return workspaceRootDir;
    }

    return null;
  }

  static bool _updateGitIgnore(final Directory workspaceRootDir) {
    const scloudIgnoreTemplate = '''
# scloud deployment generated files should not be committed to git
**/${ScloudIgnore.scloudDirName}/
''';
    final gitIgnoreFile = File(p.join(workspaceRootDir.path, '.gitignore'));
    final String content;
    if (gitIgnoreFile.existsSync()) {
      final read = gitIgnoreFile.readAsStringSync();
      if (read.contains('${ScloudIgnore.scloudDirName}/')) {
        return false;
      }
      content = read.endsWith('\n') ? '$read\n' : '$read\n\n';
    } else {
      content = '';
    }
    gitIgnoreFile.writeAsStringSync('$content$scloudIgnoreTemplate');
    return true;
  }
}
