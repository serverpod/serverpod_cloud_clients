import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/commands/deploy/prepare_workspace.dart'
    show WorkspaceProject;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';
import 'package:serverpod_cloud_cli/util/scloudignore.dart';

abstract final class ProjectFilesWriter {
  static void writeFiles({
    required final String projectId,
    required final List<String> preDeployScripts,
    required final String configFilePath,
    required final String projectDirectory,
  }) {
    _upsertConfigFile(projectId, preDeployScripts, configFilePath);
    _upsertScloudIgnoreFile(projectDirectory);
  }

  static void _upsertConfigFile(
    final String projectId,
    final List<String> suggestedPreDeployScripts,
    final String configFilePath,
  ) {
    final ScloudConfig? config;
    try {
      config = ScloudConfigIO.readFromFile(configFilePath);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to read the $configFilePath file',
      );
    }

    final ScloudConfig newConfig;
    if (config == null) {
      newConfig = ScloudConfig(
        projectId: projectId,
        scripts: ScloudScripts(
          preDeploy: suggestedPreDeployScripts,
          postDeploy: [],
        ),
      );
    } else {
      newConfig = config.copyWith(
        projectId: projectId,
        scripts: config.scripts.copyWith(
          preDeploy: [
            ...config.scripts.preDeploy,
            ...suggestedPreDeployScripts,
          ],
        ),
      );
    }
    ScloudConfigIO.writeToFile(newConfig, configFilePath);
  }

  static void _upsertScloudIgnoreFile(final String projectDirectory) {
    final workspaceRootDir = _findWorkspaceRootDir(Directory(projectDirectory));

    try {
      ScloudIgnore.writeTemplateIfNotExists(
        rootFolder: workspaceRootDir?.path ?? projectDirectory,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to write to ${ScloudIgnore.fileName} file',
      );
    }

    if (workspaceRootDir != null) {
      try {
        _updateScloudIgnore(workspaceRootDir);
      } on Exception catch (e, s) {
        throw FailureException.nested(
          e,
          s,
          'Failed to write to the .gitignore file',
        );
      }
    }
  }

  static Directory? _findWorkspaceRootDir(final Directory projectDir) {
    final projectPubspec = TenantProjectPubspec.fromProjectDir(projectDir);

    if (projectPubspec.isWorkspaceResolved()) {
      final (workspaceRootDir, workspacePubspec) =
          WorkspaceProject.findWorkspaceRoot(projectDir);
      return workspaceRootDir;
    }

    return null;
  }

  static bool _updateScloudIgnore(final Directory workspaceRootDir) {
    const scloudIgnoreTemplate =
        '''
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
