import 'dart:async';

import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';

import '../../util/printers/table_printer.dart';

abstract class Auth {
  static Future<void> createApiToken(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    final DateTime? expiresAt,
    final Duration? expiresAfter,
  }) async {
    final authSuccess = await cloudApiClient.authWithAuth.createCliToken(
      expiresAt: expiresAt,
      expiresAfter: expiresAfter,
    );
    logger.success(
      'Successfully created an API token.',
      newParagraph: true,
      followUp: '''
Use the --token option or the SERVERPOD_CLOUD_TOKEN environment variable to
authenticate with this token in scloud commands.''',
    );
    logger.info(
      'The token is only visible once:\n${authSuccess.token}\n',
      newParagraph: true,
    );
  }

  static Future<void> listAuthSessions(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final bool inUtc,
  }) async {
    final tokenInfos = await cloudApiClient.authWithAuth.listAuthSessions();

    final tablePrinter = TablePrinter();
    tablePrinter.addHeaders([
      'Token Id',
      'Method',
      'Created',
      'Last Used',
      'Expires',
      'TTL on non-use',
    ]);
    for (final tokenInfo in tokenInfos) {
      tablePrinter.addRow([
        tokenInfo.tokenId,
        tokenInfo.method,
        tokenInfo.createdAt.toTzString(inUtc, 19),
        tokenInfo.lastUsedAt?.toTzString(inUtc, 19),
        tokenInfo.expiresAt?.toTzString(inUtc, 19),
        tokenInfo.expireAfterUnusedFor?.friendlyFormat(),
      ]);
    }
    tablePrinter.writeLines(logger.line);
  }
}
