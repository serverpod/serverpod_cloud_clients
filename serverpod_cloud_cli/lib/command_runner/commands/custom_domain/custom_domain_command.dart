import 'package:config/config.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/categories.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain/custom_domain_ops.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain/custom_domain_ui.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:serverpod_cloud_cli/util/output/output.dart' show CommandOutput;

class CloudCustomDomainCommand extends CloudCliCommand {
  @override
  final name = 'domain';

  @override
  String get description =>
      '''
Bring your own domain to Serverpod Cloud. 

Get started by attaching a custom domain to your project with the command:

  \$ $baseCommand domain attach example.com <target> --project <project-id>

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
  Future<void> runWithOutput(
    final Configuration<AttachCustomDomainCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      AttachCustomDomainCommandConfig.projectId,
    );
    final domainName = commandConfig.value(
      AttachCustomDomainCommandConfig.domainName,
    );
    final target = commandConfig.value(AttachCustomDomainCommandConfig.target);

    await renderCommand(
      output,
      operation: () => CustomDomainOperations.attachDomain(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        domainName: domainName,
        target: target,
      ),
      textOutputUi: CustomDomainAttachTextUi(baseCommand: baseCommand),
    );
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
  Future<void> runWithOutput(
    final Configuration<ListCustomDomainCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      ListCustomDomainCommandConfig.projectId,
    );

    await renderCommand(
      output,
      operation: () => CustomDomainOperations.listDomains(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
      ),
      textOutputUi: const CustomDomainListTextUi(),
    );
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
  Future<void> runWithOutput(
    final Configuration<DetachCustomDomainCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      DetachCustomDomainCommandConfig.projectId,
    );
    final domainName = commandConfig.value(
      DetachCustomDomainCommandConfig.domainName,
    );

    await confirmToContinue(
      output,
      message:
          'Are you sure you want to delete the custom domain "$domainName"?',
      defaultValue: false,
    );

    await renderCommand(
      output,
      operation: () => CustomDomainOperations.detachDomain(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        domainName: domainName,
      ),
      textOutputUi: const CustomDomainDetachTextUi(),
    );
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
  Future<void> runWithOutput(
    final Configuration<RefreshCustomDomainRecordCommandConfig> commandConfig,
    final CommandOutput output,
  ) async {
    final projectId = commandConfig.value(
      RefreshCustomDomainRecordCommandConfig.projectId,
    );
    final domainName = commandConfig.value(
      RefreshCustomDomainRecordCommandConfig.domainName,
    );

    await renderCommand(
      output,
      operation: () => CustomDomainOperations.verifyDomain(
        runner.serviceProvider.cloudApiClient,
        projectId: projectId,
        domainName: domainName,
      ),
      textOutputUi: const CustomDomainVerifyTextUi(),
    );
  }
}
