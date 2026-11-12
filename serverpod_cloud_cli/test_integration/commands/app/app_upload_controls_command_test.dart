import 'dart:convert';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cloud_cli_service_provider.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:test/test.dart';

import '../../../test_utils/test_command_logger.dart';

const _projectId = 'my-project-id';
final _uploadId = const Uuid().v4obj();

void main() {
  final logger = TestCommandLogger();
  final client = ClientMock(
    authKeyProvider: InMemoryKeyManager.authenticated(),
  );
  final cli = CloudCliCommandRunner.create(
    logger: logger,
    serviceProvider: CloudCliServiceProvider(apiClientFactory: (_) => client),
  );

  setUpAll(() {
    registerFallbackValue(const Uuid().v4obj());
  });
  tearDown(() {
    logger.clear();
    reset(client.appBuilds);
  });

  test(
    'Given an upload with active and finished builds '
    'when cancelling then only active builds receive cancellation requests',
    () async {
      final active = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.running)
          .build();
      final ended = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [active, ended]);
      when(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: active.id,
        ),
      ).thenAnswer((_) async {});

      await cli.run([
        'app',
        'cancel',
        _uploadId.uuid,
        '--project',
        _projectId,
        '--format',
        'json',
      ]);

      verify(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: active.id,
        ),
      ).called(1);
      verifyNever(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: ended.id,
        ),
      );
      expect(jsonDecode(logger.rawCalls.single.content), [
        active.id.toString(),
      ]);
    },
  );

  test('Given an upload whose builds have ended '
      'when cancelling then no cancellation is requested', () async {
    when(
      () => client.appBuilds.getUploadBuilds(
        cloudCapsuleId: _projectId,
        uploadId: _uploadId,
      ),
    ).thenAnswer((_) async => [AppBuildSummaryBuilder().build()]);

    await cli.run(['app', 'cancel', _uploadId.uuid, '--project', _projectId]);

    verifyNever(
      () => client.appBuilds.cancelBuild(
        cloudCapsuleId: any(named: 'cloudCapsuleId'),
        buildId: any(named: 'buildId'),
      ),
    );
    expect(
      logger.infoCalls.map((call) => call.message),
      contains('There are no active builds to cancel.'),
    );
  });

  test(
    'Given cancellation of one build fails '
    'when cancelling an upload then the other build is still cancelled',
    () async {
      final ios = AppBuildSummaryBuilder()
          .withStatus(AppBuildStatus.running)
          .build();
      final android = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .withStatus(AppBuildStatus.queued)
          .build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [ios, android]);
      when(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: ios.id,
        ),
      ).thenThrow(Exception('Unavailable'));
      when(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: android.id,
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        cli.run(['app', 'cancel', _uploadId.uuid, '--project', _projectId]),
        throwsA(isA<ErrorExitException>()),
      );

      verify(
        () => client.appBuilds.cancelBuild(
          cloudCapsuleId: _projectId,
          buildId: android.id,
        ),
      ).called(1);
      expect(
        logger.errorCalls.map((call) => call.message),
        contains(contains('Could not cancel app build ${ios.id}')),
      );
    },
  );

  test(
    'Given an Android build with an AAB '
    'when fetching artifacts then a fresh download link is emitted',
    () async {
      final build = AppBuildSummaryBuilder()
          .withPlatform(AppPlatform.android)
          .build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.listArtifacts(
          cloudCapsuleId: _projectId,
          buildId: build.id,
        ),
      ).thenAnswer((_) async => [AppBuildArtifactBuilder().build()]);
      when(
        () => client.appBuilds.getArtifactDownloadUrl(
          cloudCapsuleId: _projectId,
          buildId: build.id,
          artifactId: 'artifact-id',
        ),
      ).thenAnswer((_) async => 'https://example.com/app-release.aab');

      await cli.run([
        'app',
        'artifacts',
        _uploadId.uuid,
        '--project',
        _projectId,
        '--format',
        'json',
      ]);

      final payload = jsonDecode(logger.rawCalls.single.content) as List;
      expect((payload.single as Map)['platform'], 'android');
      expect(
        (payload.single as Map)['downloadUrl'],
        'https://example.com/app-release.aab',
      );
      expect(
        ((payload.single as Map)['artifact'] as Map)['name'],
        'app-release.aab',
      );
      verify(
        () => client.appBuilds.getArtifactDownloadUrl(
          cloudCapsuleId: _projectId,
          buildId: build.id,
          artifactId: 'artifact-id',
        ),
      ).called(1);
    },
  );

  test(
    'Given a build without artifacts '
    'when fetching artifacts then their unavailability is explained',
    () async {
      final build = AppBuildSummaryBuilder().build();
      when(
        () => client.appBuilds.getUploadBuilds(
          cloudCapsuleId: _projectId,
          uploadId: _uploadId,
        ),
      ).thenAnswer((_) async => [build]);
      when(
        () => client.appBuilds.listArtifacts(
          cloudCapsuleId: _projectId,
          buildId: build.id,
        ),
      ).thenAnswer((_) async => []);

      await cli.run([
        'app',
        'artifacts',
        _uploadId.uuid,
        '--project',
        _projectId,
      ]);

      expect(
        logger.infoCalls.map((call) => call.message),
        contains('No artifacts are available yet, or they have expired.'),
      );
    },
  );
}
