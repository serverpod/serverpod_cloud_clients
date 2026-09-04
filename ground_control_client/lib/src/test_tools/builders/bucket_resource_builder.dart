import 'package:ground_control_client/ground_control_client.dart';

class BucketResourceBuilder {
  String _cloudCapsuleId;
  BucketProvider _provider;
  String _storageId;
  BucketVisibility _visibility;
  String _bucketName;
  ServerpodRegion _region;
  BucketStatus _status;
  int? _lastMeteredSizeBytes;
  DateTime? _accessRevokedAt;
  BucketAccessRevocationReason? _accessRevokedReason;

  BucketResourceBuilder()
    : _cloudCapsuleId = 'test-capsule',
      _provider = BucketProvider.gcp,
      _storageId = 'user-uploads',
      _visibility = BucketVisibility.private,
      _bucketName = 'spc-tenant-abcdef0123456789abcdef01',
      _region = ServerpodRegion.values.first,
      _status = BucketStatus.provisioned;

  BucketResourceBuilder withCloudCapsuleId(String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;

    return this;
  }

  BucketResourceBuilder withProvider(BucketProvider provider) {
    _provider = provider;

    return this;
  }

  BucketResourceBuilder withStorageId(String storageId) {
    _storageId = storageId;

    return this;
  }

  BucketResourceBuilder withVisibility(BucketVisibility visibility) {
    _visibility = visibility;

    return this;
  }

  BucketResourceBuilder withBucketName(String bucketName) {
    _bucketName = bucketName;

    return this;
  }

  BucketResourceBuilder withRegion(ServerpodRegion region) {
    _region = region;

    return this;
  }

  BucketResourceBuilder withStatus(BucketStatus status) {
    _status = status;

    return this;
  }

  BucketResourceBuilder withLastMeteredSizeBytes(int? lastMeteredSizeBytes) {
    _lastMeteredSizeBytes = lastMeteredSizeBytes;

    return this;
  }

  BucketResourceBuilder withAccessRevoked({
    BucketAccessRevocationReason? reason,
  }) {
    _accessRevokedAt = DateTime.utc(2026, 7, 20, 10);
    _accessRevokedReason = reason;

    return this;
  }

  BucketResource build() {
    return BucketResource(
      cloudCapsuleId: _cloudCapsuleId,
      provider: _provider,
      storageId: _storageId,
      visibility: _visibility,
      bucketName: _bucketName,
      region: _region,
      status: _status,
      lastMeteredSizeBytes: _lastMeteredSizeBytes,
      accessRevokedAt: _accessRevokedAt,
      accessRevokedReason: _accessRevokedReason,
    );
  }
}
