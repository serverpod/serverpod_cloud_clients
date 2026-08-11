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
String _valueFromUnvalidatedArgs(final List<String> args) {
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
}
