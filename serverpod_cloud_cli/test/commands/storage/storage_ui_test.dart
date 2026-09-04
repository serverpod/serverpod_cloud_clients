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

  group('Given a StorageCreateTextUi', () {
    group('when rendered for a private storage', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageCreateTextUi(baseCommand: 'scloud'),
          data: BucketResourceBuilder()
              .withStorageId('user-uploads')
              .withVisibility(BucketVisibility.private)
              .build(),
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(
          stdout,
          contains('Successfully created storage "user-uploads".'),
        );
      });

      test('then stdout hints at checking the storage status', () {
        expect(
          stdout,
          contains('The storage is being set up. Check its status with:'),
        );
        expect(stdout, contains('scloud storage list'));
      });

      test('then stdout does not warn about public access', () {
        expect(stdout, isNot(contains('Anyone with the URL')));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered for a public storage', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageCreateTextUi(baseCommand: 'scloud'),
          data: BucketResourceBuilder()
              .withStorageId('assets')
              .withVisibility(BucketVisibility.public)
              .build(),
        );
        stdout = io.stdout;
      });

      test('then stdout warns that anyone with the URL can read the files', () {
        expect(stdout, contains('Anyone with the URL can read every file'));
        expect(stdout, contains('Access cannot be'));
      });

      test('then stdout still contains the success message', () {
        expect(stdout, contains('Successfully created storage "assets".'));
      });
    });
  });

  group('Given a StorageDeleteTextUi', () {
    group('when rendered after deleting a named storage', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageDeleteTextUi(),
          data: const {'storageId': 'user-uploads'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the success message', () {
        expect(
          stdout,
          contains('Successfully deleted storage "user-uploads".'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered without a storage id', () {
      test('then stdout contains a generic success message', () async {
        final io = await renderCommandUi(
          const StorageDeleteTextUi(),
          data: const <String, Object?>{},
        );

        expect(io.stdout, contains('Successfully deleted storage.'));
      });
    });
  });

  group('Given a StorageFileListTextUi', () {
    group('when rendered with no files', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageFileListTextUi(utc: false, tree: false),
          data: const <BucketFile>[],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout reports the folder is empty', () {
        expect(stdout, contains('This folder is empty.'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });

    group('when rendered as a table', () {
      late String stdout;

      setUp(() async {
        final io = await renderCommandUi(
          const StorageFileListTextUi(utc: false, tree: false),
          data: [
            BucketFileBuilder()
                .withName('avatars/u1.png')
                .withSizeBytes(34000)
                .build(),
          ],
        );
        stdout = io.stdout;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Name'));
        expect(stdout, contains('Size'));
        expect(stdout, contains('Last Modified'));
      });

      test('then stdout contains the file row with a formatted size', () {
        expect(stdout, contains('avatars/u1.png'));
        expect(stdout, contains('34.0 kB'));
      });
    });

    group('when rendered as a tree', () {
      test('then stdout contains the tree branches', () async {
        final io = await renderCommandUi(
          const StorageFileListTextUi(utc: false, tree: true),
          data: [
            BucketFileBuilder().withName('avatars/u1.png').build(),
            BucketFileBuilder().withName('docs/report.pdf').build(),
          ],
        );

        expect(io.stdout, contains('avatars'));
        expect(io.stdout, contains('u1.png'));
        expect(io.stdout, contains('docs'));
        expect(io.stdout, contains('report.pdf'));
      });
    });
  });

  group('Given a StorageFileTreeWidget', () {
    test('then stdout renders the given paths as a tree', () async {
      final io = await renderCommandUi(
        const StorageFileTreeWidget(['a.txt', 'sub/b.txt']),
      );

      expect(io.stdout, contains('a.txt'));
      expect(io.stdout, contains('sub'));
      expect(io.stdout, contains('b.txt'));
    });
  });
}
