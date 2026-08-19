import 'package:ground_control_client/ground_control_client.dart';

class DartSdkVersionPolicyBuilder {
  List<String> _supportedVersions;
  String _defaultVersion;
  String _minVersionInclusive;
  String _maxVersionExclusive;
  Uri _documentationUrl;

  DartSdkVersionPolicyBuilder()
    : _supportedVersions = ['3.8', '3.9', '3.10', '3.11', '3.12'],
      _defaultVersion = '3.8',
      _minVersionInclusive = '3.8.0',
      _maxVersionExclusive = '3.13.0',
      _documentationUrl = Uri.parse(
        'https://docs.serverpod.dev/cloud/reference/dart-sdk-versions',
      );

  DartSdkVersionPolicyBuilder withSupportedVersions(
    final List<String> supportedVersions,
  ) {
    _supportedVersions = supportedVersions;
    return this;
  }

  DartSdkVersionPolicyBuilder withDefaultVersion(final String defaultVersion) {
    _defaultVersion = defaultVersion;
    return this;
  }

  DartSdkVersionPolicyBuilder withMinVersionInclusive(
    final String minVersionInclusive,
  ) {
    _minVersionInclusive = minVersionInclusive;
    return this;
  }

  DartSdkVersionPolicyBuilder withMaxVersionExclusive(
    final String maxVersionExclusive,
  ) {
    _maxVersionExclusive = maxVersionExclusive;
    return this;
  }

  DartSdkVersionPolicyBuilder withDocumentationUrl(final Uri documentationUrl) {
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
