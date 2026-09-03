import 'package:ground_control_client/ground_control_client.dart'
    show
        BucketAccessRevocationReason,
        BucketResource,
        BucketStatus,
        BucketVisibility;
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class StorageListTextUi extends OutputWidget {
  final String baseCommand;

  const StorageListTextUi({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    final storages = context.get<List<BucketResource>>();
    if (storages.isEmpty) {
      return OutputWidgetList([
        const InfoTextWidget('No storages available.'),
        CommandHintTextWidget(
          'Create one with:',
          command: '$baseCommand storage create <storage-id>',
        ),
      ]);
    }

    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<BucketResource>(
        columns: [
          TableColumnFormatter.forElement(
            'Storage Id',
            getter: (storage) => storage.storageId,
          ),
          TableColumnFormatter.forElement(
            'Access',
            getter: (storage) => accessLabel(storage.visibility),
          ),
          TableColumnFormatter.forElement(
            'Region',
            getter: (storage) => storage.region.name,
          ),
          TableColumnFormatter.forElement(
            'Status',
            getter: (storage) => statusLabel(storage),
          ),
        ],
        utc: false,
      ),
    );
  }
}

/// The user-facing label for the read access of a storage.
String accessLabel(BucketVisibility visibility) {
  return switch (visibility) {
    BucketVisibility.private => 'Private',
    BucketVisibility.public => 'Public',
  };
}

/// The user-facing label for the state of a storage.
///
/// Revoked access takes precedence over the provisioning status.
String statusLabel(BucketResource storage) {
  if (storage.accessRevokedAt != null) {
    final reason = storage.accessRevokedReason;
    if (reason == null) {
      return 'Access revoked';
    }
    return 'Access revoked (${_revocationReasonLabel(reason)})';
  }

  return switch (storage.status) {
    BucketStatus.created => 'Creating',
    BucketStatus.provisioned => 'Ready',
    BucketStatus.deletionRequested => 'Deleting',
    BucketStatus.deleted => 'Deleted',
  };
}

String _revocationReasonLabel(BucketAccessRevocationReason reason) {
  return switch (reason) {
    BucketAccessRevocationReason.storageOverage => 'storage overage',
    BucketAccessRevocationReason.egressOverage => 'egress overage',
    BucketAccessRevocationReason.opsOverage => 'ops overage',
  };
}
