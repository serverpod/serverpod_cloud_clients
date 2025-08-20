import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/commands/user/user.dart';

import 'categories.dart';

class CloudUserCommand extends CloudCliCommand {
  @override
  final name = 'user';

  @override
  final description = 'Manage Serverpod Cloud users.';

  @override
  String get category => CommandCategories.manage;

  CloudUserCommand({required super.logger}) {
    addSubcommand(UserListCommand(logger: logger));
  }
}

enum ListUsersOption<V> implements OptionDefinition<V> {
  projectId(ProjectIdOption());

  const ListUsersOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class UserListCommand extends CloudCliCommand<ListUsersOption> {
  @override
  final name = 'list';

  @override
  final description = 'List Serverpod Cloud users.';

  UserListCommand({required super.logger})
      : super(options: ListUsersOption.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ListUsersOption> commandConfig,
  ) async {
    final projectId = commandConfig.value(ListUsersOption.projectId);

    await UserCommands.listUsers(
      runner.serviceProvider.cloudApiClient,
      logger: logger,
      projectId: projectId,
    );
  }
}
