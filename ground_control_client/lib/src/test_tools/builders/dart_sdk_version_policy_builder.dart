import 'package:ground_control_client/ground_control_client.dart';

class DartSdkVersionPolicyBuilder {
  List<String> _supportedVersions;
  String _defaultVersion;
  String _minVersionInclusive;
  String _maxVersionExclusive;
  Uri _documentationUrl;

  DartSdkVersionPolicyBuilder()
    : _supportedVersions = ['3.8', '3.9', '3.10', '3.11', '3.12', '3.13'],
      _defaultVersion = '3.8',
      _minVersionInclusive = '3.8.0',
      _maxVersionExclusive = '3.14.0',
      _documentationUrl = Uri.parse(
        'https://docs.serverpod.dev/cloud/reference/dart-sdk-versions',
      );

  DartSdkVersionPolicyBuilder withSupportedVersions(
    List<String> supportedVersions,
  ) {
    _supportedVersions = supportedVersions;
    return this;
  }

  DartSdkVersionPolicyBuilder withDefaultVersion(String defaultVersion) {
    _defaultVersion = defaultVersion;
    return this;
  }

  DartSdkVersionPolicyBuilder withMinVersionInclusive(
    String minVersionInclusive,
  ) {
    _minVersionInclusive = minVersionInclusive;
    return this;
  }

  DartSdkVersionPolicyBuilder withMaxVersionExclusive(
    String maxVersionExclusive,
  ) {
    _maxVersionExclusive = maxVersionExclusive;
    return this;
  }

  DartSdkVersionPolicyBuilder withDocumentationUrl(Uri documentationUrl) {
    _documentationUrl = documentationUrl;
    return this;
  }

  DartSdkVersionPolicy build() {
    return DartSdkVersionPolicy(
      supportedVersions: [
        for (final version in _supportedVersions)
          DartSdkVersion(version: version),
      ],
      defaultVersion: _defaultVersion,
      minVersionInclusive: _minVersionInclusive,
      maxVersionExclusive: _maxVersionExclusive,
      documentationUrl: _documentationUrl,
    );
  }
}
