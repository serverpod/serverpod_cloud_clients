import 'package:ground_control_client/ground_control_client.dart';

class BucketResourceBuilder {
  String _cloudCapsuleId;
  BucketProvider _provider;
  String _storageId;
  BucketVisibility _visibility;
  String _bucketName;
  ServerpodRegion _region;
  BucketStatus _status;

  BucketResourceBuilder()
    : _cloudCapsuleId = 'test-capsule',
      _provider = BucketProvider.gcp,
      _storageId = 'user-uploads',
      _visibility = BucketVisibility.private,
      _bucketName = 'spc-tenant-abcdef0123456789abcdef01',
      _region = ServerpodRegion.values.first,
      _status = BucketStatus.provisioned;

  BucketResourceBuilder withCloudCapsuleId(final String cloudCapsuleId) {
    _cloudCapsuleId = cloudCapsuleId;
    return this;
  }

  BucketResourceBuilder withProvider(final BucketProvider provider) {
    _provider = provider;
    return this;
  }

  BucketResourceBuilder withStorageId(final String storageId) {
    _storageId = storageId;
    return this;
  }

  BucketResourceBuilder withVisibility(final BucketVisibility visibility) {
    _visibility = visibility;
    return this;
  }

  BucketResourceBuilder withBucketName(final String bucketName) {
    _bucketName = bucketName;
    return this;
  }

  BucketResourceBuilder withRegion(final ServerpodRegion region) {
    _region = region;
    return this;
  }

  BucketResourceBuilder withStatus(final BucketStatus status) {
    _status = status;
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
    );
  }
}
