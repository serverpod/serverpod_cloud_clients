import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';

enum PasswordCategory {
  custom('Custom'),
  services('Services'),
  auth('Auth'),
  legacyAuth('Legacy Auth');

  const PasswordCategory(this.displayName);
  final String displayName;
}

class PasswordMetadata {
  final PasswordCategory category;
  final String notes;
  final String? Function(String value) isValidValue;

  const PasswordMetadata({
    required this.category,
    required this.notes,
    required this.isValidValue,
  });
}

class PasswordInfo {
  final String name;
  final PasswordCategory category;
  final String? notes;
  final bool isPlatformManaged;
  final bool isUserSet;

  PasswordInfo({
    required this.name,
    required this.category,
    this.notes,
    required this.isPlatformManaged,
    required this.isUserSet,
  });

  String get status {
    if (isPlatformManaged && !isUserSet) {
      return 'AUTO (Platform)';
    } else if (isUserSet) {
      return 'SET (User)';
    } else {
      return 'UNSET';
    }
  }
}

abstract final class PasswordDefinitions {
  static const String prefix = 'SERVERPOD_PASSWORD_';

  static final Map<String, PasswordMetadata> metadataMap = {
    'database': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Database password',
      isValidValue: (_) => null,
    ),
    'serviceSecret': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Insights password',
      isValidValue: (final value) => value.length >= 20
          ? null
          : 'Password must be at least 20 characters long.',
    ),
    'redis': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Redis password',
      isValidValue: (_) => null,
    ),
    'HMACAccessKeyId': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Access key ID for HMAC authentication (GCP)',
      isValidValue: (_) => null,
    ),
    'HMACSecretKey': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Secret key for HMAC authentication (GCP)',
      isValidValue: (_) => null,
    ),
    'AWSAccessKeyId': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Access key ID for AWS authentication (S3)',
      isValidValue: (_) => null,
    ),
    'AWSSecretKey': PasswordMetadata(
      category: PasswordCategory.services,
      notes: 'Secret key for AWS authentication (S3)',
      isValidValue: (_) => null,
    ),
    'emailSecretHashPepper': PasswordMetadata(
      category: PasswordCategory.auth,
      notes: 'Used by serverpod_auth_idp_server',
      isValidValue: (_) => null,
    ),
    'jwtRefreshTokenHashPepper': PasswordMetadata(
      category: PasswordCategory.auth,
      notes: 'Used by serverpod_auth_idp_server',
      isValidValue: (final value) => value.length >= 10
          ? null
          : 'Password must be at least 10 characters long.',
    ),
    'jwtHmacSha512PrivateKey': PasswordMetadata(
      category: PasswordCategory.auth,
      notes: 'Used by serverpod_auth_idp_server',
      isValidValue: (_) => null,
    ),
    'serverpod_auth_googleClientSecret': PasswordMetadata(
      category: PasswordCategory.legacyAuth,
      notes: 'Client secret for Google authentication',
      isValidValue: (_) => null,
    ),
    'serverpod_auth_firebaseServiceAccountKey': PasswordMetadata(
      category: PasswordCategory.legacyAuth,
      notes: 'Service account key for Firebase authentication',
      isValidValue: (_) => null,
    ),
  };

  static PasswordCategory getCategory(final String name) {
    return metadataMap[name]?.category ?? PasswordCategory.custom;
  }

  static String? getNotes(final String name) {
    return metadataMap[name]?.notes;
  }

  static String getDisplayNotes(final String name) {
    final metadata = metadataMap[name];
    if (metadata == null) {
      return '';
    }

    return metadata.notes;
  }

  static String? isValidValue(final String name, final String value) {
    return metadataMap[name]?.isValidValue(value);
  }

  static String getFullSecretName(final String name) {
    return '$prefix$name';
  }

  static String? stripPrefix(final String secretName) {
    if (secretName.startsWith(prefix)) {
      return secretName.substring(prefix.length);
    }
    return null;
  }
}

abstract class PasswordCommands {
  static Future<void> listPasswords(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
  }) async {
    late List<String> userSecrets;
    late List<String> managedSecrets;

    try {
      userSecrets = await cloudApiClient.secrets.list(projectId);
      managedSecrets = await cloudApiClient.secrets.listManaged(projectId);
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to list passwords');
    }

    final passwordInfos = <String, PasswordInfo>{};

    for (final managedSecret in managedSecrets) {
      final passwordName = PasswordDefinitions.stripPrefix(managedSecret);
      if (passwordName != null) {
        final category = PasswordDefinitions.getCategory(passwordName);
        final notes = PasswordDefinitions.getNotes(passwordName);

        passwordInfos[passwordName] = PasswordInfo(
          name: passwordName,
          category: category,
          notes: notes,
          isPlatformManaged: true,
          isUserSet: false,
        );
      }
    }

    for (final secret in userSecrets) {
      final passwordName = PasswordDefinitions.stripPrefix(secret);
      if (passwordName != null) {
        final category = PasswordDefinitions.getCategory(passwordName);
        final notes = PasswordDefinitions.getNotes(passwordName);

        passwordInfos[passwordName] = PasswordInfo(
          name: passwordName,
          category: category,
          notes: notes,
          isPlatformManaged: managedSecrets.contains(secret),
          isUserSet: true,
        );
      }
    }

    _printPasswords(logger, passwordInfos.values.toList());
  }

  static void _printPasswords(
    final CommandLogger logger,
    final List<PasswordInfo> passwords,
  ) {
    logger.line('');

    final passwordsByCategory = <PasswordCategory, List<PasswordInfo>>{};

    for (final password in passwords) {
      passwordsByCategory
          .putIfAbsent(password.category, () => [])
          .add(password);
    }

    final categoryOrder = [
      PasswordCategory.custom,
      PasswordCategory.services,
      PasswordCategory.auth,
      PasswordCategory.legacyAuth,
    ];

    for (final category in categoryOrder) {
      final categoryPasswords = passwordsByCategory[category] ?? [];

      if (category != PasswordCategory.custom && categoryPasswords.isEmpty) {
        continue;
      }

      logger.line('');
      logger.line(category.displayName);
      logger.line('');

      categoryPasswords.sort((final a, final b) => a.name.compareTo(b.name));

      final printer = TablePrinter();
      printer.addHeaders(['Name', 'Status', 'Notes']);

      for (final password in categoryPasswords) {
        final displayNotes = PasswordDefinitions.getDisplayNotes(password.name);
        printer.addRow([password.name, password.status, displayNotes]);
      }

      printer.writeLines(logger.line);
      logger.line('');
    }
  }

  static Future<void> setPassword(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String name,
    required final String value,
  }) async {
    final validationError = PasswordDefinitions.isValidValue(name, value);
    if (validationError != null) {
      throw ErrorExitException('Password "$name": $validationError');
    }

    final fullSecretName = PasswordDefinitions.getFullSecretName(name);

    try {
      await cloudApiClient.secrets.upsert(
        secrets: {fullSecretName: value},
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to set password');
    }

    logger.success('Successfully set password "$name".');
  }

  static Future<void> unsetPassword(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String projectId,
    required final String name,
  }) async {
    final fullSecretName = PasswordDefinitions.getFullSecretName(name);

    try {
      await cloudApiClient.secrets.delete(
        cloudCapsuleId: projectId,
        key: fullSecretName,
      );
    } on Exception catch (e, s) {
      throw FailureException.nested(e, s, 'Failed to unset password');
    }

    logger.success('Successfully unset password "$name".');
  }
}
