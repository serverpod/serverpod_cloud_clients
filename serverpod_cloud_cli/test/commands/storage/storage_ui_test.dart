import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a StorageListTextUi', () {
    group('when rendered with no storages', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: const <BucketResource>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports that no storages are available', () {
        expect(stdout, contains('No storages available.'));
      });

      test('then stdout hints at creating one', () {
        expect(stdout, contains('scloud storage create <storage-id>'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered with a private and a public storage', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [
            BucketResourceBuilder()
                .withStorageId('private')
                .withVisibility(BucketVisibility.private)
                .build(),
            BucketResourceBuilder()
                .withStorageId('public')
                .withVisibility(BucketVisibility.public)
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Storage Id'));
        expect(stdout, contains('Access'));
        expect(stdout, contains('Region'));
        expect(stdout, contains('Status'));
      });

      test('then stdout contains both storage rows', () {
        expect(stdout, contains('private'));
        expect(stdout, contains('public'));
      });

      test('then stdout contains the access labels', () {
        expect(stdout, contains('Private'));
        expect(stdout, contains('Public'));
      });

      test('then stdout shows a provisioned storage as Ready', () {
        expect(stdout, contains('Ready'));
      });
    });

    group('when rendered with a storage that is being created', () {
      test('then stdout shows the status as Creating', () async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [
            BucketResourceBuilder().withStatus(BucketStatus.created).build(),
          ],
        );

        expect(io.stdout, contains('Creating'));
      });
    });

    group('when rendered with a storage that is being deleted', () {
      test('then stdout shows the status as Deleting', () async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [
            BucketResourceBuilder()
                .withStatus(BucketStatus.deletionRequested)
                .build(),
          ],
        );

        expect(io.stdout, contains('Deleting'));
      });
    });

    group('when rendered with a storage that has been deleted', () {
      test('then stdout shows the status as Deleted', () async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [
            BucketResourceBuilder().withStatus(BucketStatus.deleted).build(),
          ],
        );

        expect(io.stdout, contains('Deleted'));
      });
    });

    group('when rendered with a storage whose access was revoked', () {
      test('then stdout shows the revocation reason', () async {
        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [
            BucketResourceBuilder()
                .withAccessRevoked(
                  reason: BucketAccessRevocationReason.storageOverage,
                )
                .build(),
          ],
        );

        expect(io.stdout, contains('Access revoked (storage overage)'));
      });
    });

    group('when rendered with a storage whose access was revoked '
        'for an unknown reason', () {
      test('then stdout shows a plain revocation notice', () async {
        final storage = BucketResourceBuilder().withAccessRevoked().build();
        storage.accessRevokedReason = null;

        final io = await renderCommandUi(
          const StorageListTextUi(baseCommand: 'scloud'),
          data: [storage],
        );

        expect(io.stdout, contains('Access revoked'));
        expect(io.stdout, isNot(contains('Access revoked (')));
      });
    });
  });
}
