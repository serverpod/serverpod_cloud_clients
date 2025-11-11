import 'package:basic_utils/basic_utils.dart';
import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:ground_control_client/ground_control_client.dart';

import 'categories.dart';

class CloudCustomDomainCommand extends CloudCliCommand {
  @override
  final name = 'domain';

  @override
  final description = r'''
Bring your own domain to Serverpod Cloud. 

Get started by attaching a custom domain to your project with the command:

  $ scloud domain attach example.com <target> --project <project-id>

The valid targets are:
- api: Serverpod endpoints
- insights: Serverpod insights
- web: Relic server (e.g. REST API or a Flutter web app)
''';

  @override
  String get category => CommandCategories.control;

  CloudCustomDomainCommand({required super.logger}) {
    addSubcommand(CloudAttachCustomDomainCommand(logger: logger));
    addSubcommand(CloudListCustomDomainCommand(logger: logger));
    addSubcommand(CloudDetachCustomDomainCommand(logger: logger));
    addSubcommand(CloudVerifyCustomDomainRecordCommand(logger: logger));
  }
}

abstract final class CustomDomainCommandConfig {
  static const projectId = ProjectIdOption();

  static const domainName = NameOption(
    helpText: 'The custom domain name. Can be passed as the first argument.',
    argPos: 0,
  );

  static const target = EnumOption<DomainNameTarget>(
    argName: 'target',
    argAbbrev: 't',
    argPos: 1,
    helpText:
        'The Serverpod server target of the custom domain, only one can be specified.',
    mandatory: true,
    enumParser: EnumParser(DomainNameTarget.values),
  );
}

enum AttachCustomDomainCommandConfig<V> implements OptionDefinition<V> {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName),
  target(CustomDomainCommandConfig.target);

  const AttachCustomDomainCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudAttachCustomDomainCommand
    extends CloudCliCommand<AttachCustomDomainCommandConfig> {
  @override
  String get description => '''
Attach a custom domain to your project.

You need to have a domain name and a DNS provider that supports 
TXT, CNAME and/or ANAME records.

You can attach domains for each Serverpod server target.

The valid targets are:
- api: Serverpod endpoints
- insights: Serverpod insights
- web: Relic server (e.g. REST API or a Flutter web app)
''';

  @override
  String get name => 'attach';

  CloudAttachCustomDomainCommand({required super.logger})
      : super(options: AttachCustomDomainCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<AttachCustomDomainCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(AttachCustomDomainCommandConfig.projectId);
    final domainName =
        commandConfig.value(AttachCustomDomainCommandConfig.domainName);
    final target = commandConfig.value(AttachCustomDomainCommandConfig.target);

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    late CustomDomainNameWithDefaultDomains customDomainNameWithDefaultDomains;

    try {
      customDomainNameWithDefaultDomains =
          await apiCloudClient.customDomainName.add(
        domainName: domainName,
        target: target,
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
          e, stackTrace, 'Could not add the custom domain');
    }

    logger.success('Custom domain attached successfully!', newParagraph: true);

    final targetDefaultDomain =
        customDomainNameWithDefaultDomains.defaultDomainsByTarget[target];

    if (targetDefaultDomain == null) {
      throw FailureException(
        error: 'Could not find the target domain for "$target".',
      );
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

enum ListCustomDomainCommandConfig<V> implements OptionDefinition<V> {
  projectId(CustomDomainCommandConfig.projectId);

  const ListCustomDomainCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
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
    try {
      domainNamesList = await apiCloudClient.customDomainName.list(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
          e, stackTrace, 'Failed to list custom domains');
    }

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

enum DetachCustomDomainCommandConfig<V> implements OptionDefinition<V> {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName);

  const DetachCustomDomainCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CloudDetachCustomDomainCommand
    extends CloudCliCommand<DetachCustomDomainCommandConfig> {
  @override
  String get description => 'Detach a custom domain.';

  @override
  String get name => 'detach';

  CloudDetachCustomDomainCommand({required super.logger})
      : super(options: DetachCustomDomainCommandConfig.values);

  @override
  Future<void> runWithConfig(
    final Configuration<DetachCustomDomainCommandConfig> commandConfig,
  ) async {
    final projectId =
        commandConfig.value(DetachCustomDomainCommandConfig.projectId);
    final domainName =
        commandConfig.value(DetachCustomDomainCommandConfig.domainName);

    final shouldDelete = await logger.confirm(
      'Are you sure you want to delete the custom domain "$domainName"?',
      defaultValue: false,
    );

    if (!shouldDelete) {
      throw UserAbortException();
    }

    final apiCloudClient = runner.serviceProvider.cloudApiClient;

    try {
      await apiCloudClient.customDomainName.remove(
        cloudCapsuleId: projectId,
        domainName: domainName,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
          e, stackTrace, 'Failed to remove custom domain');
    }

    logger.success('Successfully detached custom domain: $domainName.');
  }
}

enum RefreshCustomDomainRecordCommandConfig<V> implements OptionDefinition<V> {
  projectId(CustomDomainCommandConfig.projectId),
  domainName(CustomDomainCommandConfig.domainName);

  const RefreshCustomDomainRecordCommandConfig(this.option);

  @override
  final ConfigOptionBase<V> option;
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

    try {
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
    } on DNSVerificationFailedException catch (e) {
      logger.error(
        'Failed to verify the DNS record for the custom domain: ${e.message}',
      );
      return;
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to refresh custom domain record',
      );
    }
  }
}
