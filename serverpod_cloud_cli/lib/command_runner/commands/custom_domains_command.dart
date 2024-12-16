import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/table_printer.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';

class CloudCustomDomainCommand extends CloudCliCommand {
  @override
  final name = 'domains';

  @override
  final description = 'Manage Serverpod Cloud custom domains.';

  CloudCustomDomainCommand({required super.logger}) {
    addSubcommand(CloudAddCustomDomainCommand(logger: logger));
    addSubcommand(CloudListCustomDomainCommand(logger: logger));
    addSubcommand(CloudRemoveCustomDomainCommand(logger: logger));
    addSubcommand(CloudRefreshCustomDomainRecordCommand(logger: logger));
  }
}

abstract final class CustomDomainCommandConfig {
  static const projectId = ProjectIdOption();

  static const domainName = NameOption(
    helpText: 'The custom domain name. Can be passed as the first argument.',
    argPos: 0,
  );

  static const target = ConfigOption(
    argName: 'target',
    argAbbrev: 't',
    helpText: 'The target of the custom domain.',
    mandatory: true,
    valueHelp: '[api|web|insights]',
  );
}

enum AddCustomDomainCommandConfig implements OptionDefinition {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName),
  target(CustomDomainCommandConfig.target);

  const AddCustomDomainCommandConfig(this.option);

  @override
  final ConfigOption option;
}

class CloudAddCustomDomainCommand
    extends CloudCliCommand<AddCustomDomainCommandConfig> {
  @override
  String get description => 'Add a custom domain.';

  @override
  String get name => 'add';

  CloudAddCustomDomainCommand({required super.logger})
      : super(options: AddCustomDomainCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AddCustomDomainCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(AddCustomDomainCommandConfig.projectId);
    final domainName =
        commandConfig.value(AddCustomDomainCommandConfig.domainName);
    final target = commandConfig.value(AddCustomDomainCommandConfig.target);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    final parsedTarget = _domainNameTargetfromString(target);

    late CustomDomainNameWithDefaultDomains customDomainNameWithDefaultDomains;

    await handleCommonClientExceptions(
      logger,
      () async {
        customDomainNameWithDefaultDomains =
            await apiCloudClient.customDomainName.add(
          domainName: domainName,
          target: parsedTarget,
          cloudEnvironmentId: projectId,
        );
      },
      (final e) {
        logger.error(
          'Could not add the custom domain.',
          hint: e,
        );

        throw ExitException();
      },
    );

    logger.success('Custom domain added successfully!', newParagraph: true);

    final targetDefaultDomain =
        customDomainNameWithDefaultDomains.defaultDomainsByTarget[parsedTarget];

    if (targetDefaultDomain == null) {
      logger.error(
        'Could not find the target domain for "$target".',
        hint: 'Please check that CLI is updated to the latest version.',
      );
      throw ExitException();
    }

    logger.list(
      newParagraph: true,
      title: 'Follow these steps to complete setup:',
      [
        'Add a CNAME record with the value "$targetDefaultDomain" to the DNS configuration for this domain.',
        'Wait for the update to propagate. This can take up to a few hours.',
        'Run the following command to verify the DNS record (Serverpod Cloud will also try to verify the record periodically):',
      ],
    );

    logger.terminalCommand(
      newParagraph: true,
      'scloud domains refresh-record $domainName --project-id $projectId',
    );

    logger.list(newParagraph: true, [
      'When verification succeeds, the custom domain will shortly become active.',
      'Run the following command to check the status:'
    ]);

    logger.terminalCommand(
      newParagraph: true,
      'scloud domains list --project-id $projectId',
    );
  }
}

enum ListCustomDomainCommandConfig implements OptionDefinition {
  projectId(CustomDomainCommandConfig.projectId);

  const ListCustomDomainCommandConfig(this.option);

  @override
  final ConfigOption option;
}

