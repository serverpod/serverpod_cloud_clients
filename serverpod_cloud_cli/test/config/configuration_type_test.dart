import 'package:args/args.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/util/config/config.dart';

enum AnimalEnum {
  cat,
  dog,
  mouse,
}

void main() async {
  group('Given an EnumOption', () {
    const typedOpt = EnumOption(
      argName: 'animal',
      enumParser: EnumParser(AnimalEnum.values),
      mandatory: true,
    );
    final parser = ArgParser();
    [typedOpt].prepareForParsing(parser);

    test('when given a valid value then it is parsed correctly', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--animal', 'cat']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(AnimalEnum.cat));
    });

    test('when given an invalid value then it reports an error', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--animal', 'unicorn']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        equals(
            'Invalid value for option `animal`: "unicorn" is not in cat|dog|mouse'),
      );
    });
  });

  group('Given an IntOption', () {
    const typedOpt = IntOption(
      argName: 'number',
      mandatory: true,
    );
    final parser = ArgParser();
    [typedOpt].prepareForParsing(parser);

    test('when given a valid positive value then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '123']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(123));
    });

    test('when given a valid negative value then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '-123']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(-123));
    });

    test('when given a non-integer value then it reports an error', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '0.45']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        contains('Invalid value for option `number` <integer>'),
      );
    });
    test('when given a non-number value then it reports an error', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', 'unicorn']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        contains('Invalid value for option `number` <integer>'),
      );
    });
  });

  group('Given a ranged IntOption', () {
    const typedOpt = IntOption(
      argName: 'number',
      mandatory: true,
      min: 100,
      max: 200,
    );
    final parser = ArgParser();
    [typedOpt].prepareForParsing(parser);

    test('when given a valid value then it is parsed correctly', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '123']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(123));
    });

    test(
        'when given an integer value less than the range then it reports an error',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '99']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        equals(
            'Invalid value for option `number` <integer>: 99 is below the minimum (100)'),
      );
    });
    test(
        'when given an integer value greater than the range then it reports an error',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--number', '201']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        equals(
            'Invalid value for option `number` <integer>: 201 is above the maximum (200)'),
      );
    });
  });

  group('Given a ranged DurationOption', () {
    const typedOpt = DurationOption(
      argName: 'duration',
      mandatory: true,
      min: Duration.zero,
      max: Duration(days: 2),
    );
    final parser = ArgParser();
    [typedOpt].prepareForParsing(parser);

    test('when given a valid days value then it is parsed correctly', () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '1d']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(Duration(days: 1)));
    });

    test('when given a valid hours value then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '2h']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(Duration(hours: 2)));
    });

    test('when given a valid minutes value then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '3m']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(Duration(minutes: 3)));
    });

    test('when given a valid seconds value then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '24s']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(Duration(seconds: 24)));
    });

    test('when given a valid value with no unit then it is parsed correctly',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '2']),
        env: <String, String>{},
      );
      expect(config.value(typedOpt), equals(Duration(seconds: 2)));
    });

    test('when given a value less than the range then it reports an error',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '-2s']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        equals(
            'Invalid value for option `duration` <integer[s|m|h|d]>: -2s is below the minimum (0)'),
      );
    });

    test('when given a value greater than the range then it reports an error',
        () async {
      final config = Configuration.fromEnvAndArgs(
        options: [typedOpt],
        args: parser.parse(['--duration', '20d']),
        env: <String, String>{},
      );

      expect(config.errors, hasLength(1));
      expect(
        config.errors.single,
        equals(
            'Invalid value for option `duration` <integer[s|m|h|d]>: 20d is above the maximum (2d)'),
      );
    });
  });
}
