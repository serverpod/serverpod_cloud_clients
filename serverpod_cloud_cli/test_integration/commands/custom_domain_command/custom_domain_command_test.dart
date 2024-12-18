import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domain_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../../../test_utils/command_logger_matchers.dart';
import '../../../test_utils/http_server_builder.dart';
import '../../../test_utils/test_command_logger.dart';

void main() {
  final logger = TestCommandLogger();
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    version: version,
  );

  final testCacheFolderPath = p.join(
    'test_integration',
    const Uuid().v4(),
  );

  tearDown(() {
    final directory = Directory(testCacheFolderPath);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }

    logger.clear();
  });

  const projectId = 'projectId';

  test('Given custom domains command when instantiated then requires login',
      () {
    expect(CloudCustomDomainCommand(logger: logger).requireLogin, isTrue);
  });

  group('Given unauthenticated', () {
    late Uri localServerAddress;
    late Completer requestCompleter;
    late HttpServer server;

    setUp(() async {
      requestCompleter = Completer();
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );

      final serverBuilder = HttpServerBuilder();
      serverBuilder.withOnRequest((final request) {
        requestCompleter.complete();
        request.response.statusCode = 401;
        request.response.close();
      });

      final (startedServer, serverAddress) = await serverBuilder.build();
      localServerAddress = serverAddress;
      server = startedServer;
    });

    tearDown(() async {
      await server.close(force: true);
    });

    group('when executing domain add', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domain',
          'add',
          'domain.com',
          '--target',
          'api',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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

    group('when executing domain list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domain',
          'list',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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

    group('when executing domain remove', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domain',
          'remove',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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

    group('when executing domain refresh-record', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domain',
          'refresh-record',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then throws exception', () async {
        await expectLater(requestCompleter.future, completes);
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
      await ResourceManager.storeServerpodCloudData(
        cloudData: ServerpodCloudData('my-token'),
        localStoragePath: testCacheFolderPath,
      );
    });

    late Uri localServerAddress;
    late HttpServer server;

    tearDown(() async {
      await server.close(force: true);
    });

    group('when executing domain add', () {
      late Future commandResult;
      setUp(() async {
        final serverBuilder = HttpServerBuilder();

        serverBuilder.withMethodResponse('customDomainName', 'add', (final _) {
          return (
            200,
            CustomDomainNameWithDefaultDomains(
                customDomainName: CustomDomainName(
                  name: 'domain.com',
                  status: DomainNameStatus.needsSetup,
                  target: DomainNameTarget.api,
                  environmentId: 1,
                ),
                defaultDomainsByTarget: {
                  DomainNameTarget.api: '$projectId.api.serverpod.space',
                  DomainNameTarget.insights:
                      '$projectId.insights.serverpod.space',
                  DomainNameTarget.web: '$projectId.web.serverpod.space',
                }),
          );
        });

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'add',
          'domain.com',
          '--target',
          'api',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then command completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.successCalls, isNotEmpty);
        expect(
          logger.successCalls.first,
          equalsSuccessCall(
            message: 'Custom domain added successfully!',
            newParagraph: true,
          ),
        );
      });

      test('then logs follow up instructions', () async {
        await commandResult;

        final followUpLogCalls = [
          ...logger.listCalls,
          ...logger.terminalCommandCalls
        ];

        expect(followUpLogCalls, isNotEmpty);
        expect(
          followUpLogCalls,
          containsAll(
            [
              equalsListCall(
                title: 'Follow these steps to complete setup:',
                items: [
                  'Add a CNAME record with the value "$projectId.api.serverpod.space" to the DNS configuration for this domain.',
                  'Wait for the update to propagate. This can take up to a few hours.',
                  'Run the following command to verify the DNS record (Serverpod Cloud will also try to verify the record periodically):',
                ],
                newParagraph: true,
              ),
              equalsTerminalCommandCall(
                command:
                    'scloud domains refresh-record domain.com --project-id $projectId',
                newParagraph: true,
              ),
              equalsListCall(
                items: [
                  'When verification succeeds, the custom domain will shortly become active.',
                  'Run the following command to check the status:',
                ],
                newParagraph: true,
              ),
              equalsTerminalCommandCall(
                command: 'scloud domains list --project-id $projectId',
                newParagraph: true,
              ),
            ],
          ),
        );
      });
    });

    group('when executing domain remove', () {
      late Future commandResult;
      setUp(() async {
        final serverBuilder = HttpServerBuilder();

        serverBuilder.withMethodResponse('customDomainName', 'remove',
            (final _) {
          return (200, '');
        });

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'remove',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
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
            message: 'Successfully removed custom domain: domain.com.',
          ),
        );
      });
    });

    group('and status is configured when executing domain refresh-record', () {
      late Uri localServerAddress;

      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();
        serverBuilder
            .withSuccessfulResponse(jsonEncode(DomainNameStatus.configured));

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'refresh-record',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
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
            message:
                'Successfully verified the DNS record for the custom domain. It is now active.',
          ),
        );
      });
    });

    group('and status is pending when executing domain refresh-record', () {
      late Uri localServerAddress;

      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();
        serverBuilder
            .withSuccessfulResponse(jsonEncode(DomainNameStatus.pending));

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'refresh-record',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
          logger.infoCalls.first,
          equalsInfoCall(
            message:
                'The DNS record for the custom domain is verified but certificate creation is still pending. '
                'Try again in a few minutes.',
          ),
        );
      });
    });

    group('and status is needsSetup when executing domain refresh-record', () {
      late Uri localServerAddress;

      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();
        serverBuilder
            .withSuccessfulResponse(jsonEncode(DomainNameStatus.needsSetup));

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'refresh-record',
          'domain.com',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs information message about status', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
          logger.infoCalls.first,
          equalsInfoCall(
            message: 'Failed to verify the DNS record for the custom domain. '
                'Ensure the CNAME is correctly set and try again later.',
          ),
        );
      });
    });

    group('and custom domains exist when executing domain list', () {
      late Uri localServerAddress;

      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();
        serverBuilder.withSuccessfulResponse(jsonEncode(CustomDomainNameList(
          customDomainNames: [
            CustomDomainName(
              environmentId: 1,
              name: 'api.domain.com',
              status: DomainNameStatus.configured,
              target: DomainNameTarget.api,
            ),
            CustomDomainName(
              environmentId: 1,
              name: 'web.domain.com',
              status: DomainNameStatus.pending,
              target: DomainNameTarget.web,
            ),
            CustomDomainName(
              environmentId: 1,
              name: 'insights.domain.com',
              status: DomainNameStatus.needsSetup,
              target: DomainNameTarget.insights,
            ),
          ],
          defaultDomainsByTarget: {
            DomainNameTarget.api: 'my-magical-project.api.serverpod.space',
            DomainNameTarget.insights:
                'my-magical-project.insights.serverpod.space',
            DomainNameTarget.web: 'my-magical-project.web.serverpod.space',
          },
        )));

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'list',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
            logger.infoCalls.take(2),
            containsAll([
              equalsInfoCall(
                  message:
                      'Default domain name                         | Target  \n'
                      '--------------------------------------------+---------\n'
                      'my-magical-project.api.serverpod.space      | api     \n'
                      'my-magical-project.insights.serverpod.space | insights\n'
                      'my-magical-project.web.serverpod.space      | web     \n'),
              equalsInfoCall(
                message:
                    'Custom domain name  | Target                                      | Status                      \n'
                    '--------------------+---------------------------------------------+-----------------------------\n'
                    'api.domain.com      | my-magical-project.api.serverpod.space      | Configured                  \n'
                    'web.domain.com      | my-magical-project.web.serverpod.space      | Certificate creation pending\n'
                    'insights.domain.com | my-magical-project.insights.serverpod.space | Needs setup                 \n',
              ),
            ]));
      });
    });

    group('and custom domains does not exist when executing domain list', () {
      late Uri localServerAddress;

      late Future commandResult;

      setUp(() async {
        final serverBuilder = HttpServerBuilder();
        serverBuilder.withSuccessfulResponse(jsonEncode(CustomDomainNameList(
          customDomainNames: [],
          defaultDomainsByTarget: {
            DomainNameTarget.api: 'my-magical-project.api.serverpod.space',
            DomainNameTarget.insights:
                'my-magical-project.insights.serverpod.space',
            DomainNameTarget.web: 'my-magical-project.web.serverpod.space',
          },
        )));

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domain',
          'list',
          '--project-id',
          projectId,
          '--api-url',
          localServerAddress.toString(),
          '--auth-dir',
          testCacheFolderPath,
        ]);
      });

      test('then completes successfully', () async {
        await expectLater(commandResult, completes);
      });

      test('then logs success message', () async {
        await commandResult;

        expect(logger.infoCalls, isNotEmpty);
        expect(
            logger.infoCalls.take(2),
            equals([
              equalsInfoCall(
                message:
                    'Default domain name                         | Target  \n'
                    '--------------------------------------------+---------\n'
                    'my-magical-project.api.serverpod.space      | api     \n'
                    'my-magical-project.insights.serverpod.space | insights\n'
                    'my-magical-project.web.serverpod.space      | web     \n',
              ),
              equalsInfoCall(
                message: 'Custom domain name | Target | Status\n'
                    '-------------------+--------+-------\n'
                    '<no rows data>\n',
              ),
            ]));
      });
    });
  });
}
