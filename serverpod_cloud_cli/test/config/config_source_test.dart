import 'package:args/args.dart';
import 'package:test/test.dart';

import 'package:serverpod_cloud_cli/util/config/config.dart';

void main() {
  group(
      'Given a MultiDomainConfigBroker with two domains and correctly configured options',
      () {
    const yamlContentOpt = StringOption(
      argName: 'yaml-content',
      envName: 'YAML_CONTENT',
    );
    const jsonContentOpt = StringOption(
      argName: 'json-content',
      envName: 'JSON_CONTENT',
    );
    const yamlProjectIdOpt = StringOption(
      configKey: 'yamlOption:/project/projectId',
    );
    const jsonProjectIdOpt = StringOption(
      configKey: 'jsonOption:/project/projectId',
    );
    final options = [
      yamlContentOpt,
      jsonContentOpt,
      yamlProjectIdOpt,
      jsonProjectIdOpt,
    ];

    late ConfigurationBroker configSource;

    setUp(() {
      configSource = MultiDomainConfigBroker.prefix({
        'yamlOption': OptionContentConfigProvider(
          contentOption: yamlContentOpt,
          format: ConfigEncoding.yaml,
        ),
        'jsonOption': OptionContentConfigProvider(
          contentOption: jsonContentOpt,
          format: ConfigEncoding.json,
        ),
      });
    });

    test(
        'when the YAML content option has data '
        ' then the correct value is retrieved', () async {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: parser.parse([
          '--yaml-content',
          '''
project:
  projectId: 123
''',
        ]),
        configBroker: configSource,
      );

      expect(config.errors, isEmpty);
      expect(config.optionalValue(yamlProjectIdOpt), equals('123'));
      expect(config.optionalValue(jsonProjectIdOpt), isNull);
    });

    test(
        'when the JSON content option has data '
        ' then the correct value is retrieved', () async {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: parser.parse([
          '--json-content',
          '''
{
  "project": {
    "projectId": 123
  }
}
''',
        ]),
        configBroker: configSource,
      );

      expect(config.errors, isEmpty);
      expect(config.optionalValue(yamlProjectIdOpt), isNull);
      expect(config.optionalValue(jsonProjectIdOpt), equals('123'));
    });

    test(
        'when the YAML content option has malformed data '
        ' then an appropriate error is registered', () async {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: parser.parse([
          '--yaml-content',
          '''
project:
projectId:123
''',
        ]),
        configBroker: configSource,
      );

      expect(
          config.errors,
          contains(contains(
            'Failed to resolve configuration key `yamlOption:/project/projectId`: Error on line',
          )));
      expect(
        () => config.optionalValue(yamlProjectIdOpt),
        throwsA(isA<StateError>()),
      );
      expect(config.optionalValue(jsonProjectIdOpt), isNull);
    });

    test(
        'when the JSON content option has malformed data '
        ' then an appropriate error is registered', () async {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      final config = Configuration.fromEnvAndArgs(
        options: options,
        args: parser.parse([
          '--json-content',
          '''
{
  "project": {
    "projectId":
  }
}
''',
        ]),
        configBroker: configSource,
      );

      expect(
          config.errors,
          contains(contains(
            'Failed to resolve configuration key `jsonOption:/project/projectId`: FormatException: Unexpected character',
          )));
      expect(
        () => config.optionalValue(jsonProjectIdOpt),
        throwsA(isA<StateError>()),
      );
      expect(config.optionalValue(yamlProjectIdOpt), isNull);
    });
  });

  group(
      'Given a MultiDomainConfigBroker with a domain and misconfigured options',
      () {
    const yamlContentOpt = StringOption(
      argName: 'yaml-content',
      envName: 'YAML_CONTENT',
    );
    const yamlProjectIdOpt = StringOption(
      configKey: 'yamlOption:/project/projectId',
    );
    const missingDomainOpt = StringOption(
      configKey: '/project/projectId',
    );
    const unknownDomainOpt = StringOption(
      configKey: 'unknown:/project/projectId',
    );
    final options = [
      yamlContentOpt,
      yamlProjectIdOpt,
      missingDomainOpt,
      unknownDomainOpt,
    ];

    late ConfigurationBroker configSource;

    setUp(() {
      configSource = MultiDomainConfigBroker.prefix({
        'yamlOption': OptionContentConfigProvider(
          contentOption: yamlContentOpt,
          format: ConfigEncoding.yaml,
        ),
      });
    });

    test(
        'when creating the configuration '
        ' then the expected errors are registered', () async {
      final parser = ArgParser();
      options.prepareForParsing(parser);
      final config = Configuration.fromEnvAndArgs(
        options: options,
        configBroker: configSource,
      );

      expect(
          config.errors,
          containsAll([
            'Failed to resolve configuration key `/project/projectId`: Bad state: No matching configuration domain for key: /project/projectId',
            'Failed to resolve configuration key `unknown:/project/projectId`: Bad state: No matching configuration domain for key: unknown:/project/projectId',
          ]));
    });
  });
}
