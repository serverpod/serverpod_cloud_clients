import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

class CustomDomainAttachTextUi extends OutputWidget {
  final String baseCommand;

  const CustomDomainAttachTextUi({required this.baseCommand});

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final domainName = result['domainName'];
    final projectId = result['projectId'];
    final records = result['records'];

    final table = TablePrinter();
    table.addHeaders(['Record type', 'Domain name', 'Value']);
    if (records is List) {
      for (final record in records) {
        if (record is Map) {
          table.addRow([
            '${record['type']}',
            '${record['domain']}',
            '${record['value']}',
          ]);
        }
      }
    }

    return OutputWidgetList([
      const SuccessTextWidget(
        'Custom domain attached successfully!',
        newParagraph: true,
      ),
      const InfoTextWidget(
        'Complete the setup by adding the following records to your DNS '
        'configuration:',
        newParagraph: true,
      ),
      BoxTextWidget(table.toString(), newParagraph: true),
      const InfoTextWidget(
        'Check the status of the setup by running the command:',
        newParagraph: true,
      ),
      CommandHintTextWidget.command(
        '$baseCommand domain list --project $projectId',
        newParagraph: true,
      ),
      const ListTextWidget(
        [
          'DNS propagation can take up to 24 hours to complete.',
          'Serverpod Cloud will periodically verify the record(s).',
          'To manually force a verification, run the command:',
        ],
        title: 'Additional context',
        newParagraph: true,
      ),
      CommandHintTextWidget.command(
        '$baseCommand domain verify $domainName --project $projectId',
        newParagraph: true,
      ),
      const InfoTextWidget(' ', newParagraph: true),
    ]);
  }
}

class CustomDomainListTextUi extends OutputWidget {
  const CustomDomainListTextUi();

  static final _defaultDomainFormatter =
      TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Default domain name', key: 'name'),
          TableColumnFormatter.forKey('Target', key: 'target'),
        ],
        utc: false,
      );

  static final _customDomainFormatter =
      TextTableOutputFormatter<Map<String, Object?>>(
        columns: [
          TableColumnFormatter.forKey('Custom domain name', key: 'name'),
          TableColumnFormatter.forKey('Target', key: 'target'),
          TableColumnFormatter.forKey('Status', key: 'status'),
        ],
        utc: false,
      );

  @override
  OutputWidget build(final OutputContext context) {
    final domainNamesList = context.get<CustomDomainNameList>();

    final defaultRows = [
      for (final entry in domainNamesList.defaultDomainsByTarget.entries)
        {'name': entry.value, 'target': entry.key.toString()},
    ];
    final customRows = [
      for (final domainName in domainNamesList.customDomainNames)
        {
          'name': domainName.name,
          'target': domainNamesList.defaultDomainsByTarget[domainName.target],
          'status': _statusLabel(domainName.status),
        },
    ];

    return OutputWidgetList([
      TextTableWidget(_defaultDomainFormatter.format(defaultRows)),
      const LineTextWidget(),
      TextTableWidget(_customDomainFormatter.format(customRows)),
    ]);
  }
}

class CustomDomainDetachTextUi extends OutputWidget {
  const CustomDomainDetachTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final domainName = result['domainName'];
    return SuccessTextWidget(
      'Successfully detached custom domain: $domainName.',
    );
  }
}

class CustomDomainVerifyTextUi extends OutputWidget {
  const CustomDomainVerifyTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final status = context.get<DomainNameStatus>();
    return switch (status) {
      DomainNameStatus.configured => const SuccessTextWidget(
        'Successfully verified the DNS record for the custom domain. It is now active.',
      ),
      DomainNameStatus.needsSetup => const InfoTextWidget(
        'Failed to verify the DNS record for the custom domain.',
      ),
      DomainNameStatus.pending => const InfoTextWidget(
        'The DNS record for the custom domain is verified but certificate creation is still pending. '
        'Try again in a few minutes.',
      ),
    };
  }
}

String _statusLabel(final DomainNameStatus status) {
  return switch (status) {
    DomainNameStatus.configured => 'Configured',
    DomainNameStatus.pending => 'Certificate creation pending',
    DomainNameStatus.needsSetup => 'Needs setup',
  };
}
