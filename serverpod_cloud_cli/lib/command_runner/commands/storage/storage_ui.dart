import 'package:ground_control_client/ground_control_client.dart'
    show
        BucketAccessRevocationReason,
        BucketResource,
        BucketStatus,
        BucketVisibility;
import 'package:ground_control_client/ground_control_client.dart'
    show BucketFile;
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';
import 'package:serverpod_cloud_cli/util/byte_size.dart';
import 'package:serverpod_cloud_cli/util/printers/file_tree_printer.dart';

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

class StorageCreateTextUi extends OutputWidget {
  final String baseCommand;

  const StorageCreateTextUi({required this.baseCommand});

  @override
  OutputWidget build(OutputContext context) {
    final storage = context.get<BucketResource>();

    return OutputWidgetList([
      if (storage.visibility == BucketVisibility.public)
        const InfoTextWidget(
          'Anyone with the URL can read every file in this storage. '
          'Access cannot be changed later.',
        ),
      SuccessTextWidget('Successfully created storage "${storage.storageId}".'),
      CommandHintTextWidget(
        'The storage is being set up. Check its status with:',
        command: '$baseCommand storage list',
      ),
    ]);
  }
}

class StorageDeleteTextUi extends OutputWidget {
  const StorageDeleteTextUi();

  @override
  OutputWidget build(OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final storageId = result['storageId'];

    return storageId is! String
        ? const SuccessTextWidget('Successfully deleted storage.')
        : SuccessTextWidget('Successfully deleted storage "$storageId".');
  }
}

class StorageFileListTextUi extends OutputWidget {
  final bool utc;
  final bool tree;

  const StorageFileListTextUi({required this.utc, required this.tree});

  @override
  OutputWidget build(OutputContext context) {
    final files = context.get<List<BucketFile>>();
    if (files.isEmpty) {
      return const InfoTextWidget('This folder is empty.');
    }

    if (tree) {
      return StorageFileTreeWidget([for (final file in files) file.name]);
    }

    return FormattedTableWidget(
      formatter: TextTableOutputFormatter<BucketFile>(
        columns: [
          TableColumnFormatter.forElement('Name', getter: (file) => file.name),
          TableColumnFormatter.forElement(
            'Size',
            getter: (file) => formatByteSize(file.sizeBytes),
          ),
          TableColumnFormatter.forElement(
            'Last Modified',
            getter: (file) => file.updated,
          ),
        ],
        utc: utc,
      ),
    );
  }
}

/// Renders file paths as a directory tree.
class StorageFileTreeWidget extends OutputWidget {
  final List<String> names;

  const StorageFileTreeWidget(this.names);

  @override
  void render({required CommandLogger logger}) {
    FileTreePrinter.writeFileTree(
      filePaths: names.toSet(),
      ignoredPaths: const {},
      write: logger.raw,
    );
  }
}

class StorageFileUploadTextUi extends OutputWidget {
  const StorageFileUploadTextUi();

  @override
  OutputWidget build(OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final storageId = result['storageId'];
    final files = result['files'];
    final fileCount = files is List ? files.length : 0;

    if (fileCount == 1 && files is List) {
      final path = (files.single as Map<String, Object?>)['path'];
      return SuccessTextWidget(
        'Successfully uploaded "$path" to storage "$storageId".',
      );
    }

    final sizeBytes = result['sizeBytes'];
    final size = sizeBytes is int ? ' (${formatByteSize(sizeBytes)})' : '';

    return SuccessTextWidget(
      'Successfully uploaded $fileCount files$size to storage "$storageId".',
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
