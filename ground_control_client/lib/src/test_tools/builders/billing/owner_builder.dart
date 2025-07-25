import 'package:ground_control_client/ground_control_client.dart';

class OwnerBuilder {
  UuidValue? _id;
  String _externalBillingId;
  Uri _billingPortalUrl;
  List<String> _billingEmails;
  BillingInfo? _billingInfo;
  List<Project>? _projects;

  OwnerBuilder()
      : _id = Uuid().v4obj(),
        _externalBillingId = 'default-external-billing-id',
        _billingPortalUrl = Uri.parse('https://billing.example.com'),
        _billingEmails = [],
        _projects = [],
        _billingInfo = null;

  OwnerBuilder withId(UuidValue id) {
    _id = id;
    return this;
  }

  OwnerBuilder withExternalBillingId(String externalBillingId) {
    _externalBillingId = externalBillingId;
    return this;
  }

  OwnerBuilder withBillingPortalUrl(Uri billingPortalUrl) {
    _billingPortalUrl = billingPortalUrl;
    return this;
  }

  OwnerBuilder withBillingPortalUrlString(String billingPortalUrl) {
    _billingPortalUrl = Uri.parse(billingPortalUrl);
    return this;
  }

  OwnerBuilder withBillingEmails(List<String> billingEmails) {
    _billingEmails = billingEmails;
    return this;
  }

  OwnerBuilder addBillingEmail(String email) {
    _billingEmails.add(email);
    return this;
  }

  OwnerBuilder withBillingInfo(BillingInfo? billingInfo) {
    _billingInfo = billingInfo;
    return this;
  }

  OwnerBuilder withProjects(List<Project>? projects) {
    _projects = projects;
    return this;
  }

  OwnerBuilder addProject(Project project) {
    _projects ??= [];
    _projects?.add(project);
    return this;
  }

  Owner build() {
    return Owner(
      id: _id,
      externalBillingId: _externalBillingId,
      billingPortalUrl: _billingPortalUrl,
      billingEmails: _billingEmails,
      billingInfo: _billingInfo,
      projects: _projects,
    );
  }
}
