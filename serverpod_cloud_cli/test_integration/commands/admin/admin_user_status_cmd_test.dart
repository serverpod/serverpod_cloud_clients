import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart'
    show ErrorExitException;
import 'package:test/test.dart';
import 'package:yaml_codec/yaml_codec.dart';

import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/admin/users/admin_users_commands.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';

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

  const userEmail = 'ada@example.com';
  final ownerId = UuidValue.fromString('00000000-0000-4000-8000-000000000001');

  tearDown(() async {
    logger.clear();
    reset(client);
  });

  test(
    'Given admin user status command when instantiated then requires login',
    () {
      expect(AdminUserStatusCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    group('when executing admin user status by email', () {
      setUp(() async {
        when(
          () =>
              client.adminUsers.getUserStatus(email: userEmail, ownerId: null),
        ).thenAnswer((_) async => AdminUserStatusBuilder().build());

        await cli.run(['admin', 'user', 'status', userEmail]);
      });

      test('then stdout contains structured owner and project output', () {
        final output = logger.lineCalls.join('\n');
        expect(output, contains('User'));
        expect(output, contains('ada@example.com'));
        expect(output, contains('Owner id'));
        expect(output, contains('Project'));
        expect(output, contains('my-project'));
        expect(output, contains('Phase'));
        expect(output, contains('active'));
      });
    });

    group('when executing admin user status by owner id', () {
      setUp(() async {
        when(
          () => client.adminUsers.getUserStatus(email: null, ownerId: ownerId),
        ).thenAnswer(
          (_) async => AdminUserStatusBuilder()
              .withOwner(AdminUserOwnerStatusBuilder().withOwnerId(ownerId))
              .build(),
        );

        await cli.run(['admin', 'user', 'status', ownerId.toString()]);
      });

      test('then stdout contains the owner id', () {
        expect(logger.lineCalls.join('\n'), contains(ownerId.toString()));
      });
    });

    group('when executing admin user status with an invalid identifier', () {
      test('then the command fails with a client-side error', () async {
        await expectLater(
          cli.run(['admin', 'user', 'status', 'not-an-email-or-uuid']),
          throwsA(isA<ErrorExitException>()),
        );
      });
    });

    group('when the API returns NotFoundException', () {
      test('then the command fails with the server message', () async {
        when(
          () =>
              client.adminUsers.getUserStatus(email: userEmail, ownerId: null),
        ).thenThrow(NotFoundException(message: 'User not found'));

        await expectLater(
          cli.run(['admin', 'user', 'status', userEmail]),
          throwsA(isA<ErrorExitException>()),
        );
      });
    });

    group('when executing admin user status with --format json', () {
      setUp(() async {
        when(
          () =>
              client.adminUsers.getUserStatus(email: userEmail, ownerId: null),
        ).thenAnswer((_) async => AdminUserStatusBuilder().build());

        await cli.run([
          'admin',
          'user',
          'status',
          userEmail,
          '--format',
          'json',
        ]);
      });

      test('then raw json contains owner email', () {
        final decoded =
            jsonDecode(logger.rawCalls.single.content) as Map<String, dynamic>;
        final owner = decoded['owner'] as Map<String, dynamic>;
        expect(owner['userEmail'], userEmail);
        final projects = decoded['projects'] as List<dynamic>;
        final project = projects.single as Map<String, dynamic>;
        expect(project['status'], 'active');
        expect(project.containsKey('suspendedAt'), isFalse);
        expect(project.containsKey('suspensionReason'), isFalse);
      });
    });

    group('when executing admin user status with --format yaml', () {
      setUp(() async {
        when(
          () =>
              client.adminUsers.getUserStatus(email: userEmail, ownerId: null),
        ).thenAnswer(
          (_) async => AdminUserStatusBuilder().withNoProjects().build(),
        );

        await cli.run([
          'admin',
          'user',
          'status',
          userEmail,
          '--format',
          'yaml',
        ]);
      });

      test('then raw yaml contains empty projects list', () {
        final decoded =
            yamlDecode(logger.rawCalls.single.content) as Map<Object?, Object?>;
        expect(decoded['projects'], isEmpty);
      });
    });
  });
}
