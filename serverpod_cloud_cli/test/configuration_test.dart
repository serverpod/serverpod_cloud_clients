import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';
import 'package:test/test.dart';

void main() async {
  group('Given invalid configuration abbrevation without full name', () {
    const projectIdOpt = ConfigOption(
      argAbbrev: 'p',
    );
    final parser = ArgParser();

    test('when preparing for parsing then throws exception', () async {
      expect(
        () => [projectIdOpt].prepareForParsing(parser),
        throwsA(allOf(
          isA<InvalidOptionConfigurationException>(),
          (final e) => e.toString().contains(
                "An argument option can't have an abbreviation but not a full name",
              ),
        )),
      );
    });
  });

  group('Given invalid configuration positional argument and isFlag', () {
    const projectIdOpt = ConfigOption(
      argPos: 0,
      isFlag: true,
    );
    final parser = ArgParser();

    test('when preparing for parsing then throws exception', () async {
      expect(
        () => [projectIdOpt].prepareForParsing(parser),
        throwsA(allOf(
          isA<InvalidOptionConfigurationException>(),
          (final e) => e.toString().contains(
                "Positional options can't be flags",
              ),
        )),
      );
    });
  });

  group('Given invalid configuration valueRequired and mandatory', () {
    const projectIdOpt = ConfigOption(
      valueRequired: true,
      mandatory: true,
    );
    final parser = ArgParser();

    test('when preparing for parsing then throws exception', () async {
      expect(
        () => [projectIdOpt].prepareForParsing(parser),
        throwsA(allOf(
          isA<InvalidOptionConfigurationException>(),
          (final e) => e.toString().contains(
                "An argument option should not have valueRequired specified if mandatory is true, "
                "since this already guarantees that the value will be passed",
              ),
        )),
      );
    });
  });

  group('Given invalid configuration mandatory with default value', () {
    const projectIdOpt = ConfigOption(
      mandatory: true,
      defaultsTo: 'default',
    );
    final parser = ArgParser();

    test('when preparing for parsing then throws exception', () async {
      expect(
        () => [projectIdOpt].prepareForParsing(parser),
        throwsA(allOf(
          isA<InvalidOptionConfigurationException>(),
          (final e) => e
              .toString()
              .contains("Mandatory options can't have default values"),
        )),
      );
    });
  });

  group(
      'Given invalid configuration mandatory with default value from function',
      () {
    const projectIdOpt = ConfigOption(
      mandatory: true,
      defaultFrom: _defaultValueFunction,
    );

    final parser = ArgParser();

    test('when preparing for parsing then throws exception', () async {
      expect(
        () => [projectIdOpt].prepareForParsing(parser),
        throwsA(allOf(
          isA<InvalidOptionConfigurationException>(),
          (final e) => e
              .toString()
              .contains("Mandatory options can't have default values"),
        )),
      );
    });
  });

  group('Given a configuration option definition', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
    );

    group('added to the arg parser', () {
      final parser = ArgParser();
      [projectIdOpt].prepareForParsing(parser);

      test('then it is listed as an option there', () async {
        expect(parser.options, contains('project-id'));
      });

      test('when present on the command line, then it is successfully parsed',
          () async {
        final results = parser.parse(['--project-id', '123']);
        expect(results.option('project-id'), '123');
      });

      test('when present on the command line, then it is marked as parsed',
          () async {
        final results = parser.parse(['--project-id', '123']);
        expect(results.wasParsed('project-id'), isTrue);
      });

      test(
          'when not present on the command line, then it is marked as not parsed',
          () async {
        final results = parser.parse(['123']);
        expect(results.wasParsed('project-id'), isFalse);
      });

      test('when misspelled on the command line, then it fails to parse',
          () async {
        expect(() => parser.parse(['--projectid', '123']),
            throwsA(isA<ArgParserException>()));
      });

      test('when present twice on the command line, the value is the last one',
          () async {
        final results =
            parser.parse(['--project-id', '123', '--project-id', '456']);
        expect(results.option('project-id'), '456');
      });
    });
  });

  group('Given a configuration option defined for all sources', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
      envName: 'PROJECT_ID',
      defaultFrom: _defaultValueFunction,
      defaultsTo: 'constDefaultValue',
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('then command line argument has first precedence', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('123'));
    });

    test('then env variable has second precedence', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('then defaultFrom function has second last precedence', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('defaultValueFunction'));
    });
  });

  group('Given a configuration option with a defaultsTo value', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
      envName: 'PROJECT_ID',
      defaultsTo: 'constDefaultValue',
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('then command line argument has first precedence', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('123'));
    });

    test('then env variable has second precedence', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('then defaultsTo value has last precedence', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.value(projectIdOpt), equals('constDefaultValue'));
    });
  });

  group('Given a configuration flag option', () {
    const verboseFlag = ConfigOption(
      argName: 'verbose',
      envName: 'VERBOSE',
      defaultsTo: 'false',
      isFlag: true,
    );
    final parser = ArgParser();
    [verboseFlag].prepareForParsing(parser);

    test('then command line argument has first precedence', () async {
      final argResults = parser.parse(['--verbose']);
      final envVars = {'VERBOSE': 'false'};
      final config = Configuration.fromEnvAndArgs(
        options: [verboseFlag],
        args: argResults,
        env: envVars,
      );
      expect(config.flag(verboseFlag), isTrue);
    });

    test('then env variable has second precedence', () async {
      final argResults = parser.parse([]);
      final envVars = {'VERBOSE': 'true'};
      final config = Configuration.fromEnvAndArgs(
        options: [verboseFlag],
        args: argResults,
        env: envVars,
      );
      expect(config.flag(verboseFlag), isTrue);
    });
  });

  group('Given a configuration flag option', () {
    const verboseFlag = ConfigOption(
      argName: 'verbose',
      envName: 'VERBOSE',
      defaultsTo: 'true',
      isFlag: true,
    );
    final parser = ArgParser();
    [verboseFlag].prepareForParsing(parser);

    test('then defaultsTo value has last precedence', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [verboseFlag],
        args: argResults,
        env: envVars,
      );
      expect(config.flag(verboseFlag), isTrue);
    });
  });

  group('Given an optional configuration option', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
      envName: 'PROJECT_ID',
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('when provided as argument then value() still throws StateError',
        () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(() => config.value(projectIdOpt), throwsA(isA<StateError>()));
    });

    test('when provided as env variable then value() still throws StateError',
        () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(() => config.value(projectIdOpt), throwsA(isA<StateError>()));
    });

    test('when not provided then calling value() throws StateError', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(() => config.value(projectIdOpt), throwsA(isA<StateError>()));
    });

    test('when provided as argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.valueOrNull(projectIdOpt), equals('123'));
    });

    test('when provided as env variable then parsing succeeds', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.valueOrNull(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing succeeds and results in null',
        () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.valueOrNull(projectIdOpt), isNull);
    });
  });

  group('Given a mandatory configuration option', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
      envName: 'PROJECT_ID',
      mandatory: true,
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('when provided as argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('123'));
    });

    test('when provided as env variable then parsing succeeds', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first, 'option `project-id` is mandatory');
      expect(() => config.value(projectIdOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given a valueRequired configuration option', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
      envName: 'PROJECT_ID',
      valueRequired: true,
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('when provided as argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('123'));
    });

    test('when provided as env variable then parsing succeeds', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first, 'option `project-id` is mandatory');
      expect(() => config.value(projectIdOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given a mandatory env-only configuration option', () {
    const projectIdOpt = ConfigOption(
      envName: 'PROJECT_ID',
      mandatory: true,
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('when provided as argument then parsing fails', () async {
      expect(() => parser.parse(['--project-id', '123']),
          throwsA(isA<ArgParserException>()));
    });

    test('when provided as env variable then parsing succeeds', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first,
          'environment variable `PROJECT_ID` is mandatory');
      expect(() => config.value(projectIdOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given a valueRequired env-only configuration option', () {
    const projectIdOpt = ConfigOption(
      envName: 'PROJECT_ID',
      valueRequired: true,
    );
    final parser = ArgParser();
    [projectIdOpt].prepareForParsing(parser);

    test('when provided as argument then parsing fails', () async {
      expect(() => parser.parse(['--project-id', '123']),
          throwsA(isA<ArgParserException>()));
    });

    test('when provided as env variable then parsing succeeds', () async {
      final argResults = parser.parse([]);
      final envVars = {'PROJECT_ID': '456'};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first,
          'environment variable `PROJECT_ID` is mandatory');
      expect(() => config.value(projectIdOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given invalid combinations of options', () {
    const argNameOpt = ConfigOption(
      argName: 'arg-name',
    );
    const envNameOpt = ConfigOption(
      envName: 'env-name',
    );
    const duplicateOpt = ConfigOption(
      argName: 'arg-name',
      envName: 'env-name',
      argPos: 0,
    );
    const argPosOpt = ConfigOption(
      argPos: 0,
    );
    const argPos2Opt = ConfigOption(
      argPos: 2,
    );

    test(
        'when duplicate arg names specified then InvalidOptionConfigurationException is thrown',
        () async {
      final parser = ArgParser();
      expect(() => [argNameOpt, duplicateOpt].prepareForParsing(parser),
          throwsA(isA<InvalidOptionConfigurationException>()));
    });

    test(
        'when duplicate env names specified then InvalidOptionConfigurationException is thrown',
        () async {
      final parser = ArgParser();
      expect(() => [envNameOpt, duplicateOpt].prepareForParsing(parser),
          throwsA(isA<InvalidOptionConfigurationException>()));
    });

    test(
        'when duplicate arg positions specified then InvalidOptionConfigurationException is thrown',
        () async {
      final parser = ArgParser();
      expect(() => [argPosOpt, duplicateOpt].prepareForParsing(parser),
          throwsA(isA<InvalidOptionConfigurationException>()));
    });

    test(
        'when non-consecutive arg positions specified then InvalidOptionConfigurationException is thrown',
        () async {
      final parser = ArgParser();
      expect(() => [argPosOpt, argPos2Opt].prepareForParsing(parser),
          throwsA(isA<InvalidOptionConfigurationException>()));
    });

    test(
        'when first arg position does not start at 0 then InvalidOptionConfigurationException is thrown',
        () async {
      final parser = ArgParser();
      expect(() => [argPos2Opt].prepareForParsing(parser),
          throwsA(isA<InvalidOptionConfigurationException>()));
    });
  });

  group('Given an optional positional argument option', () {
    const positionalOpt = ConfigOption(
      argPos: 0,
    );
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
    );
    final options = [positionalOpt, projectIdOpt];
    final parser = ArgParser();
    options.prepareForParsing(parser);

    test('when provided as lone positional argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(positionalOpt), equals('pos-arg'));
    });

    test('when provided before named argument then parsing succeeds', () async {
      final argResults = parser.parse(['pos-arg', '--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(positionalOpt), equals('pos-arg'));
    });

    test('when provided after named argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123', 'pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(positionalOpt), equals('pos-arg'));
    });

    test(
        'when not provided then parsing succeeds and value() throws StateError',
        () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(() => config.value(positionalOpt), throwsA(isA<StateError>()));
    });

    test('when not provided then parsing succeeds and its value is null',
        () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(positionalOpt), isNull);
    });
  });

  group('Given a mandatory positional argument option', () {
    const positionalOpt = ConfigOption(
      argPos: 0,
      mandatory: true,
    );
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
    );
    final options = [positionalOpt, projectIdOpt];
    final parser = ArgParser();
    options.prepareForParsing(parser);

    test('when provided as lone positional argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when provided before named argument then parsing succeeds', () async {
      final argResults = parser.parse(['pos-arg', '--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when provided after named argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123', 'pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first, 'positional argument 0 is mandatory');
      expect(() => config.value(positionalOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given a valueRequired positional argument option', () {
    const positionalOpt = ConfigOption(
      argPos: 0,
      valueRequired: true,
    );
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
    );
    final options = [positionalOpt, projectIdOpt];
    final parser = ArgParser();
    options.prepareForParsing(parser);

    test('when provided as lone positional argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when provided before named argument then parsing succeeds', () async {
      final argResults = parser.parse(['pos-arg', '--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when provided after named argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123', 'pos-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.value(positionalOpt), equals('pos-arg'));
    });

    test('when not provided then parsing has error', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(config.errors.first, 'positional argument 0 is mandatory');
      expect(() => config.value(positionalOpt), throwsA(isA<UsageException>()));
    });
  });

  group('Given two argument options that can be both positional and named', () {
    const firstOpt = ConfigOption(
      argName: 'first',
      argPos: 0,
    );
    const secondOpt = ConfigOption(
      argName: 'second',
      argPos: 1,
    );
    final options = [firstOpt, secondOpt];
    final parser = ArgParser();
    options.prepareForParsing(parser);

    test('when provided as lone positional argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['1st-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), isNull);
    });

    test('when provided as lone named argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['--first', '1st-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), isNull);
    });

    test(
        'when second pos arg is provided as lone named argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['--second', '2st-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), isNull);
      expect(config.valueOrNull(secondOpt), equals('2st-arg'));
    });

    test('when provided as two positional args then parsing succeeds',
        () async {
      final argResults = parser.parse(['1st-arg', '2nd-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test(
        'when provided as 1 positional & 1 named argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['1st-arg', '--second', '2nd-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test(
        'when provided as 1 named & 1 positional argument then parsing succeeds',
        () async {
      final argResults = parser.parse(['--first', '1st-arg', '2nd-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test(
        'when provided as 1 named & 1 positional argument in reverse order then parsing succeeds',
        () async {
      final argResults = parser.parse(['2nd-arg', '--first', '1st-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test('when provided as 2 named arguments then parsing succeeds', () async {
      final argResults =
          parser.parse(['--first', '1st-arg', '--second', '2nd-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test(
        'when provided as 2 named arguments in reverse order then parsing succeeds',
        () async {
      final argResults =
          parser.parse(['--second', '2nd-arg', '--first', '1st-arg']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test('when not provided then parsing succeeds and both are null', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, isEmpty);
      expect(config.valueOrNull(firstOpt), isNull);
      expect(config.valueOrNull(secondOpt), isNull);
    });

    test('when superfluous positional argument provided then parsing has error',
        () async {
      final argResults = parser.parse(['1st-arg', '2nd-arg', '3rd-arg']);
      final envVars = <String, String>{};

      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(
          config.errors.first, "Unexpected positional argument(s): '3rd-arg'");
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });

    test(
        'when superfluous positional argument provided after named args then parsing has error',
        () async {
      final argResults = parser
          .parse(['--first', '1st-arg', '--second', '2nd-arg', '3rd-arg']);
      final envVars = <String, String>{};

      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: argResults,
        env: envVars,
      );
      expect(config.errors, hasLength(1));
      expect(
          config.errors.first, "Unexpected positional argument(s): '3rd-arg'");
      expect(config.valueOrNull(firstOpt), equals('1st-arg'));
      expect(config.valueOrNull(secondOpt), equals('2nd-arg'));
    });
  });
}

/// Default value function for testing.
/// Needs to be a top-level function (or static method) in order to use it with a const constructor.
String _defaultValueFunction() {
  return 'defaultValueFunction';
}
