import 'package:ground_control_client/ground_control_client.dart';
import 'package:ground_control_client/ground_control_client_test_tools.dart';
import 'package:ground_control_client_mock/ground_control_client_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show AuthSuccess, AuthStrategy;

void stubCloudClient(
  final ClientMock client, {
  required final String projectId,
}) {
  registerFallbackValue(DateTime.utc(2024));
  registerFallbackValue(Duration.zero);
  registerFallbackValue(Uuid().v4obj());
  registerFallbackValue(DomainNameTarget.api);
  registerFallbackValue(UserAccountStatus.registered);
  registerFallbackValue(<String, String>{});
  registerFallbackValue(<String>[]);

  when(() => client.close()).thenAnswer((final _) async {});
  when(
    () => client.billing.ownerIsInGoodStanding(),
  ).thenAnswer((_) async => true);

  _stubUsers(client);
  _stubAuth(client);
  _stubProjects(client, projectId: projectId);
  _stubVariablesAndSecrets(client);
  _stubDomains(client, projectId: projectId);
  _stubLogs(client, projectId: projectId);
  _stubStatusAndDeployments(client, projectId: projectId);
  _stubDatabase(client);
  _stubAdmin(client, projectId: projectId);
}

void _stubUsers(final ClientMock client) {
  when(() => client.users.readUser()).thenAnswer(
    (_) async => UserBuilder()
        .withEmail('user@example.com')
        .withName('Ada Lovelace')
        .build(),
  );
  when(
    () => client.users.listUsersInProject(
      cloudProjectId: any(named: 'cloudProjectId'),
    ),
  ).thenAnswer(
    (_) async => [
      UserBuilder().withEmail('owner@example.com').withName('Owner').build(),
      UserBuilder().withEmail('dev@example.com').withName('Developer').build(),
    ],
  );
}

void _stubAuth(final ClientMock client) {
  final createdAt = DateTime.utc(2026, 2, 11, 16, 50, 06);
  when(() => client.authWithAuth.listAuthSessions()).thenAnswer(
    (_) async => [
      AuthTokenInfoBuilder()
          .withTokenId('tid-1')
          .withCreatedAt(createdAt)
          .withLastUsedAt(DateTime.utc(2026, 2, 12, 16, 50, 06))
          .withExpireAfterUnusedFor(const Duration(days: 30))
          .build(),
      AuthTokenInfoBuilder()
          .withTokenId('tid-2')
          .withMethod('CLI token')
          .withCreatedAt(createdAt)
          .withExpiresAt(DateTime.utc(2026, 3, 11, 16, 50, 06))
          .build(),
    ],
  );
  when(
    () => client.authWithAuth.createCliToken(
      expiresAt: any(named: 'expiresAt'),
      expiresAfter: any(named: 'expiresAfter'),
    ),
  ).thenAnswer(
    (_) async => AuthSuccess(
      token: 'created-api-token-123',
      authStrategy: AuthStrategy.session.name,
      authUserId: Uuid().v4obj(),
      scopeNames: {},
    ),
  );
  when(() => client.authWithAuth.logoutDevice()).thenAnswer((_) async => true);
  when(
    () => client.authWithAuth.logoutDevice(
      authTokenId: any(named: 'authTokenId'),
    ),
  ).thenAnswer((_) async => true);
  when(() => client.authWithAuth.logoutAll()).thenAnswer((_) async {});
}

void _stubProjects(final ClientMock client, {required final String projectId}) {
  final projects = [
    ProjectInfoBuilder()
        .withProject(
          ProjectBuilder()
              .withCloudProjectId(projectId)
              .withCreatedAt(DateTime.utc(2024, 12, 31, 10, 20, 30)),
        )
        .withLatestDeployAttemptTime(DateTime.utc(2024, 12, 31, 10, 20, 30))
        .build(),
    ProjectInfoBuilder()
        .withProject(
          ProjectBuilder()
              .withCloudProjectId('other-project')
              .withCreatedAt(DateTime.utc(2024, 12, 31, 12, 20, 30))
              .withArchivedAt(DateTime.utc(2025, 1, 1, 14, 20, 30)),
        )
        .withLatestDeployAttemptTime(DateTime.utc(2024, 12, 31, 12, 20, 30))
        .build(),
  ];

  when(
    () => client.projects.listProjectsInfo(
      includeLatestDeployAttemptTime: any(
        named: 'includeLatestDeployAttemptTime',
      ),
    ),
  ).thenAnswer((_) async => projects);
  when(
    () => client.projects.deleteProject(
      cloudProjectId: any(named: 'cloudProjectId'),
    ),
  ).thenAnswer(
    (_) async => ProjectBuilder().withCloudProjectId(projectId).build(),
  );
  when(
    () => client.projects.inviteUser(
      cloudProjectId: any(named: 'cloudProjectId'),
      email: any(named: 'email'),
      assignRoleNames: any(named: 'assignRoleNames'),
    ),
  ).thenAnswer((_) async {});
}

