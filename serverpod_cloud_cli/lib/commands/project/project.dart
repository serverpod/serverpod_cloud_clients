import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/commands/deploy/prepare_workspace.dart'
    show WorkspaceException, WorkspaceProject;
import 'package:serverpod_cloud_cli/shared/helpers/common_exceptions_handler.dart';
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

    await handleCommonClientExceptions(logger, () async {
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
    }, (final e) {
      logger.error(
        'Request to create a new project failed',
        exception: e,
      );

      throw ErrorExitException();
    });

    if (enableDb) {
      await logger.progress(
        'Requesting database creation.',
        () async {
          await handleCommonClientExceptions(logger, () async {
            await cloudApiClient.infraResources
                .enableDatabase(cloudCapsuleId: projectId);
          }, (final e) {
            logger.error(
              'Request to create a database for the new project failed',
              exception: e,
            );
            throw ErrorExitException();
          });
          return true;
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
      throw ErrorExitException();
    }

    await handleCommonClientExceptions(logger, () async {
      await cloudApiClient.projects.deleteProject(cloudProjectId: projectId);
    }, (final e) {
      logger.error(
        'Request to delete the project failed',
        exception: e,
      );

      throw ErrorExitException();
    });

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
    await handleCommonClientExceptions(logger, () async {
      projects = await cloudApiClient.projects.listProjects();
    }, (final e) {
      logger.error(
        'Request to list projects failed',
        exception: e,
      );
      throw ErrorExitException();
    });

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
    return await handleCommonClientExceptions(
      logger,
      () => cloudApiClient.projects.fetchProjectConfig(
        cloudProjectId: projectId,
      ),
      (final e) {
        logger.error(
          'Failed to fetch project config',
          exception: e,
        );
        throw ErrorExitException();
      },
    );
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
      final message = 'Failed to write to the $configFilePath file';
      logger.error(message, exception: e);
      throw ErrorExitException(message, e, s);
    }

    try {
      ScloudIgnore.writeTemplateIfNotExists(
        rootFolder: workspaceRootDir?.path ?? projectDirectory,
      );
      logger.debug("Wrote the '${ScloudIgnore.fileName}' file.");
    } on Exception catch (e, s) {
      final message = 'Failed to write to ${ScloudIgnore.fileName} file';
      logger.error(message, exception: e);
      throw ErrorExitException(message, e, s);
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
        final message = 'Failed to write to the .gitignore file';
        logger.error(message, exception: e);
        throw ErrorExitException(message, e, s);
      }
    }
  }

  static Directory? _findWorkspaceRootDir(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
    final projectPubspec = TenantProjectPubspec.fromProjectDir(
      projectDir,
      logger: logger,
    );

    if (projectPubspec.isWorkspaceResolved()) {
      try {
        final (workspaceRootDir, workspacePubspec) =
            WorkspaceProject.findWorkspaceRoot(projectDir);
        return workspaceRootDir;
      } on WorkspaceException catch (e, s) {
        e.errors?.forEach(logger.error);
        throw ErrorExitException(e.errors?.first, e, s);
      }
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
