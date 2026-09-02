import 'package:serverpod_cloud_cli/util/output/output_context.dart';
import 'package:serverpod_cloud_cli/util/output/output_format.dart';
import 'package:test/test.dart';

void main() {
  group('Given an output context constructed with a string', () {
    late OutputContext context;

    setUp(() {
      context = OutputContext(OutputFormat.text, 'hello');
    });

    test('when looking up that string then the stored value is returned', () {
      expect(context.get<String>(), 'hello');
    });

    test('when looking up a missing type then lookup fails', () {
      expect(
        () => context.get<int>(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('int'),
          ),
        ),
      );
    });

    test('when putting another object then both values can be looked up', () {
      context.put(7);

      expect(context.get<String>(), 'hello');
      expect(context.get<int>(), 7);
    });

    test(
      'when putting a value of the same type then the new value is returned',
      () {
        context.put('replaced');

        expect(context.get<String>(), 'replaced');
      },
    );

    test('when reading the format then it is the constructed format', () {
      expect(context.format, OutputFormat.text);
    });

    test('when reading the error then it is absent', () {
      expect(context.find<QualifiedException>(), isNull);
    });
  });

  group('Given an output context constructed with a list', () {
    late OutputContext context;

    setUp(() {
      context = OutputContext(OutputFormat.json, <String>['alpha', 'beta']);
    });

    test('when looking up the list then the stored values are returned', () {
      expect(context.get<List<String>>(), ['alpha', 'beta']);
    });
  });

  group('Given an output context constructed from an exception', () {
    final exception = FormatException('boom');
    final stackTrace = StackTrace.current;
    late OutputContext context;

    setUp(() {
      context = OutputContext.exception(
        OutputFormat.yaml,
        exception,
        stackTrace,
      );
    });

    test(
      'when reading the error then the exception is the original instance',
      () {
        expect(context.get<QualifiedException>().exception, same(exception));
      },
    );

    test('when reading the error then the stack trace is preserved', () {
      expect(context.get<QualifiedException>().stackTrace, same(stackTrace));
    });

    test('when reading the format then it is the constructed format', () {
      expect(context.format, OutputFormat.yaml);
    });

    test('when looking up an object then lookup fails', () {
      expect(() => context.get<String>(), throwsA(isA<StateError>()));
    });
  });
}
