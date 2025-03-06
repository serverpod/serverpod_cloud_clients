import 'package:basic_utils/basic_utils.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/common_exceptions_handler.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/cloud_cli_usage_exception.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

class CloudCustomDomainCommand extends CloudCliCommand {
  @override
  final name = 'domain';

  @override
  final description = r'''
Bring your own domain to Serverpod Cloud. 

Get started by adding a custom domain to your project with the command:

  $ scloud domain add example.com <target> --project <project-id>

The valid targets are:
- api: Serverpod endpoints
- insights: Serverpod insights
- web: Relic server (e.g. REST API or a Flutter web app)
''';

  CloudCustomDomainCommand({required super.logger}) {
    addSubcommand(CloudAddCustomDomainCommand(logger: logger));
    addSubcommand(CloudListCustomDomainCommand(logger: logger));
    addSubcommand(CloudRemoveCustomDomainCommand(logger: logger));
    addSubcommand(CloudVerifyCustomDomainRecordCommand(logger: logger));
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
    argPos: 1,
    helpText:
        'The Serverpod server target of the custom domain, only one can be specified.',
    mandatory: true,
    valueHelp: '[ api | web | insights ]',
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
  String get description => '''
Add a custom domain to your project.

You need to have a domain name and a DNS provider that supports 
TXT, CNAME and/or ANAME records.

You can add domains for each Serverpod server target.

The valid targets are:
- api: Serverpod endpoints
- insights: Serverpod insights
- web: Relic server (e.g. REST API or a Flutter web app)
''';

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
          cloudCapsuleId: projectId,
        );
      },
      (final e) {
        logger.error(
          'Could not add the custom domain: $e',
        );

        throw ErrorExitException();
      },
    );

    logger.success('Custom domain added successfully!', newParagraph: true);

    final targetDefaultDomain =
        customDomainNameWithDefaultDomains.defaultDomainsByTarget[parsedTarget];

    if (targetDefaultDomain == null) {
      logger.error(
        'Could not find the target domain for "$target".',
      );
      throw ErrorExitException();
    }

    if (DomainUtils.isSubDomain(domainName)) {
      _logDomainInstructions(
        action: 'Add a CNAME record with the value "$targetDefaultDomain" '
            'to the DNS configuration for this domain.',
        logger: logger,
        domainName: domainName,
        projectId: projectId,
        records: [
          (type: 'CNAME', value: targetDefaultDomain),
        ],
      );
      return;
    }

    _logDomainInstructions(
      action: 'Add a TXT record with the name "$targetDefaultDomain" and '
          'value "${customDomainNameWithDefaultDomains.customDomainName.dnsRecordVerificationValue}".',
      logger: logger,
      domainName: domainName,
      projectId: projectId,
      records: [
        (
          type: 'ANAME',
          value: targetDefaultDomain,
        ),
        (
          type: 'TXT',
          value: customDomainNameWithDefaultDomains
              .customDomainName.dnsRecordVerificationValue
        ),
      ],
    );
  }

  void _logDomainInstructions({
    required final CommandLogger logger,
    required final String domainName,
    required final String projectId,
    required final String action,
    required final List<({String type, String value})> records,
  }) {
    logger.info(
      'Complete the setup by adding the records to your DNS configuration',
      newParagraph: true,
    );

    final tablePrinter = TablePrinter();

    tablePrinter.addHeaders(['Record type', 'Domain name', 'Value']);
    for (final record in records) {
      tablePrinter.addRow([record.type, domainName, record.value]);
    }

    logger.box(tablePrinter.toString(), newParagraph: true);

    logger.info(
      'Check the status of the setup by running the command:',
      newParagraph: true,
    );

    logger.terminalCommand(
      newParagraph: true,
      'scloud domain list --project $projectId',
    );

    logger.list(
      title: 'Additional context',
      [
        'DNS propagation can take up to 24 hours to complete.',
        'Serverpod Cloud will periodically verify the record(s).',
        'To manually force a verification, run the command:',
      ],
      newParagraph: true,
    );

    logger.terminalCommand(
      newParagraph: true,
      'scloud domain verify $domainName --project $projectId',
    );

    logger.info(' ', newParagraph: true);
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
        cloudCapsuleId: projectId,
      );
    }, (final e) {
      logger.error(
        'Failed to list custom domains: $e',
      );

      throw ErrorExitException();
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

    defaultDomainPrinter.writeLines(logger.line);
    logger.line('');
    customDomainPrinter.writeLines(logger.line);
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

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the custom domain "$domainName"?',
      defaultValue: false,
      checkBypassFlag: runner.globalConfiguration.flag,
    );

    if (!shouldDelete) {
      throw ErrorExitException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    await handleCommonClientExceptions(logger, () async {
      await apiCloudClient.customDomainName.remove(
        cloudCapsuleId: projectId,
        domainName: domainName,
      );
    }, (final e) {
      logger.error(
        'Failed to remove custom domain: $e',
      );

      throw ErrorExitException();
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

class CloudVerifyCustomDomainRecordCommand
    extends CloudCliCommand<RefreshCustomDomainRecordCommandConfig> {
  @override
  String get description => 'Verify the DNS record for a custom domain.';

  @override
  String get name => 'verify';

  CloudVerifyCustomDomainRecordCommand({required super.logger})
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
        cloudCapsuleId: projectId,
        domainName: domainName,
      );

      switch (result) {
        case DomainNameStatus.configured:
          logger.success(
              'Successfully verified the DNS record for the custom domain. It is now active.');
        case DomainNameStatus.needsSetup:
          logger.info('Failed to verify the DNS record for the custom domain.');
        case DomainNameStatus.pending:
          logger.info(
            'The DNS record for the custom domain is verified but certificate creation is still pending. '
            'Try again in a few minutes.',
          );
      }

      return;
    }, (final e) {
      if (e is DNSVerificationFailedException) {
        logger.error(
          'Failed to verify the DNS record for the custom domain: ${e.message}',
        );
        return;
      }

      logger.error(
        'Failed to refresh custom domain record: $e',
      );

      throw ErrorExitException();
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
