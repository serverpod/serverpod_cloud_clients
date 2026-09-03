import 'package:basic_utils/basic_utils.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

abstract class CustomDomainOperations {
  static Future<Map<String, Object?>> attachDomain(
    final Client cloudApiClient, {
    required final String projectId,
    required final String domainName,
    required final DomainNameTarget target,
  }) async {
    late CustomDomainNameWithDefaultDomains attached;
    try {
      attached = await cloudApiClient.customDomainName.add(
        domainName: domainName,
        target: target,
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Could not add the custom domain',
      );
    }

    final targetDefaultDomain = attached.defaultDomainsByTarget[target];
    if (targetDefaultDomain == null) {
      throw FailureException(
        error: 'Could not find the target domain for "$target".',
      );
    }

    return {
      'domainName': domainName,
      'projectId': projectId,
      'records': _dnsRecords(
        domainName: domainName,
        target: target,
        targetDefaultDomain: targetDefaultDomain,
        verificationValue: attached.customDomainName.dnsRecordVerificationValue,
      ),
    };
  }

  static Future<CustomDomainNameList> listDomains(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    try {
      return await cloudApiClient.customDomainName.list(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to list custom domains',
      );
    }
  }

  static Future<Map<String, Object?>> detachDomain(
    final Client cloudApiClient, {
    required final String projectId,
    required final String domainName,
  }) async {
    try {
      await cloudApiClient.customDomainName.remove(
        cloudCapsuleId: projectId,
        domainName: domainName,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to remove custom domain',
      );
    }

    return {'domainName': domainName};
  }

  static Future<DomainNameStatus> verifyDomain(
    final Client cloudApiClient, {
    required final String projectId,
    required final String domainName,
  }) async {
    try {
      return await cloudApiClient.customDomainName.refreshRecord(
        cloudCapsuleId: projectId,
        domainName: domainName,
      );
    } on DNSVerificationFailedException catch (e) {
      throw FailureException(
        error:
            'Failed to verify the DNS record for the custom domain: ${e.message}',
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to refresh custom domain record',
      );
    }
  }

  static List<Map<String, Object?>> _dnsRecords({
    required final String domainName,
    required final DomainNameTarget target,
    required final String targetDefaultDomain,
    required final String verificationValue,
  }) {
    if (DomainUtils.isSubDomain(domainName)) {
      return [
        {'type': 'CNAME', 'domain': domainName, 'value': targetDefaultDomain},
      ];
    }

    return [
      {'type': 'ANAME', 'domain': domainName, 'value': targetDefaultDomain},
      {'type': 'TXT', 'domain': domainName, 'value': verificationValue},
      if (target == DomainNameTarget.web)
        {
          'type': 'CNAME',
          'domain': 'www.$domainName',
          'value': targetDefaultDomain,
        },
    ];
  }
}
