import 'package:ground_control_client/ground_control_client.dart';

class BucketFileBuilder {
  String _name;
  int? _sizeBytes;
  DateTime? _updated;

  BucketFileBuilder()
    : _name = 'file.txt',
      _sizeBytes = 1024,
      _updated = DateTime.utc(2026, 7, 20, 10);

  BucketFileBuilder withName(final String name) {
    _name = name;

    return this;
  }

  BucketFileBuilder withSizeBytes(final int? sizeBytes) {
    _sizeBytes = sizeBytes;

    return this;
  }

  BucketFileBuilder withUpdated(final DateTime? updated) {
    _updated = updated;

    return this;
  }

  BucketFile build() {
    return BucketFile(name: _name, sizeBytes: _sizeBytes, updated: _updated);
  }
}
