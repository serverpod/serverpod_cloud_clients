import 'package:ground_control_client/ground_control_client.dart';

/// Builds an [AppReadinessItem]. The default is the not-done
/// "bundle ID reported" item.
class AppReadinessItemBuilder {
  AppReadinessKey _key;
  bool _done;
  String _title;
  String? _action;
  String? _url;

  AppReadinessItemBuilder()
    : _key = AppReadinessKey.appIdentifierReported,
      _done = false,
      _title = 'Bundle ID reported',
      _action =
          'Run the scloud setup step in your project so Serverpod Cloud '
          'reads the identifier from your code.';

  AppReadinessItemBuilder withKey(AppReadinessKey key) {
    _key = key;
    return this;
  }

  AppReadinessItemBuilder withDone(bool done) {
    _done = done;
    return this;
  }

  AppReadinessItemBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  AppReadinessItemBuilder withAction(String? action) {
    _action = action;
    return this;
  }

  AppReadinessItemBuilder withUrl(String? url) {
    _url = url;
    return this;
  }

  AppReadinessItem build() {
    return AppReadinessItem(
      key: _key,
      done: _done,
      title: _title,
      action: _action,
      url: _url,
    );
  }
}
