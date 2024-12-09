import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/custom_domains_command.dart';
import 'package:serverpod_cloud_cli/persistent_storage/models/serverpod_cloud_data.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';
import 'package:serverpod_ground_control_client/serverpod_ground_control_client.dart';
import 'package:test/test.dart';

import '../../test_utils/http_server_builder.dart';
import '../../test_utils/test_logger.dart';

void main() {
  final logger = TestLogger();
  final commandLogger = CommandLogger(logger);
  final version = Version.parse('0.0.1');
  final cli = CloudCliCommandRunner.create(
    logger: commandLogger,
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
    expect(
        CloudCustomDomainCommand(logger: commandLogger).requireLogin, isTrue);
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
          'domains',
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

        expect(logger.errors, isNotEmpty);
        expect(
            logger.errors.first,
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.');
      });
    });

    group('when executing domain list', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domains',
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

        expect(logger.errors, isNotEmpty);
        expect(
            logger.errors.first,
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.');
      });
    });

    group('when executing domain remove', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domains',
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

        expect(logger.errors, isNotEmpty);
        expect(
            logger.errors.first,
            'The credentials for this session seem to no longer be valid.\n'
            'Please run `scloud logout` followed by `scloud login` and try this command again.');
      });
    });

    group('when executing domain refresh-record', () {
      late Future commandResult;
      setUp(() async {
        commandResult = cli.run([
          'domains',
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

        expect(logger.errors, isNotEmpty);
        expect(
          logger.errors.first,
          'The credentials for this session seem to no longer be valid.\n'
          'Please run `scloud logout` followed by `scloud login` and try this command again.',
        );
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
          return (200, null);
        });

        final (startedServer, serverAddress) = await serverBuilder.build();
        localServerAddress = serverAddress;
        server = startedServer;

        commandResult = cli.run([
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(logger.messages.first, 'Custom domain added successfully! 🚀\n');
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully removed custom domain: domain.com.',
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Successfully verified the DNS record for the custom domain. It is now active.',
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'The DNS record for the custom domain is verified but certificate creation is still pending. '
          'Try again in a few minutes.',
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
          logger.messages.first,
          'Failed to verify the DNS record for the custom domain. Ensure the CNAME is correctly set and try again later.',
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
            logger.messages,
            containsAll([
              'Default domain name                         | Target  \n'
                  '--------------------------------------------+---------\n'
                  'my-magical-project.api.serverpod.space      | api     \n'
                  'my-magical-project.insights.serverpod.space | insights\n'
                  'my-magical-project.web.serverpod.space      | web     \n',
              'Custom domain name  | Target                                      | Status                      \n'
                  '--------------------+---------------------------------------------+-----------------------------\n'
                  'api.domain.com      | my-magical-project.api.serverpod.space      | Configured                  \n'
                  'web.domain.com      | my-magical-project.web.serverpod.space      | Certificate creation pending\n'
                  'insights.domain.com | my-magical-project.insights.serverpod.space | Needs setup                 \n',
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
          'domains',
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

        expect(logger.messages, isNotEmpty);
        expect(
            logger.messages.take(2),
            equals([
              'Default domain name                         | Target  \n'
                  '--------------------------------------------+---------\n'
                  'my-magical-project.api.serverpod.space      | api     \n'
                  'my-magical-project.insights.serverpod.space | insights\n'
                  'my-magical-project.web.serverpod.space      | web     \n',
              'Custom domain name | Target | Status\n'
                  '-------------------+--------+-------\n'
                  '<no rows data>\n'
            ]));
      });
    });
  });
}
