import 'dart:io';

import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart'
    show BucketVisibility;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/byte_size.dart';
import 'package:serverpod_cloud_cli/util/file_dir_option.dart';
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
  static const uploadSource = FileDirOption(
    argName: 'file',
    argAbbrev: 'f',
    argPos: 1,
    helpText:
        'The local file or directory to upload. '
        'A directory is uploaded with everything in it. '
        'Can be passed as the second argument.',
    mandatory: true,
    mode: PathExistMode.mustExist,
  );
  static const uploadPath = StringOption(
    argName: 'path',
    argPos: 2,
    helpText:
        'The destination path inside the storage. '
        'Defaults to the file or directory name. '
        'End it with "/" to upload into a folder. '
        'Can be passed as the third argument.',
  );

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
    addSubcommand(CloudStorageFileUploadCommand(logger: logger));
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

enum StorageFileUploadCommandConfig<V> implements OptionDefinition<V> {
  projectId(StorageCommandConfig.projectId),
  storageId(StorageCommandConfig.storageId),
  file(StorageCommandConfig.uploadSource),
  path(StorageCommandConfig.uploadPath);

  const StorageFileUploadCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudStorageFileUploadCommand
    extends CloudCliCommand<StorageFileUploadCommandConfig> {
  @override
  String get description => '''Upload a local file or directory to a storage.

A directory is uploaded with everything in it, and the command asks for confirmation before it starts.
Uploading to a path that already holds a file fails, so delete the file first to replace it.
''';

  @override
  String get name => 'upload';

  @override
  String? get usageExamples =>
      '''\n
Examples

  Upload avatar.png to the root of the storage "public".

    \$ $baseCommand storage file upload public ./avatar.png

  Upload it into the folder "avatars" under a new name.

    \$ $baseCommand storage file upload public ./avatar.png avatars/u1.png

  Upload it into the folder "avatars", keeping the file name.

    \$ $baseCommand storage file upload public ./avatar.png avatars/

  Upload a whole directory, keeping its name and structure.

    \$ $baseCommand storage file upload public ./avatars

  Upload the directory under another name.

    \$ $baseCommand storage file upload public ./avatars images
''';

  CloudStorageFileUploadCommand({required super.logger})
    : super(options: StorageFileUploadCommandConfig.values);

  @override
  Future<void> runWithOutput(
    final Configuration<StorageFileUploadCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      StorageFileUploadCommandConfig.projectId,
    );
    final storageId = commandConfig.value(
      StorageFileUploadCommandConfig.storageId,
    );
    final source = commandConfig.value(StorageFileUploadCommandConfig.file);
    final path = commandConfig.optionalValue(
      StorageFileUploadCommandConfig.path,
    );

    final items = await StorageOperations.collectUploadItems(
      source: source,
      path: path,
    );

    if (source is Directory) {
      await confirmToContinue(
        output,
        message: _uploadPlanMessage(source, items, storageId),
        defaultValue: true,
      );
    }

    await renderCommand(
      output,
      operation: () => StorageOperations.uploadFiles(
        runner.serviceProvider.cloudApiClient,
        runner.serviceProvider.fileUploaderFactory,
        logger,
        projectId: projectId,
        storageId: storageId,
        items: items,
        baseCommand: baseCommand,
      ),
      textOutputUi: const StorageFileUploadTextUi(),
    );
  }
}

const _maxListedUploadItems = 20;

String _uploadPlanMessage(
  final Directory source,
  final List<UploadItem> items,
  final String storageId,
) {
  final totalBytes = items.fold<int>(
    0,
    (final sum, final item) => sum + item.sizeBytes,
  );
  final listed = items.take(_maxListedUploadItems);
  final remaining = items.length - listed.length;

  return [
    'The directory "${source.path}" contains ${items.length} '
        '${items.length == 1 ? 'file' : 'files'} '
        '(${formatByteSize(totalBytes)}):',
    '',
    for (final item in listed) '  ${item.remotePath}',
    if (remaining > 0) '  ... and $remaining more',
    '',
    'Upload them to storage "$storageId"?',
  ].join('\n');
}