class CloudListCustomDomainCommand
    extends CloudCliCommand<ListCustomDomainCommandConfig> {
  @override
  String get description => 'List all custom domains.';

  @override
  String get name => 'list';

  CloudListCustomDomainCommand({required super.logger})
      : super(options: ListCustomDomainCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<ListCustomDomainCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(ListCustomDomainCommandConfig.projectId);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late CustomDomainNameList domainNamesList;
    await handleCommonClientExceptions(logger, () async {
      domainNamesList = await apiCloudClient.customDomainName.list(
        cloudEnvironmentId: projectId,
      );
    }, (final e) {
      logger.error(
        'Failed to list custom domains.',
        hint: e,
      );

      throw ExitException();
    });

    final defaultDomainPrinter = TablePrinter();
    defaultDomainPrinter.addHeaders(['Default domain name', 'Target']);

    for (var domainName in domainNamesList.defaultDomainsByTarget.entries) {
      defaultDomainPrinter.addRow([
        domainName.value,
        domainName.key.toString(),
      ]);
    }

    final customDomainPrinter = TablePrinter();
    customDomainPrinter.addHeaders(['Custom domain name', 'Target', 'Status']);
    for (var domainName in domainNamesList.customDomainNames) {
      customDomainPrinter.addRow([
        domainName.name,
        domainNamesList.defaultDomainsByTarget[domainName.target],
        _getStatusLabel(domainName.status),
      ]);
    }

    logger.info(defaultDomainPrinter.toString());
    logger.info(customDomainPrinter.toString());
  }

  _getStatusLabel(final DomainNameStatus status) {
    switch (status) {
      case DomainNameStatus.configured:
        return 'Configured';
      case DomainNameStatus.pending:
        return 'Certificate creation pending';
      case DomainNameStatus.needsSetup:
        return 'Needs setup';
    }
  }
}

enum RemoveCustomDomainCommandConfig implements OptionDefinition {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName);

  const RemoveCustomDomainCommandConfig(this.option);

  @override
  final ConfigOption option;
}

class CloudRemoveCustomDomainCommand
    extends CloudCliCommand<RemoveCustomDomainCommandConfig> {
  @override
  String get description => 'Remove a custom domain.';

  @override
  String get name => 'remove';

  CloudRemoveCustomDomainCommand({required super.logger})
      : super(options: RemoveCustomDomainCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<RemoveCustomDomainCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(RemoveCustomDomainCommandConfig.projectId);
    final domainName =
        commandConfig.value(RemoveCustomDomainCommandConfig.domainName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.customDomainName.remove(
        cloudEnvironmentId: projectId,
        domainName: domainName,
      );
    }, (final e) {
      logger.error(
        'Failed to remove custom domain.',
        hint: e,
      );

      throw ExitException();
    });

    logger.success('Successfully removed custom domain: $domainName.');
  }
}

enum RefreshCustomDomainRecordCommandConfig implements OptionDefinition {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName);

  const RefreshCustomDomainRecordCommandConfig(this.option);

  @override
  final ConfigOption option;
}

class CloudRefreshCustomDomainRecordCommand
    extends CloudCliCommand<RefreshCustomDomainRecordCommandConfig> {
  @override
  String get description => 'Refresh a custom domain record.';

  @override
  String get name => 'refresh-record';

  CloudRefreshCustomDomainRecordCommand({required super.logger})
      : super(options: RefreshCustomDomainRecordCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<RefreshCustomDomainRecordCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(RefreshCustomDomainRecordCommandConfig.projectId);
    final domainName =
        commandConfig.value(RefreshCustomDomainRecordCommandConfig.domainName);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(logger, () async {
      final result = await apiCloudClient.customDomainName.refreshRecord(
        cloudEnvironmentId: projectId,
        domainName: domainName,
      );

      switch (result) {
        case DomainNameStatus.configured:
          logger.success(
              'Successfully verified the DNS record for the custom domain. It is now active.');
        case DomainNameStatus.needsSetup:
          logger.info('Failed to verify the DNS record for the custom domain. '
              'Ensure the CNAME is correctly set and try again later.');
        case DomainNameStatus.pending:
          logger.info(
            'The DNS record for the custom domain is verified but certificate creation is still pending. '
            'Try again in a few minutes.',
          );
      }

      return;
    }, (final e) {
      logger.error(
        'Failed to refresh custom domain record',
        hint: e,
      );

      throw ExitException();
    });
  }
}

DomainNameTarget _domainNameTargetfromString(final String value) {
  switch (value) {
    case 'api':
      return DomainNameTarget.api;
    case 'web':
      return DomainNameTarget.web;
    case 'insights':
      return DomainNameTarget.insights;
    default:
      throw CloudCliUsageException(
        'Invalid target value "$value".',
        hint: 'Valid values are: [${DomainNameTarget.values.join(', ')}]',
      );
  }
}
