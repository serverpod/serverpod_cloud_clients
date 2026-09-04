import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show BucketVisibility;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;
import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart'
    show StorageIdValidator;

class CloudStorageCommand extends CloudCliCommand {
  @override
  final name = 'storage';

  @override
  String get description => '''Manage file storage for a project.

A storage holds the files your project uploads at runtime, such as user avatars or generated documents.
Every project starts with a private storage "private" and a public storage "public".
''';

  @override
  String get category => CommandCategories.control;

  CloudStorageCommand({required super.logger}) {
    addSubcommand(CloudStorageListCommand(logger: logger));
    addSubcommand(CloudStorageCreateCommand(logger: logger));
    addSubcommand(CloudStorageDeleteCommand(logger: logger));
    addSubcommand(CloudStorageFileCommand(logger: logger));
  }
}

abstract final class StorageCommandConfig {
  static const projectId = ProjectIdOption();
  static const storageId = StringOption(
    argName: 'storage',
    argAbbrev: 's',
    argPos: 0,
    helpText: 'The id of the storage. Can be passed as the first argument.',
    mandatory: true,
  );
  static const newStorageId = StringOption(
    argName: 'storage',
    argAbbrev: 's',
    argPos: 0,
    helpText:
        'The id of the new storage. Lowercase letters, digits and dashes. '
        'Can be passed as the first argument.',
    mandatory: true,
    customValidator: _validateStorageId,
  );
  static const optionalPath = StringOption(
    argName: 'path',
    argPos: 1,
    helpText:
        'A folder path inside the storage. '
        'Can be passed as the second argument.',
  );
  static const utc = UtcOption();

  static void _validateStorageId(final String value) {
    final reason = StorageIdValidator.validate(value);
    if (reason != null) {
      throw UsageException(reason, '');
    }
  }
}

enum StorageListCommandConfig<V> implements OptionDefinition<V> {
  projectId(StorageCommandConfig.projectId);

  const StorageListCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStorageListCommand
    extends CloudCliCommand<StorageListCommandConfig> {
  @override
  String get description => 'List the storages of a project.';

  @override
  String get name => 'list';

  @override
  final bool takesArguments = false;

  CloudStorageListCommand({required super.logger})
    : super(options: StorageListCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StorageListCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(StorageListCommandConfig.projectId);

    await renderCommand(
      output,
      operation: () => StorageOperations.listStorages(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        baseCommand: baseCommand,
      ),
      textOutputUi: StorageListTextUi(baseCommand: baseCommand),
    );
  }
}

enum StorageCreateCommandConfig<V> implements OptionDefinition<V> {
  projectId(StorageCommandConfig.projectId),
  storageId(StorageCommandConfig.newStorageId),
  access(
    EnumOption<BucketVisibility>(
      argName: 'access',
      argAbbrev: 'a',
      helpText:
          'Who can read the files. '
          '"private": only your project. "public": anyone with the URL. '
          'Cannot be changed later.',
      defaultsTo: BucketVisibility.private,
      enumParser: EnumParser(BucketVisibility.values),
    ),
  );

  const StorageCreateCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStorageCreateCommand
    extends CloudCliCommand<StorageCreateCommandConfig> {
  @override
  String get description => '''Create a storage.

The access of a storage decides who can read its files, and is fixed at creation.
A private storage is only readable by your project, a public storage is readable by anyone with the URL.
''';

  @override
  String get name => 'create';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Create a private storage called user-uploads.

    \$ $baseCommand storage create user-uploads

  Create a storage whose files anyone with the URL can read.

    \$ $baseCommand storage create assets --access public
''';

  CloudStorageCreateCommand({required super.logger})
    : super(options: StorageCreateCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StorageCreateCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(StorageCreateCommandConfig.projectId);
    final storageId = commandConfig.value(StorageCreateCommandConfig.storageId);
    final access = commandConfig.value(StorageCreateCommandConfig.access);

    await renderCommand(
      output,
      operation: () => StorageOperations.createStorage(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        storageId: storageId,
        access: access,
        baseCommand: baseCommand,
      ),
      textOutputUi: StorageCreateTextUi(baseCommand: baseCommand),
    );
  }
}

enum StorageDeleteCommandConfig<V> implements OptionDefinition<V> {
  projectId(StorageCommandConfig.projectId),
  storageId(StorageCommandConfig.storageId);

  const StorageDeleteCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStorageDeleteCommand
    extends CloudCliCommand<StorageDeleteCommandConfig> {
  @override
  String get description =>
      'Delete a storage and every file in it. This cannot be undone.';

  @override
  String get name => 'delete';

  @override
  String get category => CommandCategories.dangerZone;

  CloudStorageDeleteCommand({required super.logger})
    : super(options: StorageDeleteCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StorageDeleteCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(StorageDeleteCommandConfig.projectId);
    final storageId = commandConfig.value(StorageDeleteCommandConfig.storageId);

    await confirmToContinue(
      output,
      message:
          'Delete storage "$storageId" and every file in it? '
          'This cannot be undone.',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => StorageOperations.deleteStorage(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        storageId: storageId,
        baseCommand: baseCommand,
      ).then((_) => {'storageId': storageId}),
      textOutputUi: const StorageDeleteTextUi(),
    );
  }
}

class CloudStorageFileCommand extends CloudCliCommand {
  @override
  final name = 'file';

  @override
  String get description => 'Manage the files in a storage.';

  @override
  String get category => CommandCategories.control;

  CloudStorageFileCommand({required super.logger}) {
    addSubcommand(CloudStorageFileListCommand(logger: logger));
  }
}

enum StorageFileListCommandConfig<V> implements OptionDefinition<V> {
  projectId(StorageCommandConfig.projectId),
  storageId(StorageCommandConfig.storageId),
  path(StorageCommandConfig.optionalPath),
  tree(
    FlagOption(
      argName: 'tree',
      argAbbrev: 't',
      helpText: 'Show the files as a directory tree instead of a table.',
      negatable: false,
      defaultsTo: false,
    ),
  ),
  utc(StorageCommandConfig.utc);

  const StorageFileListCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStorageFileListCommand
    extends CloudCliCommand<StorageFileListCommandConfig> {
  @override
  String get description => '''List the files in a storage.

Listing is recursive. Pass a folder path to list only the files under it.
''';

  @override
  String get name => 'list';

  @override
  String? get usageExamples =>
      '''\n
Examples

  List every file in the storage "public".

    \$ $baseCommand storage file list public

  List the files under the folder "avatars".

    \$ $baseCommand storage file list public avatars

  Show the files as a directory tree.

    \$ $baseCommand storage file list public --tree
''';

  CloudStorageFileListCommand({required super.logger})
    : super(options: StorageFileListCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StorageFileListCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      StorageFileListCommandConfig.projectId,
    );
    final storageId = commandConfig.value(
      StorageFileListCommandConfig.storageId,
    );
    final path = commandConfig.optionalValue(StorageFileListCommandConfig.path);
    final tree = commandConfig.value(StorageFileListCommandConfig.tree);
    final utc = commandConfig.value(StorageFileListCommandConfig.utc);

    await renderCommand(
      output,
      operation: () => StorageOperations.listFiles(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        storageId: storageId,
        path: path,
        baseCommand: baseCommand,
      ),
      textOutputUi: StorageFileListTextUi(utc: utc, tree: tree),
    );
  }
}
