import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show AuthSuccess, AuthStrategy;
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/auth_command.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

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
      apiClientFactory: (final globalCfg) => client,
    ),
  );

  tearDown(() {
    logger.clear();
  });

  test(
    'Given auth create-token command when instantiated then requires login',
    () {
      expect(CreateTokenCommand(logger: logger).requireLogin, isTrue);
    },
  );

  group('Given authenticated', () {
    const testToken = 'created-api-token-123';

    AuthSuccess buildAuthSuccess({final String token = testToken}) {
      return AuthSuccess(
        token: token,
        authStrategy: AuthStrategy.session.name,
        authUserId: const Uuid().v4obj(),
        scopeNames: {},
      );
    }

    setUp(() async {
      when(
        () => client.authWithAuth.createCliToken(
          expiresAt: any(named: 'expiresAt'),
          expiresAfter: any(named: 'expiresAfter'),
        ),
      ).thenAnswer((final _) async => buildAuthSuccess());
    });

    tearDown(() {
      reset(client.authWithAuth);
    });

    group('when executing auth create-token', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'create-token']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully created an API token.',
            newParagraph: true,
            followUp: '''
Use the --token option or the SERVERPOD_CLOUD_TOKEN environment variable to
authenticate with this token in scloud commands.''',
          ),
        );
      });

      test('then logs token in info', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
          logger.infoCalls.first,
          equalsInfoCall(
            message: 'The token is only visible once:\n$testToken\n',
            newParagraph: true,
          ),
        );
      });
    });

    group('when executing auth create-token with --expire-at', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run([
          'auth',
          'create-token',
          '--expire-at',
          '2025-12-31T23:59:59',
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then createCliToken was called with expiresAt', () async {
        await commandResult;

        verify(
          () => client.authWithAuth.createCliToken(
            expiresAt: any(named: 'expiresAt'),
            expiresAfter: any(named: 'expiresAfter'),
          ),
        ).called(1);
      });
    });

    group('when executing auth create-token with --no-expires-after', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'create-token', '--no-idle-ttl']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Successfully created an API token.',
            newParagraph: true,
            followUp: '''
Use the --token option or the SERVERPOD_CLOUD_TOKEN environment variable to
authenticate with this token in scloud commands.''',
          ),
        );
      });
    });

    group('when executing auth create-token with --idle-ttl', () {
      late Future commandResult;
      setUp(() {
        commandResult = cli.run(['auth', 'create-token', '--idle-ttl', '7d']);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs token in info', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(logger.infoCalls.first.message, contains(testToken));
      });
    });
  });
}
