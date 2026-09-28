import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given the platform variables', () {
    test('when checking the future call execution name '
        'then it is reserved with a plan-managed reason', () {
      expect(
        PlatformVariables.isReservedWithReason(
          PlatformVariables.futureCallEnabled,
        ),
        "'SERVERPOD_FUTURE_CALL_ENABLED' is managed by your project "
        "plan and can't be set.",
      );
    });

    test('when checking another name then it is not reserved', () {
      expect(PlatformVariables.isReservedWithReason('MY_VARIABLE'), isNull);
    });
  });
}
