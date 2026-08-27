import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cli_tools/logger.dart' as cli show AnsiStyle;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/file_uploader_factory.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/deploy.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/deploy/prepare_project_files.dart'
    show TenantProject;
import 'package:serverpod_cloud_cli/command_runner/commands/launch/tui/app.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/tui/state.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/launch/tui/state_holder.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/status/status_ops.dart';
import 'package:serverpod_cloud_cli/constants.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/browser_launcher.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart'
    show SelectList, SelectListStyle;
import 'package:serverpod_cloud_cli/util/listener_server.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:serverpod_cloud_cli/util/project_id_validator.dart';
import 'package:serverpod_cloud_cli/util/pubspec_validator.dart'
    show TenantProjectPubspec;
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_io.dart';
import 'package:serverpod_cloud_cli/util/scloud_config/scloud_config_model.dart';
import 'package:serverpod_logging_cli/serverpod_logging_cli.dart';
import 'package:serverpod_tui/serverpod_tui.dart';
import 'package:yaml_codec/yaml_codec.dart' show yamlDecode;

abstract class Launch {
  static const _projectFactStyle = cli.AnsiStyle.cyan;

  static Future<void> launch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final Directory projectDirectory,
    required final String? projectId,
    required final bool includePreDeployScripts,
    required final bool performDeploy,
    required final bool tui,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool wetRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
    final String? dartVersionOverride,
  }) async {
    logger.init('Launching a Serverpod Cloud project.\n');

    final pubspec = _validateProjectDir(logger, projectDirectory);

    final dirPath = logger.wrapStyle(projectDirectory.path, _projectFactStyle);
    logger.info('Project directory: $dirPath\n');

    final usesDatabase = _usesDatabase(projectDirectory);

    final projectSetup = ProjectLaunch(
      projectDir: projectDirectory,
      projectPubspec: pubspec,
      usesDb: usesDatabase,
      includePreDeployScripts: includePreDeployScripts,
      projectId: projectId,
      dartVersionOverride: dartVersionOverride,
      performDeploy: performDeploy,
    );

    if (tui) {
      await launchWithTui(
        cloudApiClient,
        fileUploaderFactory,
        logger: logger,
        projectSetup: projectSetup,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        deployConcurrency: deployConcurrency,
        wetRun: wetRun,
        deployShowFiles: deployShowFiles,
        deployOutputPath: deployOutputPath,
        deploySkipTailingStatus: deploySkipTailingStatus,
      );
    } else {
      await launchWithoutTui(
        cloudApiClient,
        fileUploaderFactory,
        logger: logger,
        projectSetup: projectSetup,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        deployConcurrency: deployConcurrency,
        wetRun: wetRun,
        deployShowFiles: deployShowFiles,
        deployOutputPath: deployOutputPath,
        deploySkipTailingStatus: deploySkipTailingStatus,
      );
    }
  }

  static Future<void> launchWithoutTui(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final ProjectLaunch projectSetup,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool wetRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    await selectProjectId(cloudApiClient, logger, projectSetup);

    if (projectSetup.preexistingProject != true) {
      projectSetup.projectId = await createProject(
        logger,
        consoleServer: consoleServer,
        openBrowser: openBrowser,
        projectName: projectSetup.projectId ?? '',
        usesDb: projectSetup.usesDb,
      );
    }

    await suggestCodeGenerationPreDeployHook(logger, projectSetup);

    await suggestFlutterBuildPreDeployHook(logger, projectSetup);

    await selectCustomPasswords(cloudApiClient, logger, projectSetup);

    await performLaunch(
      cloudApiClient,
      fileUploaderFactory,
      logger,
      projectSetup,
      consoleServer: consoleServer,
      openBrowser: openBrowser,
      deployConcurrency: deployConcurrency,
      wetRun: wetRun,
      deployShowFiles: deployShowFiles,
      deployOutputPath: deployOutputPath,
      deploySkipTailingStatus: deploySkipTailingStatus,
    );
  }

  static Future<void> launchWithTui(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory, {
    required final CommandLogger logger,
    required final ProjectLaunch projectSetup,
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool wetRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
  }) async {
    final defaultProjectId = _getDefaultProjectId(projectSetup);

    final existingProjects = await _fetchExistingUndeployedProjects(
      cloudApiClient,
    );
    final existingProjectIds = existingProjects
        .map((final p) => p.cloudProjectId)
        .toList();

    final state = LaunchConfigState(
      projectSetup: projectSetup,
      defaultProjectId: defaultProjectId,
      existingProjectIds: existingProjectIds,
    );
    final holder = LaunchAppStateHolder(state);

    final tuiWriter = TuiLogWriter()..attach(holder);
    final tuiLogger = ServerpodCliLogger(tuiWriter);

    // Hook up the TUI logger for structured logs in the TUI.
    logger.initializeWith(tuiLogger);

    await runTuiApp(
      ScloudLaunchApp(
        holder: holder,
        onLaunch: () async {
          // Update UI to show logs from the launch
          state.markLaunchingProject();
          holder.markDirty();

          final stdoutController = StreamController<List<int>>();
          stdoutController.stream
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter())
              .listen(logger.debug);
          final toDebugLog = IOSink(stdoutController);
          final stderrController = StreamController<List<int>>();
          stderrController.stream
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter())
              .listen(logger.error);
          final toErrorLog = IOSink(stderrController);

          await performLaunch(
            cloudApiClient,
            fileUploaderFactory,
            logger,
            state.projectSetup,
            consoleServer: consoleServer,
            openBrowser: openBrowser,
            stdout: toDebugLog,
            stderr: toErrorLog,
            deployConcurrency: deployConcurrency,
            wetRun: wetRun,
            deployShowFiles: deployShowFiles,
            deployOutputPath: deployOutputPath,
            deploySkipTailingStatus: deploySkipTailingStatus,
          );
        },
        onQuit: () {
          /// Reset to the default logger for post-tui logs.
          logger.reset();
          shutdownTuiApp();
        },
      ),
    );
  }

  /// Validates that the project directory is a valid Serverpod server directory
  /// and that it has supported dependencies.
  ///
  /// Returns the [TenantProjectPubspec] if the project is valid,
  /// otherwise throws a [FailureException].
  static TenantProjectPubspec _validateProjectDir(
    final CommandLogger logger,
    final Directory projectDir,
  ) {
    final pubspecValidator = TenantProjectPubspec.fromProjectDir(projectDir);

    if (!pubspecValidator.isServerpodServer()) {
      throw FailureException(
        error: '`${projectDir.path}` is not a Serverpod server directory.',
        hint: "Provide the project's server directory and try again.",
      );
    }

    final lockfileDirectory = TenantProject.resolveLockfileDirectory(
      projectDir,
      isWorkspaceResolved: pubspecValidator.isWorkspaceResolved(),
    );

    final issues = [
      ...pubspecValidator.projectDependencyIssues(),
      ...TenantProjectPubspec.readLockfileDartSdk(
        File(p.join(lockfileDirectory.path, 'pubspec.lock')),
      ).issues,
    ];
    if (issues.isEmpty) {
      return pubspecValidator;
    }

    throw FailureException(
      error:
          '`${projectDir.path}` is a Serverpod server directory, but it is not valid:',
      errors: issues,
      hint: 'Resolve the issues and try again.',
    );
  }

  static bool _usesDatabase(final Directory projectDir) {
    const configFiles = [
      'development.yaml',
      'production.yaml',
      'staging.yaml',
      'test.yaml',
    ];
    for (final filename in configFiles) {
      final configFile = File(p.join(projectDir.path, 'config', filename));
      if (configFile.existsSync()) {
        final config = yamlDecode(configFile.readAsStringSync());
        if (config case final Map<dynamic, dynamic> cfgMap) {
          if (cfgMap.containsKey('database')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static Future<void> selectProjectId(
    final Client cloudApiClient,
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    const invalidProjectIdMessage =
        'Invalid project ID. Must be 6-32 characters long '
        'and contain only lowercase letters, numbers, and hyphens.';

    final existingProjects = await cloudApiClient.projects.listProjectsInfo(
      includeLatestDeployAttemptTime: true,
    );

    final specifiedProjectId = projectSetup.projectId;
    if (specifiedProjectId != null) {
      final preexistingProject = existingProjects.firstWhereOrNull(
        (final p) => p.project.cloudProjectId == specifiedProjectId,
      );
      if (preexistingProject != null) {
        projectSetup.preexistingProject = true;
        projectSetup.preexistingProjectDeployed =
            preexistingProject.latestDeployAttemptTime?.timestamp != null;
        return;
      }

      if (isValidProjectIdFormat(specifiedProjectId)) {
        final confirm = await logger.confirm(
          'Open the browser and create a new Serverpod Cloud project?',
          defaultValue: true,
        );
        if (!confirm) {
          logger.info('Setup cancelled.');
          throw UserAbortException();
        }
        return;
      }

      throw FailureException(error: invalidProjectIdMessage);
    }

    final selectedId = await _selectExistingProject(
      cloudApiClient,
      existingProjects,
      logger,
    );
    if (selectedId != null) {
      projectSetup.projectId = selectedId;
      projectSetup.preexistingProject = true;
      final preexistingProject = existingProjects.firstWhereOrNull(
        (final p) => p.project.cloudProjectId == selectedId,
      );
      projectSetup.preexistingProjectDeployed =
          preexistingProject?.latestDeployAttemptTime?.timestamp != null;
      return;
    }

    projectSetup.projectId = _getDefaultProjectId(projectSetup);
    return;
  }

  static Future<void> selectCustomPasswords(
    final Client cloudApiClient,
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    const ignoredSecretNames = [
      'database',
      'emailSecretHashPepper',
      'jwtHmacSha512PrivateKey',
      'jwtRefreshTokenHashPepper',
      'serviceSecret',
      'redis',
      'mySharedPassword',
    ];

    final allPasswords = _readAllPasswords(projectSetup.projectDir);
    if (allPasswords.isEmpty) return;

    List<String> alreadySetSecretNames;
    final projectId = projectSetup.projectId;
    if (projectSetup.preexistingProject == true && projectId != null) {
      alreadySetSecretNames = await PasswordOperations.fetchPasswords(
        cloudApiClient,
        projectId: projectId,
      ).then((final passwords) => passwords.map((final p) => p.name).toList());
    } else {
      alreadySetSecretNames = [];
    }

    final filteredPasswords = allPasswords.where(
      (final p) =>
          !ignoredSecretNames.contains(p.name) &&
          !alreadySetSecretNames.contains(p.name),
    );
    if (filteredPasswords.isEmpty) return;

    final sortedPasswords = filteredPasswords.toList()
      ..sort((final a, final b) => a.section.index.compareTo(b.section.index));

    final longestPasswordNameLength = sortedPasswords
        .map((final p) => p.name.length)
        .reduce((final a, final b) => math.max(a, b));
    String padAfterName(final String name) {
      return ''.padRight(longestPasswordNameLength - name.length);
    }

    final options = sortedPasswords
        .map(
          (final p) =>
              '${p.name}: ${padAfterName(p.name)}${_hidePassword(p.value)}'
              '  (from section "${p.section.name}")',
        )
        .toList();
    final initiallySelected = options.where(
      (final s) => s.endsWith('"production")') || s.endsWith('"shared")'),
    );

    final selected = await SelectList.chooseMultiple<String>(
      prompt:
          'Custom passwords were found in config/passwords.yaml.\n'
          'You can select which of them to copy securely to Serverpod Cloud now.\n'
          '${logger.wrapStyle('Set them later with `scloud password set`.', cli.AnsiStyle.darkGray)}',
      options: options,
      initiallySelected: initiallySelected,
      terminal: logger.inlineTerminal,
      style: SelectListStyle(highlightStyle: _projectFactStyle.ansiCode),
    );
    if (selected == null) {
      logger.info('Setup cancelled.');
      throw UserAbortException();
    }

    final selectedNames = selected
        .map((final option) => option.split(':').first)
        .toSet();
    final selectedPasswords = sortedPasswords.where(
      (final p) => selectedNames.contains(p.name),
    );
    projectSetup.selectedPasswords = {
      for (final p in selectedPasswords) p.name: p.value,
    };
  }

  static Set<_Password> _readAllPasswords(final Directory projectDir) {
    final file = File(p.join(projectDir.path, 'config', 'passwords.yaml'));
    if (!file.existsSync()) return {};

    final Object? decoded;
    try {
      decoded = yamlDecode(file.readAsStringSync());
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to parse config/passwords.yaml',
      );
    }
    if (decoded is! Map) return {};

    final passwords = <_Password>{
      for (final section in PasswordSection.values)
        ..._readPasswords(decoded, section),
    };

    return passwords;
  }

  static Set<_Password> _readPasswords(
    final Map<dynamic, dynamic> decoded,
    final PasswordSection section,
  ) {
    final passwords = <_Password>{};
    final sectionData = decoded[section.name];
    if (sectionData is! Map) return {};
    for (final entry in sectionData.entries) {
      final value = entry.value;
      if (value == null || value is Map || value is Iterable) continue;
      passwords.add(
        _Password(
          name: entry.key.toString(),
          value: value.toString(),
          section: section,
        ),
      );
    }
    return passwords;
  }

  static Future<String?> _selectExistingProject(
    final Client cloudApiClient,
    final List<ProjectInfo> existingProjects,
    final CommandLogger logger,
  ) async {
    if (existingProjects.isEmpty) {
      final confirm = await logger.confirm(
        'Open the browser and create a new Serverpod Cloud project?',
        defaultValue: true,
      );
      if (!confirm) {
        logger.info('Setup cancelled.');
        throw UserAbortException();
      }
      return null; // create a new project
    }

    existingProjects.sort((final a, final b) {
      // if both or neither are null, keep the order
      if ((a.latestDeployAttemptTime?.timestamp == null) ==
          (b.latestDeployAttemptTime?.timestamp == null)) {
        return 0;
      }
      // if one is null and the other is not, put the null one first
      return (a.latestDeployAttemptTime?.timestamp == null) ? -1 : 1;
    });

    final projectLabels = existingProjects.map((final p) {
      final lastDeployedTime = p.latestDeployAttemptTime?.timestamp;
      final lastDeployed = lastDeployedTime == null
          ? 'available for first deployment'
          : 'available for redeploy (last deployed ${lastDeployedTime.toString().substring(0, 16)})';
      return '${p.project.cloudProjectId.padRight(30)}$lastDeployed';
    });
    final optionLabels = [
      ...projectLabels,
      'Open the browser and create a new project',
    ];
    final options = optionLabels
        .mapIndexed((final i, final r) => (i, r))
        .toList();

    final selected = await SelectList.choose(
      prompt:
          'Select a Serverpod Cloud project to deploy to, or create a new project:',
      options: options,
      label: (final o) => o.$2,
      terminal: logger.inlineTerminal,
      style: SelectListStyle(highlightStyle: _projectFactStyle.ansiCode),
    );
    if (selected == null) {
      logger.info('Setup cancelled.');
      return throw UserAbortException();
    }
    if (selected.$1 == existingProjects.length) {
      return null; // create a new project
    }
    return existingProjects[selected.$1].project.cloudProjectId;
  }

  static Future<List<Project>> _fetchExistingUndeployedProjects(
    final Client cloudApiClient,
  ) async {
    try {
      final projects = await cloudApiClient.projects.listProjectsInfo(
        includeLatestDeployAttemptTime: true,
      );
      return projects
          .where((final p) => p.project.archivedAt == null)
          .where((final p) => p.latestDeployAttemptTime?.timestamp == null)
          .map((final p) => p.project)
          .toList();
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Request to list projects failed');
    }
  }

  static String? _getDefaultProjectId(final ProjectLaunch projectSetup) {
    final projectPubspec = projectSetup.projectPubspec;
    if (projectPubspec.isServerpodServer()) {
      var name = projectPubspec.pubspec.name.toLowerCase().replaceAll('_', '-');

      const serverSuffix = '-server';
      if (name.length > serverSuffix.length && name.endsWith(serverSuffix)) {
        name = name.substring(0, name.length - serverSuffix.length);
      }

      if (isValidProjectIdFormat(name)) {
        return name;
      }
    }
    return null;
  }

  static Future<void> suggestFlutterBuildPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (!projectSetup.includePreDeployScripts) return;

    final projectPubspec = projectSetup.projectPubspec;
    final configFilePath = projectSetup.configFilePath;

    if (!projectPubspec.hasFlutterBuildScript()) return;

    ScloudConfig? existingConfig;
    try {
      existingConfig = ScloudConfigIO.readFromFile(configFilePath);
    } catch (_) {
      logger.debug('Failed to read config file at $configFilePath');
      return;
    }

    final flutterBuildHook = 'serverpod run flutter_build';

    final existingPreDeploy = existingConfig?.scripts.preDeploy ?? [];
    if (existingPreDeploy.contains(flutterBuildHook)) return;

    logger.debug(
      "Detected 'flutter_build' script. Adding it as a pre-deploy hook.",
    );
    projectSetup.suggestedPreDeployScripts.add(flutterBuildHook);
  }

  static Future<void> suggestCodeGenerationPreDeployHook(
    final CommandLogger logger,
    final ProjectLaunch projectSetup,
  ) async {
    if (!projectSetup.includePreDeployScripts) return;

    final configFilePath = projectSetup.configFilePath;
    ScloudConfig? existingConfig;
    try {
      existingConfig = ScloudConfigIO.readFromFile(configFilePath);
    } catch (_) {
      logger.debug('Failed to read config file at $configFilePath');
    }

    final codeGenerationHook = 'serverpod generate';

    final existingPreDeploy = existingConfig?.scripts.preDeploy ?? [];
    if (existingPreDeploy.contains(codeGenerationHook)) return;

    logger.debug(
      "Adding code generation ('serverpod generate') as a pre-deploy hook.",
    );
    projectSetup.suggestedPreDeployScripts.add(codeGenerationHook);
  }

  static Future<void> performLaunch(
    final Client cloudApiClient,
    final FileUploaderFactory fileUploaderFactory,
    final CommandLogger logger,
    final ProjectLaunch projectSetup, {
    required final String consoleServer,
    required final bool openBrowser,
    required final int deployConcurrency,
    required final bool wetRun,
    required final bool deployShowFiles,
    final String? deployOutputPath,
    final bool deploySkipTailingStatus = false,
    final IOSink? stdout,
    final IOSink? stderr,
  }) async {
    final projectId = projectSetup.projectId;
    if (projectId == null) {
      throw StateError('Project ID not set in project setup.');
    }

    final projectDir = projectSetup.projectDir;
    final configFilePath = projectSetup.configFilePath;
    final performDeploy = projectSetup.performDeploy;

    await ProjectCommands.linkProject(
      cloudApiClient,
      logger: logger,
      projectId: projectId,
      projectDirectory: projectDir.path,
      configFilePath: configFilePath,
      dartVersionOverride: projectSetup.dartVersionOverride,
      preDeployScripts: projectSetup.suggestedPreDeployScripts,
      suppressCommandMessages: true,
    );

    await _populateCustomPasswords(
      cloudApiClient,
      logger,
      projectId: projectId,
      passwords: projectSetup.selectedPasswords,
    );

    if (!performDeploy) {
      logger.terminalCommand(
        'scloud launch',
        message:
            'Deployment skipped. Run this command again to deploy to the cloud:',
        newParagraph: true,
      );
      return;
    }

    await Deploy.deploy(
      cloudApiClient,
      fileUploaderFactory,
      logger: logger,
      projectId: projectId,
      projectDir: projectDir.path,
      projectConfigFilePath: configFilePath,
      concurrency: deployConcurrency,
      wetRun: wetRun,
      showFiles: deployShowFiles,
      outputPath: deployOutputPath,
      skipTailingStatus: deploySkipTailingStatus,
      suppressCommandMessages: true,
      dartVersionOverride: projectSetup.dartVersionOverride,
      stdout: stdout,
      stderr: stderr,
    );

    if (wetRun) return;

    _displayProjectInfo(logger: logger, actualProjectId: projectId);

    logger.terminalCommand(
      'scloud help deployment',
      message: 'To see how to view deployment statuses, run this command:',
      newParagraph: true,
    );
  }

  static void _displayProjectInfo({
    required final CommandLogger logger,
    required final String actualProjectId,
  }) {
    final projectIdStr = logger.wrapStyle(actualProjectId, _projectFactStyle);
    logger.info(
      'Your Serverpod Cloud project ID is: $projectIdStr',
      newParagraph: true,
    );

    final webUrl = logger.wrapStyle(
      'https://$actualProjectId.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    final apiUrl = logger.wrapStyle(
      'https://$actualProjectId.api.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    final insightsUrl = logger.wrapStyle(
      'https://$actualProjectId.insights.${HostConstants.tenantDomain}/',
      _projectFactStyle,
    );
    logger.info(
      'When the server has started, you can access it at:\n'
      '   Web:      $webUrl\n'
      '   API:      $apiUrl\n'
      '   Insights: $insightsUrl',
      newParagraph: true,
    );
  }

  /// Hands off project creation to the Serverpod Cloud console.
  ///
  /// Opens the console's create-project page, forwarding the analyzed project
  /// information ([projectName] and whether the project [usesDb]), and waits
  /// for the console to redirect back to a local callback server with the id of
  /// the created project. Returns the created project id.
  static Future<String> createProject(
    final CommandLogger logger, {
    required final String consoleServer,
    required final bool openBrowser,
    required final String projectName,
    required final bool usesDb,
    final Duration timeLimit = const Duration(minutes: 5),
  }) async {
    final callbackUrlFuture = Completer<Uri>();
    final projectIdFuture = ListenerServer.listenForCallback(
      queryParameter: 'projectId',
      logger: logger,
      onConnected: callbackUrlFuture.complete,
      timeLimit: timeLimit,
      successMessage:
          'The Serverpod Cloud project has been created, you may now close this window and return to the CLI.',
      failureMessage:
          'The Serverpod Cloud project creation failed, please try again or contact support.',
    );

    final callbackUrl = await callbackUrlFuture.future;
    final createProjectUrl = Uri.parse(consoleServer).replace(
      path: ConsoleRoutes.createProject,
      queryParameters: {
        'project-name': projectName,
        'database-enabled': usesDb.toString(),
        'return-url': callbackUrl.toString(),
      },
    );

    logger.info(
      'Create your Serverpod Cloud project in the opened browser or through this link:\n'
      '$createProjectUrl',
    );

    if (openBrowser) {
      try {
        await BrowserLauncher.openUrl(createProjectUrl);
      } on Exception catch (e) {
        logger.error('Failed to open browser', exception: e);
      }
    }

    String? createdProjectId;
    await logger.progress(
      'Waiting for project creation',
      successMessage: 'Serverpod Cloud project created.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        createdProjectId = await projectIdFuture;
        return createdProjectId != null;
      },
    );
    logger.info(' ');

    final projectId = createdProjectId;
    if (projectId == null) {
      throw FailureException(
        error: 'Failed to create project.',
        hint: 'Please try again.',
      );
    }

    return projectId;
  }

  static Future<void> _populateCustomPasswords(
    final Client cloudApiClient,
    final CommandLogger logger, {
    required final String projectId,
    required final Map<String, String> passwords,
  }) async {
    if (passwords.isEmpty) return;

    await logger.progress(
      'Setting custom passwords',
      successMessage: 'Custom passwords set in cloud.',
      padRight: StatusCommands.progressMessagePadLength,
      () async {
        await PasswordOperations.setPasswords(
          cloudApiClient,
          projectId: projectId,
          passwords: passwords,
        );
        return true;
      },
    );
  }
}

String _hidePassword(final String password) {
  final included = math.min(password.length, 4);
  return '${password.substring(0, included)}*****';
}

/// The order of the sections is significant for the password value precedence.
/// Earlier sections override later sections.
enum PasswordSection { production, shared, staging, test, development }

class _Password {
  final String name;
  final String value;
  final PasswordSection section;

  _Password({required this.name, required this.value, required this.section});

  @override
  String toString() {
    return '$name: ${_hidePassword(value)}';
  }

  @override
  bool operator ==(final Object other) {
    if (other is _Password) return name == other.name;
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}

class ProjectLaunch {
  final Directory projectDir;
  final TenantProjectPubspec projectPubspec;
  final bool usesDb;
  late final String configFilePath;
  String? projectId;
  String? dartVersionOverride;
  bool? preexistingProject;
  bool? preexistingProjectDeployed;
  final bool performDeploy;
  final bool includePreDeployScripts;
  final List<String> suggestedPreDeployScripts;
  Map<String, String> selectedPasswords;

  ProjectLaunch({
    required this.projectDir,
    required this.projectPubspec,
    required this.usesDb,
    required this.includePreDeployScripts,
    this.projectId,
    this.dartVersionOverride,
    this.preexistingProject,
    this.preexistingProjectDeployed,
    this.performDeploy = true,
    final List<String>? suggestedPreDeployScripts,
    final Map<String, String>? selectedPasswords,
  }) : suggestedPreDeployScripts = suggestedPreDeployScripts ?? [],
       selectedPasswords = selectedPasswords ?? {} {
    configFilePath = _constructConfigFilePath(projectDir.path);
  }

  String _constructConfigFilePath(final String projectDir) {
    return p.join(projectDir, ProjectConfigFileConstants.defaultFileName);
  }

  @override
  String toString() {
    final text = TablePrinter.columns(
      rows: [
        ['Project directory', projectDir.path],
        if (preexistingProject != true) ...[
          ['Create new project', 'yes'],
          ['Uses DB', usesDb ? 'yes' : 'no'],
        ] else
          ['Existing project', projectId],
        if (suggestedPreDeployScripts.isNotEmpty) ...[
          [
            'Pre-deploy hooks',
            suggestedPreDeployScripts
                .map((final hook) => "- '$hook'")
                .join('\n                    '),
          ],
        ],
      ],
      columnSeparator: '  ',
    ).toString();
    return text.substring(0, text.length - 1); // trims last newline
  }
}
