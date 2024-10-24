import 'package:serverpod_cloud_cli/command_runner/helpers/option_parsing.dart';
import 'package:test/test.dart';

void main() {
  group('OptionParsing.parseDate() - ', () {
    test(
        'When calling parseDate() with empty string then it throws ArgumentError.',
        () {
      expect(() => OptionParsing.parseDate(''), throwsArgumentError);
    });

    test(
        'When calling parseDate() with 2020-01-01 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01'),
        equals(DateTime(2020, 1, 1)),
      );
    });

    test(
        'When calling parseDate() with 20200101 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('20200101'),
        equals(DateTime(2020, 1, 1)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01 12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01 12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01T12:20:40Z then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01T12:20:40Z'),
        equals(DateTime.utc(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01T12:20:40.001z then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01T12:20:40.001z'),
        equals(DateTime.utc(2020, 1, 1, 12, 20, 40, 1)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01t12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01t12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01-12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01-12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01:12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01:12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01_12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01_12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01/12:20:40 then it successfully returns a DateTime.',
        () {
      expect(
        OptionParsing.parseDate('2020-01-01/12:20:40'),
        equals(DateTime(2020, 1, 1, 12, 20, 40)),
      );
    });

    test(
        'When calling parseDate() with 2020-01-01x12:20:40 then it throws ArgumentError.',
        () {
      expect(() => OptionParsing.parseDate('2020-01-01x12:20:40'),
          throwsArgumentError);
    });
  });
}
