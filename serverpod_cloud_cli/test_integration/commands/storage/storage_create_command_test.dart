import 'dart:async';
import 'dart:convert';

import 'package:config/config.dart' show UsageException;
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/storage/storage_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (globalCfg) => client,
    ),
    adminUserMode: true,
  );

  setUpAll(() {
    registerFallbackValue(BucketVisibility.private);
  });

  tearDown(() async {
    logger.clear();
    reset(client.bucket);
  });

  const projectId = 'projectId';

  void stubCreateBucket(final BucketResource storage) {
    when(
      () => client.bucket.createBucket(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        visibility: any(named: 'visibility'),
      ),
    ).thenAnswer((_) async => storage);
  }

  void stubCreateBucketThrows(final Object exception) {
    when(
      () => client.bucket.createBucket(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        storageId: any(named: 'storageId'),
        visibility: any(named: 'visibility'),
      ),
    ).thenThrow(exception);
  }

  test(
    'Given storage create command when instantiated then requires login',
    () {
      expect(CloudStorageCreateCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given unauthenticated', () {
    setUp(() {
      stubCreateBucketThrows(ServerpodClientUnauthorized());
    });

    group('when executing storage create', () {
      test('then throws exception', () async {
        await expectLater(
          cli.run(['storage', 'create', 'user-uploads', '-p', projectId]),
          throwsA(isA<ErrorExitException>()),
        );
      });
    });
  });

  group('Given authenticated', () {
    group('when creating a storage without an access option', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucket(
          BucketResourceBuilder().withStorageId('user-uploads').build(),
        );

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then creates a private storage', () async {
        await commandResult;

        verify(
          () => client.bucket.createBucket(
            cloudCapsuleId: projectId,
            storageId: 'user-uploads',
            visibility: BucketVisibility.private,
          ),
        ).called(1);
      });

      test('then logs the success message', () async {
        await commandResult;

        expect(
          logger.successCalls.single,
          equalsSuccessCall(
            message: 'Successfully created storage "user-uploads".',
          ),
        );
      });

      test('then hints at how to check the storage status', () async {
        await commandResult;

        expect(
          logger.terminalCommandCalls.single,
          equalsTerminalCommandCall(
            command: 'scloud storage list',
            message: 'The storage is being set up. Check its status with:',
          ),
        );
      });

      test('then does not warn about public access', () async {
        await commandResult;

        expect(logger.infoCalls, isEmpty);
      });
    });

    group('when creating a storage with --access public', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucket(
          BucketResourceBuilder()
              .withStorageId('assets')
              .withVisibility(BucketVisibility.public)
              .build(),
        );

        commandResult = cli.run([
          'storage',
          'create',
          'assets',
          '--access',
          'public',
          '-p',
          projectId,
        ]);
      });

      test('then creates a public storage', () async {
        await commandResult;

        verify(
          () => client.bucket.createBucket(
            cloudCapsuleId: projectId,
            storageId: 'assets',
            visibility: BucketVisibility.public,
          ),
        ).called(1);
      });

      test('then warns that anyone with the URL can read the files', () async {
        await commandResult;

        expect(
          logger.infoCalls.single,
          equalsInfoCall(
            message:
                'Anyone with the URL can read every file in this storage. '
                'Access cannot be changed later.',
          ),
        );
      });
    });

    group('when creating a storage with --format json', () {
      test('then emits the created storage as JSON', () async {
        stubCreateBucket(
          BucketResourceBuilder().withStorageId('user-uploads').build(),
        );

        await cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
          '--format',
          'json',
        ]);

        expect(logger.lineCalls, isEmpty);
        final payload = jsonDecode(logger.rawCalls.single.content) as Map;
        expect(payload['storageId'], 'user-uploads');
        expect(payload['visibility'], 'private');
      });
    });

    group('when creating a storage with a padded id', () {
      test('then throws a UsageException and calls no endpoint', () async {
        await expectLater(
          cli.run(['storage', 'create', ' user-uploads ', '-p', projectId]),
          throwsA(isA<UsageException>()),
        );

        verifyNever(
          () => client.bucket.createBucket(
            cloudCapsuleId: any(named: 'cloudCapsuleId'),
            storageId: any(named: 'storageId'),
            visibility: any(named: 'visibility'),
          ),
        );
      });
    });

    group('when creating a storage with an invalid id', () {
      test('then throws a UsageException with the validation reason', () async {
        await expectLater(
          cli.run(['storage', 'create', 'Bad_Id', '-p', projectId]),
          throwsA(
            isA<UsageException>().having(
              (final e) => e.message,
              'message',
              contains(
                'Use lowercase letters, digits and dashes, '
                'starting and ending with a letter or digit.',
              ),
            ),
          ),
        );
      });
    });

    group('when the storage id is already taken', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucketThrows(DuplicateEntryException(message: 'taken'));

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the duplicate error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message:
                'A storage with id "user-uploads" already exists '
                'in project "projectId".',
            hint:
                'Pick another id, or run "scloud storage list" '
                'to see the existing storages.',
          ),
        );
      });
    });

    group('when the plan has no storage slots left', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucketThrows(
          ProcurementDeniedException(
            message: 'no allowance',
            reason: ProcurementDeniedReason.productNotAvailable,
          ),
        );

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the plan allowance error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'This project has no storage slots left on its plan.',
            hint:
                'Remove an existing storage, or upgrade the project plan in '
                'the console.',
          ),
        );
      });
    });

    group('when the account has no payment method', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucketThrows(
          ProcurementDeniedException(
            message: 'The account has no valid payment method',
            reason: ProcurementDeniedReason.paymentMethodRequired,
          ),
        );

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then logs the common payment method error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls.single.message, 'You need a payment method!');
      });
    });

    group('when the project storage identity is not ready', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucketThrows(
          BucketStorageIdentityUnavailableException(message: 'not ready'),
        );

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ErrorExitException>()));
      });

      test('then logs the not ready error with a retry hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'Storage for this project is still being set up.',
            hint: 'Try again in a moment.',
          ),
        );
      });
    });

    group('when the project does not exist', () {
      late Future commandResult;

      setUp(() async {
        stubCreateBucketThrows(NotFoundException(message: 'no such project'));

        commandResult = cli.run([
          'storage',
          'create',
          'user-uploads',
          '-p',
          projectId,
        ]);
      });

      test('then logs the project not found error with a hint', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(
          logger.errorCalls.single,
          equalsErrorCall(
            message: 'Project "projectId" was not found.',
            hint: 'Run "scloud project list" to see your projects.',
          ),
        );
      });
    });
  });
}
