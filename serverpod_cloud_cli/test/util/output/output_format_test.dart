import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:test/test.dart';

void main() {
  group('Given the text output format', () {
    test('when checking if it is structured then it is not', () {
      expect(OutputFormat.text.isStructured, isFalse);
    });
  });

  group('Given the json output format', () {
    test('when checking if it is structured then it is', () {
      expect(OutputFormat.json.isStructured, isTrue);
    });
  });

  group('Given the yaml output format', () {
    test('when checking if it is structured then it is', () {
      expect(OutputFormat.yaml.isStructured, isTrue);
    });
  });
}
