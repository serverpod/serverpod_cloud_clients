import 'package:serverpod_cloud_cli/command_runner/commands/admin/product/product_admin_ui.dart';
import 'package:test/test.dart';

import '../../../test_utils/render_command_ui.dart';

void main() {
  group('Given a ProductListTextUi', () {
    group('when rendered with procured products', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProductListTextUi(),
          data: [
            {'name': 'starter', 'type': 'PlanProduct'},
            {'name': 'starter-project', 'type': 'ProjectProduct'},
          ],
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the table headings', () {
        expect(stdout, contains('Product'));
        expect(stdout, contains('Type'));
      });

      test('then stdout contains the product rows', () {
        expect(stdout, contains('starter'));
        expect(stdout, contains('PlanProduct'));
        expect(stdout, contains('starter-project'));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProductProcureTextUi', () {
    group('when rendered after procuring a plan', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProductProcureTextUi(),
          data: const {'planName': 'growth'},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the procure success message', () {
        expect(
          stdout,
          contains('The plan growth has been procured for the user.'),
        );
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });

  group('Given a ProductCancelTextUi', () {
    group('when rendered after cancelling a plan', () {
      late String stdout;
      late String stderr;

      setUp(() async {
        final io = await renderCommandUi(
          const ProductCancelTextUi(),
          data: const <String, Object?>{},
        );
        stdout = io.stdout;
        stderr = io.stderr;
      });

      test('then stdout contains the cancel success message', () {
        expect(stdout, contains("The user's plan has been cancelled."));
      });

      test('then stderr is empty', () {
        expect(stderr, isEmpty);
      });
    });
  });
}
