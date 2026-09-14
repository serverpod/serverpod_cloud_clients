import 'package:ground_control_client/ground_control_client.dart'
    show ProcurementDeniedException, ProcurementDeniedReason;
import 'package:serverpod_cloud_cli/shared/helpers/plan_features.dart';
import 'package:test/test.dart';

void main() {
  group('Given a plan feature', () {
    test('when building the upgrade hint then it states the availability', () {
      final hint = PlanFeature.customDomains.upgradeHint('my-project');

      expect(
        hint,
        startsWith('Custom domains are available on the Growth plan.\n'),
      );
    });

    test('when building the upgrade hint then it links to the plan page', () {
      final hint = PlanFeature.customDomains.upgradeHint('my-project');

      expect(hint, contains('/project/my-project/plan-and-settings'));
    });
  });

  group('Given a denial because the product is not available', () {
    final denial = ProcurementDeniedException(
      message: "Custom domains are not available for this project's plan.",
      reason: ProcurementDeniedReason.productNotAvailable,
    );

    test('when mapped then the failure repeats the server message', () {
      final failure = planFeatureDeniedFailure(
        denial,
        StackTrace.empty,
        feature: PlanFeature.customDomains,
        projectId: 'my-project',
        failureMessage: 'Could not add the custom domain',
      );

      expect(failure.errors, [denial.message]);
    });

    test('when mapped then the failure hints at the plan upgrade', () {
      final failure = planFeatureDeniedFailure(
        denial,
        StackTrace.empty,
        feature: PlanFeature.customDomains,
        projectId: 'my-project',
        failureMessage: 'Could not add the custom domain',
      );

      expect(failure.hint, PlanFeature.customDomains.upgradeHint('my-project'));
    });
  });

  group('Given a denial for another reason', () {
    final denial = ProcurementDeniedException(
      message: 'The account has no valid payment method',
      reason: ProcurementDeniedReason.paymentMethodRequired,
    );

    test('when mapped then the failure nests the denial', () {
      final failure = planFeatureDeniedFailure(
        denial,
        StackTrace.empty,
        feature: PlanFeature.customDomains,
        projectId: 'my-project',
        failureMessage: 'Could not add the custom domain',
      );

      expect(failure.nestedException, same(denial));
      expect(failure.hint, isNull);
    });
  });
}
