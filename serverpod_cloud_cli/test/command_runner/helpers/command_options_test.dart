import 'package:config/config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/command_runner/helpers/command_options.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

enum _ValueOptionsUnderTest<V> implements OptionDefinition<V> {
  value(ValueOption(argPos: 0, helpText: 'The value.')),
  valueFile(ValueFileOption(helpText: 'The file holding the value.'));

  const _ValueOptionsUnderTest(this.option);

  @override
  final ConfigOptionBase<V> option;
}

/// Resolves the value options from [args] without the usage validation that
/// the command runner applies, so that inputs the mandatory option group
/// rejects can reach [ValueOptionResolution.valueOrFileContent].
String _valueFromUnvalidatedArgs(List<String> args) {
  final configuration = Configuration<_ValueOptionsUnderTest>.resolveNoExcept(
    options: _ValueOptionsUnderTest.values,
    args: args,
  );

  return configuration.valueOrFileContent(
    value: _ValueOptionsUnderTest.value,
    valueFile: _ValueOptionsUnderTest.valueFile,
  );
}

void main() {
  group('Given the value options', () {
    test('when the value option is set '
        'then the value is returned', () {
      expect(_valueFromUnvalidatedArgs(['--value', 'the-value']), 'the-value');
    });

    test('when the value option is set to an empty string '
        'then the empty string is returned', () {
      expect(_valueFromUnvalidatedArgs(['--value', '']), '');
    });

    test('when the value file option is set '
        'then the full file content is returned', () async {
      await d.file('value.txt', 'first line\nsecond lïne\n').create();

      expect(
        _valueFromUnvalidatedArgs([
          '--from-file',
          p.join(d.sandbox, 'value.txt'),
        ]),
        'first line\nsecond lïne\n',
      );
    });

    test('when neither option is set '
        'then a StateError is thrown', () {
      expect(() => _valueFromUnvalidatedArgs([]), throwsA(isA<StateError>()));
    });
  });

  group('Given a ProjectIdOption', () {
    const option = ProjectIdOption();

    group('when the scloud project config and the project context both have '
        'values', () {
      test('then the project id is the scloud project config', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'scloud:/project/projectId': 'scloud-project',
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.value(option), 'scloud-project');
      });
    });

    group('when only the project context has a value', () {
      test('then the project id is the project context', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.value(option), 'settings-project');
      });
    });
  });

  group('Given a ProjectIdOption.nonMandatory', () {
    const option = ProjectIdOption.nonMandatory();

    group('when the scloud project config and the project context both have '
        'values', () {
      test('then the project id is the scloud project config', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'scloud:/project/projectId': 'scloud-project',
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.optionalValue(option), 'scloud-project');
      });
    });

    group('when only the project context has a value', () {
      test('then the project id is the project context', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.optionalValue(option), 'settings-project');
      });
    });

    group('when neither the scloud project config nor the project context has '
        'a value', () {
      test('then the option has no value', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({}),
        );

        expect(config.optionalValue(option), isNull);
      });
    });
  });

  group('Given a ProjectIdOption.nonMandatory with excludeSettings', () {
    const option = ProjectIdOption.nonMandatory(excludeSettings: true);

    group('when the scloud project config and the project context both have '
        'values', () {
      test('then the project id is the scloud project config', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'scloud:/project/projectId': 'scloud-project',
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.optionalValue(option), 'scloud-project');
      });
    });

    group('when only the scloud project config has a value', () {
      test('then the project id is the scloud project config', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'scloud:/project/projectId': 'scloud-project',
          }),
        );

        expect(config.optionalValue(option), 'scloud-project');
      });
    });

    group('when only the project context has a value', () {
      test('then the option has no value', () {
        final config = Configuration.resolveNoExcept(
          options: [option],
          configBroker: _MapConfigBroker({
            'settings:/project_context': 'settings-project',
          }),
        );

        expect(config.optionalValue(option), isNull);
      });
    });
  });
}

class _MapConfigBroker implements ConfigurationBroker {
  const _MapConfigBroker(this.values);

  final Map<String, String> values;

  @override
  String? valueOrNull(String key, Configuration cfg) => values[key];
}
