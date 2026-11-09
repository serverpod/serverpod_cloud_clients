import 'package:ground_control_client/ground_control_client.dart';

import 'project_builder.dart';
import 'project_info_builder.dart';

class AdminProjectInfoBuilder {
  ProjectInfoBuilder projectInfoBuilder;
  ProjectLifecycleStatus _status;
  DateTime? _suspendedAt;
  ProjectSuspensionReason? _suspensionReason;
  String _planProductId;
  String _subscriptionId;
  List<PaymentsStatus> _overduePaymentsStatuses;
  String? _billingPlanId;
  DateTime? _firstInvoicePaidAt;
  String? _firstPaidInvoiceId;
  String? _gracePeriodInvoiceId;
  DateTime? _gracePeriodSuspendAt;
  DateTime? _gracePeriodConcludedAt;
  DeployAttempt? _latestDeployAttempt;

  AdminProjectInfoBuilder({final ProjectInfoBuilder? projectInfoBuilder})
    : projectInfoBuilder = projectInfoBuilder ?? ProjectInfoBuilder(),
      _status = ProjectLifecycleStatus.active,
      _suspendedAt = null,
      _suspensionReason = null,
      _planProductId = 'closed-beta:0',
      _subscriptionId = 'orb_sub_test',
      _overduePaymentsStatuses = const [],
      _billingPlanId = 'closed-beta:1',
      _firstInvoicePaidAt = null,
      _firstPaidInvoiceId = null,
      _gracePeriodInvoiceId = null,
      _gracePeriodSuspendAt = null,
      _gracePeriodConcludedAt = null,
      _latestDeployAttempt = null;

  AdminProjectInfoBuilder withProject(final ProjectBuilder projectBuilder) {
    projectInfoBuilder.withProject(projectBuilder);
    return this;
  }

  AdminProjectInfoBuilder withProjectInfo(
    final ProjectInfoBuilder projectInfoBuilder,
  ) {
    this.projectInfoBuilder = projectInfoBuilder;
    return this;
  }

  AdminProjectInfoBuilder withStatus(final ProjectLifecycleStatus status) {
    _status = status;
    return this;
  }

  AdminProjectInfoBuilder withSuspendedAt(final DateTime? suspendedAt) {
    _suspendedAt = suspendedAt;
    return this;
  }

  AdminProjectInfoBuilder withSuspensionReason(
    final ProjectSuspensionReason? suspensionReason,
  ) {
    _suspensionReason = suspensionReason;
    return this;
  }

  /// A suspended project, for an overdue payment unless [reason] says
  /// otherwise.
  AdminProjectInfoBuilder withSuspended([
    ProjectSuspensionReason reason = ProjectSuspensionReason.paymentOverdue,
  ]) {
    _status = ProjectLifecycleStatus.suspended;
    _suspendedAt = DateTime.now();
    _suspensionReason = reason;
    return this;
  }

  AdminProjectInfoBuilder withPlanProductId(final String planProductId) {
    if (planProductId.isNotEmpty) {
      assert(
        planProductId.contains(':'),
        'Plan product ID must contain a colon',
      );
    }
    _planProductId = planProductId;
    return this;
  }

  AdminProjectInfoBuilder withSubscriptionId(final String subscriptionId) {
    _subscriptionId = subscriptionId;
    return this;
  }

  AdminProjectInfoBuilder withOverduePaymentsStatuses(
    final List<PaymentsStatus> overduePaymentsStatuses,
  ) {
    _overduePaymentsStatuses = overduePaymentsStatuses;
    return this;
  }

  AdminProjectInfoBuilder withBillingPlanId(final String? billingPlanId) {
    _billingPlanId = billingPlanId;
    return this;
  }

  AdminProjectInfoBuilder withFirstInvoicePaidAt(final DateTime? paidAt) {
    _firstInvoicePaidAt = paidAt;
    return this;
  }

  AdminProjectInfoBuilder withFirstPaidInvoiceId(final String? invoiceId) {
    _firstPaidInvoiceId = invoiceId;
    return this;
  }

  AdminProjectInfoBuilder withGracePeriodInvoiceId(final String? invoiceId) {
    _gracePeriodInvoiceId = invoiceId;
    return this;
  }

  AdminProjectInfoBuilder withGracePeriodSuspendAt(final DateTime? suspendAt) {
    _gracePeriodSuspendAt = suspendAt;
    return this;
  }

  AdminProjectInfoBuilder withGracePeriodConcludedAt(
    final DateTime? concludedAt,
  ) {
    _gracePeriodConcludedAt = concludedAt;
    return this;
  }

  AdminProjectInfoBuilder withLatestDeployAttempt(
    final DeployAttempt? latestDeployAttempt,
  ) {
    _latestDeployAttempt = latestDeployAttempt;
    return this;
  }

  AdminProjectInfo build() {
    return AdminProjectInfo(
      projectInfo: projectInfoBuilder.build(),
      status: _status,
      suspendedAt: _suspendedAt,
      suspensionReason: _suspensionReason,
      planProductId: _planProductId,
      subscriptionId: _subscriptionId,
      overduePaymentsStatuses: _overduePaymentsStatuses,
      billingPlanId: _billingPlanId,
      firstInvoicePaidAt: _firstInvoicePaidAt,
      firstPaidInvoiceId: _firstPaidInvoiceId,
      gracePeriodInvoiceId: _gracePeriodInvoiceId,
      gracePeriodSuspendAt: _gracePeriodSuspendAt,
      gracePeriodConcludedAt: _gracePeriodConcludedAt,
      latestDeployAttempt: _latestDeployAttempt,
    );
  }
}
