import 'package:basic_utils/basic_utils.dart';
import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/project/project_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/shared/helpers/plan_features.dart';

/// The domain names of a project, and the project's plan type when it has no
/// custom domains and the plan therefore explains why.
typedef CustomDomainListing = ({
  String projectId,
  CustomDomainNameList domains,
  PlanType? planType,
});

abstract class CustomDomainOperations {
  /// Attaches [domainName] to the [target] of the project.
  ///
  /// Throws [FailureException] if the project's plan does not include custom
  /// domains, or if the request fails.
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
    } on ProcurementDeniedException catch (e, stackTrace) {
      throw planFeatureDeniedFailure(
        e,
        stackTrace,
        feature: PlanFeature.customDomains,
        projectId: projectId,
        failureMessage: 'Could not add the custom domain',
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

  /// Lists the default and custom domain names of the project.
  ///
  /// When there are no custom domains, the project's plan type is read as
  /// well, so that the caller can tell an empty listing apart from a plan
  /// without custom domains. It is null if the plan could not be determined.
  static Future<CustomDomainListing> listDomains(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    late final CustomDomainNameList domains;
    try {
      domains = await cloudApiClient.customDomainName.list(
        cloudCapsuleId: projectId,
      );
    } on Exception catch (e, stackTrace) {
      throw FailureException.nested(
        e,
        stackTrace,
        'Failed to list custom domains',
      );
    }

    return (
      projectId: projectId,
      domains: domains,
      planType: domains.customDomainNames.isEmpty
          ? await ProjectCommands.readPlanType(
              cloudApiClient,
              projectId: projectId,
            )
          : null,
    );
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
