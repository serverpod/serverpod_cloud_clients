import 'dart:async';

import 'package:cli_tools/cli_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/db_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_mock.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final keyManager = InMemoryKeyManager();
  final client = ClientMock(authenticationKeyManager: keyManager);
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() async {
    await keyManager.remove();

    logger.clear();
  });
  const projectId = 'projectId';

  test('Given db connection command when instantiated then requires login', () {
    expect(
        CloudDbConnectionDetailsCommand(logger: logger).requireLogin, isTrue);
  });

  test(
      'Given db create-superuser command when instantiated then requires login',
      () {
    expect(CloudDbCreateSuperuserCommand(logger: logger).requireLogin, isTrue);
  });

  test('Given db reset-password command when instantiated then requires login',
      () {
    expect(CloudDbResetPasswordCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing db connection', () {
      setUpAll(() {
        when(() => client.database.getConnectionDetails(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'connection',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });

    group('when executing db create-superuser', () {
      setUpAll(() {
        when(() => client.database.createSuperUser(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              username: 'wernher',
            )).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'create-superuser',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });

    group('when executing db reset-password', () {
      setUpAll(() {
        when(() => client.database.resetDatabasePassword(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              username: 'wernher',
            )).thenThrow(ServerpodClientUnauthorized());
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'reset-password',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(commandResult, throwsA(isA<ExitException>()));
      });

      test('then logs error', () async {
        try {
          await commandResult;
        } catch (_) {}

        expect(logger.errorCalls, isNotEmpty);
        expect(
            logger.errorCalls.first,
            equalsErrorCall(
              message:
                  'The credentials for this session seem to no longer be valid.',
            ));
      });
    });
  });

  group('Given authenticated', () {
    setUp(() async {
      await keyManager.put('mock-token');
    });

    group('when executing db connection', () {
      final connection = DatabaseConnection(
        host: 'localhost',
        port: 5432,
        name: 'default',
        user: 'wernher',
        requiresSsl: false,
      );

      setUpAll(() {
        when(() => client.database.getConnectionDetails(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
            )).thenAnswer((final _) async => Future.value(connection));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'connection',
          '--project',
          projectId,
        ]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the connection details', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
            logger.successCalls.single.message.split('\n'),
            containsAllInOrder([
              contains('Connection details:'),
              contains('Host: ${connection.host}'),
              contains('Port: ${connection.port}'),
              contains('Database: ${connection.name}'),
            ]));
        expect(
            logger.successCalls.single.followUp!.split('\n'),
            containsAllInOrder([
              contains(
                  'This psql command can be used to connect to the database (it will prompt for the password):'),
              contains(
                  'psql "postgresql://${connection.host}/${connection.name}?sslmode=${connection.requiresSsl ? 'require' : 'disable'}" --user <username>')
            ]));
      });
    });

    group('when executing db create-superuser', () {
      const password = 'von Braun';

      setUpAll(() {
        when(() => client.database.createSuperUser(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              username: 'wernher',
            )).thenAnswer((final _) async => Future.value(password));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'create-superuser',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the password', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.single.message,
          '''
DB superuser created. The password is only shown this once:
$password''',
        );
      });
    });

    group('when executing db reset-password', () {
      const password = 'von Braun';

      setUpAll(() {
        when(() => client.database.resetDatabasePassword(
              cloudCapsuleId: any(named: 'cloudCapsuleId'),
              username: 'wernher',
            )).thenAnswer((final _) async => Future.value(password));
      });

      tearDownAll(() {
        reset(client.database);
      });

      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'db',
          'reset-password',
          'wernher',
          '--project',
          projectId,
        ]);
      });

      test('then succeeds', () async {
        await expectLater(commandResult, completes);
      });

      test('then outputs the password', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.single.message,
          '''
DB password is reset. The new password is only shown this once:
$password''',
        );
      });
    });
  });
}
