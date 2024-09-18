import 'package:args/args.dart';
import 'package:test/test.dart';
import 'package:serverpod_cloud_cli/util/configuration.dart';

void main() async {
  group('Given a configuration option definition', () {
    const projectIdOpt = ConfigOption(
      argName: 'project-id',
    );

    group('added to the arg parser', () {
      final parser = ArgParser();
      projectIdOpt.addToArgParser(parser);

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
            throwsA(isA<FormatException>()));
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
    [projectIdOpt].addToArgParser(parser);

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
    [projectIdOpt].addToArgParser(parser);

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
    [verboseFlag].addToArgParser(parser);

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
    [verboseFlag].addToArgParser(parser);

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
    [projectIdOpt].addToArgParser(parser);

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
    [projectIdOpt].addToArgParser(parser);

    test('when provided as argument then parsing succeeds', () async {
      final argResults = parser.parse(['--project-id', '123']);
      final envVars = <String, String>{};
      final config = Configuration.fromEnvAndArgs(
        options: [projectIdOpt],
        args: argResults,
        env: envVars,
      );
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
      expect(config.value(projectIdOpt), equals('456'));
    });

    test('when not provided then parsing throws ArgumentError', () async {
      final argResults = parser.parse([]);
      final envVars = <String, String>{};
      expect(
          () => Configuration.fromEnvAndArgs(
                options: [projectIdOpt],
                args: argResults,
                env: envVars,
              ),
          throwsA(isA<ArgumentError>()));
    });
  });
}

/// Default value function for testing.
/// Needs to be a top-level function (or static method) in order to use it with a const constructor.
String _defaultValueFunction() {
  return 'defaultValueFunction';
}