void _stubVariablesAndSecrets(final ClientMock client) {
  when(() => client.environmentVariables.list(any())).thenAnswer(
    (_) async => [
      EnvironmentVariable(name: 'LOG_LEVEL', value: 'info', capsuleId: 0),
      EnvironmentVariable(name: 'REGION', value: 'eu-north-1', capsuleId: 0),
    ],
  );
  when(
    () => client.environmentVariables.create(any(), any(), any()),
  ).thenAnswer(
    (final invocation) async => EnvironmentVariable(
      name: invocation.positionalArguments[0] as String,
      value: invocation.positionalArguments[1] as String,
      capsuleId: 0,
    ),
  );
  when(
    () => client.environmentVariables.update(
      name: any(named: 'name'),
      value: any(named: 'value'),
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (final invocation) async => EnvironmentVariable(
      name: invocation.namedArguments[#name] as String,
      value: invocation.namedArguments[#value] as String,
      capsuleId: 0,
    ),
  );

  when(() => client.secrets.list(any())).thenAnswer(
    (_) async => [
      'SERVERPOD_PASSWORD_database',
      'SERVERPOD_PASSWORD_customPassword',
      'API_TOKEN',
    ],
  );
  when(() => client.secrets.listManaged(any())).thenAnswer(
    (_) async => [
      'SERVERPOD_PASSWORD_database',
      'SERVERPOD_PASSWORD_emailSecretHashPepper',
    ],
  );
  when(
    () => client.secrets.listBuild(any()),
  ).thenAnswer((_) async => ['SECRET_1', 'SECRET_2']);
  when(
    () => client.secrets.upsert(
      secrets: any(named: 'secrets'),
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => client.secrets.create(
      secrets: any(named: 'secrets'),
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer((_) async {});
}

void _stubDomains(final ClientMock client, {required final String projectId}) {
  when(
    () => client.customDomainName.list(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => CustomDomainNameList(
      customDomainNames: [
        CustomDomainName(
          capsuleId: 1,
          name: 'api.example.com',
          status: DomainNameStatus.configured,
          target: DomainNameTarget.api,
          dnsRecordVerificationValue: '$projectId.api.serverpod.space',
          dnsRecordType: DnsRecordType.cname,
        ),
      ],
      defaultDomainsByTarget: {
        DomainNameTarget.api: '$projectId.api.serverpod.space',
        DomainNameTarget.insights: '$projectId.insights.serverpod.space',
        DomainNameTarget.web: '$projectId.serverpod.space',
      },
    ),
  );
  when(
    () => client.customDomainName.add(
      domainName: any(named: 'domainName'),
      target: any(named: 'target'),
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => CustomDomainNameWithDefaultDomains(
      customDomainName: CustomDomainName(
        name: 'example.com',
        status: DomainNameStatus.needsSetup,
        target: DomainNameTarget.api,
        capsuleId: 1,
        dnsRecordVerificationValue: '$projectId.api.serverpod.space',
        dnsRecordType: DnsRecordType.cname,
      ),
      defaultDomainsByTarget: {
        DomainNameTarget.api: '$projectId.api.serverpod.space',
        DomainNameTarget.insights: '$projectId.insights.serverpod.space',
        DomainNameTarget.web: '$projectId.serverpod.space',
      },
    ),
  );
}

void _stubLogs(final ClientMock client, {required final String projectId}) {
  final timestamp = DateTime.utc(2024, 1, 1);
  final records = [
    LogRecordBuilder()
        .withCloudIds(projectId)
        .withRecordId('1')
        .withTimestamp(timestamp)
        .withContent('Server started')
        .withSeverity(null)
        .build(),
    LogRecordBuilder()
        .withCloudIds(projectId)
        .withRecordId('2')
        .withTimestamp(timestamp)
        .withContent('Ready to accept connections')
        .withSeverity(null)
        .build(),
  ];

  when(
    () => client.logs.fetchRecentRecords(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) => Stream.fromIterable(records));
  when(
    () => client.logs.fetchRecords(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      beforeTime: any(named: 'beforeTime'),
      afterTime: any(named: 'afterTime'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) => Stream.fromIterable(records));
}

void _stubStatusAndDeployments(
  final ClientMock client, {
  required final String projectId,
}) {
  final attemptId = Uuid().v4obj();
  final attempt = DeployAttemptBuilder()
      .withSuccessfulDeployment()
      .withCloudCapsuleId(projectId)
      .withAttemptId(attemptId)
      .withStartedAt(DateTime.utc(2024, 12, 31, 10, 20, 30))
      .withEndedAt(DateTime.utc(2024, 12, 31, 10, 20, 40))
      .build();
  final stages = [
    ...?attempt.stages,
    DeployAttemptStageBuilder()
        .withCloudCapsuleId(projectId)
        .withAttemptId(attemptId)
        .withStageType(DeployStageType.service)
        .withStageStatus(DeployProgressStatus.success)
        .withStartedAt(DateTime.utc(2024, 12, 31, 10, 20, 30))
        .withEndedAt(DateTime.utc(2024, 12, 31, 10, 20, 40))
        .build(),
  ];

  when(
    () => client.status.getCapsuleRuntimeStatus(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => CapsuleRuntimeStatus(
      status: CapsuleStatus(
        cloudCapsuleId: projectId,
        status: CapsuleState.ready,
        deployment: CapsuleDeploymentStatus(
          name: 'app',
          state: CapsuleState.ready,
          desiredReplicas: 2,
          readyReplicas: 2,
        ),
      ),
      serving: DeployAttemptSummary(
        attemptId: attemptId,
        commitHash: '8f3c2a1',
        commitMessage: 'Fix session timeout',
        branch: 'main',
        deployedBy: UserBuilder().withName('Alice').build(),
        startedAt: DateTime.utc(2024, 12, 31, 8, 20, 30),
        endedAt: DateTime.utc(2024, 12, 31, 8, 20, 40),
      ),
    ),
  );
  when(
    () => client.status.getDeployAttempts(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => [attempt]);
  when(
    () => client.status.getDeployAttemptId(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      attemptNumber: any(named: 'attemptNumber'),
    ),
  ).thenAnswer((_) async => attemptId);
  when(
    () => client.status.getDeployAttemptStatus(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
      attemptId: any(named: 'attemptId'),
    ),
  ).thenAnswer((_) async => stages);
}

void _stubDatabase(final ClientMock client) {
  when(
    () => client.database.getConnectionDetails(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => DatabaseConnection(
      host: 'localhost',
      port: 5432,
      name: 'default',
      user: 'wernher',
      requiresSsl: false,
    ),
  );
  when(
    () => client.database.listSnapshots(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => [
      DatabaseSnapshot(
        id: 'snap-1',
        name: 'nightly',
        createdAt: DateTime.utc(2026, 1, 15, 10, 30),
        manual: false,
        fullSizeBytes: 5 * 1024 * 1024,
      ),
      DatabaseSnapshot(
        id: 'snap-2',
        name: 'manual-1',
        createdAt: DateTime.utc(2026, 1, 15, 10, 30),
        manual: true,
        fullSizeBytes: 5 * 1024 * 1024,
      ),
    ],
  );
  when(
    () => client.database.getBackupSchedule(
      cloudCapsuleId: any(named: 'cloudCapsuleId'),
    ),
  ).thenAnswer(
    (_) async => BackupSchedule(
      frequency: BackupFrequency.weekly,
      day: 2,
      hour: 4,
      retention: const Duration(days: 30),
    ),
  );
}

void _stubAdmin(final ClientMock client, {required final String projectId}) {
  when(
    () => client.adminUsers.listUsers(
      cloudProjectId: any(named: 'cloudProjectId'),
      ofAccountStatus: any(named: 'ofAccountStatus'),
      includeArchived: any(named: 'includeArchived'),
    ),
  ).thenAnswer(
    (_) async => [
      UserBuilder()
          .withEmail('test@example.com')
          .withCreatedAt(DateTime.utc(2025, 7, 2, 11))
          .withAccountStatus(UserAccountStatus.registered)
          .build(),
      UserBuilder()
          .withEmail('invited@example.com')
          .withCreatedAt(DateTime.utc(2025, 7, 2, 12))
          .withAccountStatus(UserAccountStatus.invited)
          .build(),
    ],
  );
  when(
    () => client.adminProcurement.listProcuredProducts(
      userEmail: any(named: 'userEmail'),
    ),
  ).thenAnswer((_) async => [('starter', 'PlanProduct')]);
  when(
    () => client.adminProjects.listProjectsInfo(
      includeArchived: any(named: 'includeArchived'),
      includeLatestDeployAttemptTime: any(
        named: 'includeLatestDeployAttemptTime',
      ),
    ),
  ).thenAnswer(
    (_) async => [
      ProjectInfoBuilder()
          .withProject(
            ProjectBuilder()
                .withCreatedAt(DateTime.utc(2025, 7, 2, 11))
                .withCloudProjectId(projectId)
                .withUserOwner(
                  UserBuilder().withEmail('test@example.com').build(),
                ),
          )
          .build(),
    ],
  );
  when(
    () => client.adminUpdatePlan.listOrbPlans(),
  ).thenAnswer((_) async => ['starter', 'growth']);
  when(() => client.adminProjects.redeployCapsule(any())).thenAnswer(
    (_) async => UuidValue.raw('00000000-0000-4000-8000-000000000000'),
  );
}
