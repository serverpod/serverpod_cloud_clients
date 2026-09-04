import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

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
