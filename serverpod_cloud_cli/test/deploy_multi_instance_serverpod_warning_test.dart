import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/util/deploy_multi_instance_serverpod_warning.dart';
import 'package:test/test.dart';

void main() {
  group('serverpodConstraintPrecludesMultiInstanceSafeRelease', () {
    test('Given ^3.2.0 when evaluated then returns false', () {
      expect(
        serverpodConstraintPrecludesMultiInstanceSafeRelease('^3.2.0'),
        isFalse,
      );
    });

    test('Given 3.3.0 when evaluated then returns false', () {
      expect(
        serverpodConstraintPrecludesMultiInstanceSafeRelease('3.3.0'),
        isFalse,
      );
    });

    test('Given >=3.2.0 <3.3.0 when evaluated then returns true', () {
      expect(
        serverpodConstraintPrecludesMultiInstanceSafeRelease('>=3.2.0 <3.3.0'),
        isTrue,
      );
    });

    test('Given ^3.3.0 when evaluated then returns false', () {
      expect(
        serverpodConstraintPrecludesMultiInstanceSafeRelease('^3.3.0'),
        isFalse,
      );
    });

    test('Given null when evaluated then returns false', () {
      expect(
        serverpodConstraintPrecludesMultiInstanceSafeRelease(null),
        isFalse,
      );
    });
  });

  group('computeUsesMoreThanOneInstance', () {
    test('Given min 1 max 1 when evaluated then returns false', () {
      final info = ComputeInfo(
        cloudCapsuleId: 'c1',
        size: ComputeSizeOption.small,
        minInstances: 1,
        maxInstances: 1,
        memoryMb: 512,
      );
      expect(computeUsesMoreThanOneInstance(info), isFalse);
    });

    test('Given min 1 max 2 when evaluated then returns true', () {
      final info = ComputeInfo(
        cloudCapsuleId: 'c1',
        size: ComputeSizeOption.small,
        minInstances: 1,
        maxInstances: 2,
        memoryMb: 512,
      );
      expect(computeUsesMoreThanOneInstance(info), isTrue);
    });

    test('Given min 2 max 2 when evaluated then returns true', () {
      final info = ComputeInfo(
        cloudCapsuleId: 'c1',
        size: ComputeSizeOption.small,
        minInstances: 2,
        maxInstances: 2,
        memoryMb: 512,
      );
      expect(computeUsesMoreThanOneInstance(info), isTrue);
    });
  });
}
