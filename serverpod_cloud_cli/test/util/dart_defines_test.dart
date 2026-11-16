import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/dart_defines.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

void main() {
  group('Given a dart define', () {
    test(
      'when parsing it then the key and value are split at the first "="',
      () {
        final define = DartDefines.parseDefine('QUERY=a=b');

        expect(define.key, 'QUERY');
        expect(define.value, 'a=b');
      },
    );

    test('when parsing one with an empty value then the value is empty', () {
      expect(DartDefines.parseDefine('FLAVOR=').value, '');
    });

    test('when parsing one without "=" then FormatException is thrown', () {
      expect(
        () => DartDefines.parseDefine('FLAVOR'),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'when parsing one with an empty key then FormatException is thrown',
      () {
        expect(
          () => DartDefines.parseDefine('=production'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  test('Given a JSON dart defines file when reading it '
      'then strings, numbers and booleans are strings', () async {
    await d.file('defines.json', '''
{"API_URL": "https://api.example.com", "RETRIES": 3, "DEBUG": false}
''').create();

    expect(DartDefines.readFile(_sandboxFile('defines.json')), {
      'API_URL': 'https://api.example.com',
      'RETRIES': '3',
      'DEBUG': 'false',
    });
  });

  test('Given a JSON dart defines file that is not valid JSON '
      'when reading it then FailureException is thrown', () async {
    await d.file('defines.json', '{"API_URL": ').create();

    expect(
      () => DartDefines.readFile(_sandboxFile('defines.json')),
      throwsA(isA<FailureException>()),
    );
  });

  test('Given a dart defines file that holds a JSON list '
      'when reading it then FailureException is thrown', () async {
    await d.file('defines.json', '["API_URL"]').create();

    expect(
      () => DartDefines.readFile(_sandboxFile('defines.json')),
      throwsA(isA<FailureException>()),
    );
  });

  test('Given a JSON dart defines file with a nested value '
      'when reading it then FailureException is thrown', () async {
    await d
        .file('defines.json', '{"API": {"URL": "https://api.example.com"}}')
        .create();

    expect(
      () => DartDefines.readFile(_sandboxFile('defines.json')),
      throwsA(isA<FailureException>()),
    );
  });

  test('Given a .env dart defines file when reading it '
      'then each KEY=VALUE line is a dart define', () async {
    await d.file('.env', '''
# The production settings
API_URL=https://api.example.com

DOUBLE="quoted # value"
SINGLE='single'
BACK=`back`
COMMENTED=value # comment
 SPACED = spaced value
EMPTY=
''').create();

    expect(DartDefines.readFile(_sandboxFile('.env')), {
      'API_URL': 'https://api.example.com',
      'DOUBLE': 'quoted # value',
      'SINGLE': 'single',
      'BACK': 'back',
      'COMMENTED': 'value',
      'SPACED': 'spaced value',
      'EMPTY': '',
    });
  });

  test(
    'Given a .env dart defines file with quoted values followed by '
    'comments when reading it then the quotes and comments are dropped',
    () async {
      await d.file('.env', '''
DOUBLE="double" # note
SINGLE='single' # note
BACK=`back` # note
''').create();

      expect(DartDefines.readFile(_sandboxFile('.env')), {
        'DOUBLE': 'double',
        'SINGLE': 'single',
        'BACK': 'back',
      });
    },
  );

  test('Given a .env dart defines file with an unquoted value that contains '
      '"#" when reading it then the value ends before "#"', () async {
    await d.file('.env', 'FLAVOR=production#eu\n').create();

    expect(DartDefines.readFile(_sandboxFile('.env')), {
      'FLAVOR': 'production',
    });
  });

  test('Given a .env dart defines file with a key that contains "." '
      'when reading it then FailureException is thrown', () async {
    await d.file('.env', 'api.url=https://api.example.com\n').create();

    expect(
      () => DartDefines.readFile(_sandboxFile('.env')),
      throwsA(isA<FailureException>()),
    );
  });

  test('Given a .env dart defines file with a multi-line value '
      'when reading it then FailureException is thrown', () async {
    await d.file('.env', 'CERTIFICATE="""\nline one\n"""\n').create();

    expect(
      () => DartDefines.readFile(_sandboxFile('.env')),
      throwsA(isA<FailureException>()),
    );
  });

  test('Given a .env dart defines file with a line without "=" '
      'when reading it then FailureException names the line', () async {
    await d.file('.env', 'API_URL=https://api.example.com\nFLAVOR\n').create();

    expect(
      () => DartDefines.readFile(_sandboxFile('.env')),
      throwsA(
        isA<FailureException>().having((e) => e.errors, 'errors', [
          contains('line 2'),
        ]),
      ),
    );
  });

  test('Given a dart defines file named .env.production with KEY=VALUE lines '
      'when reading it then each line is a dart define', () async {
    await d
        .file('.env.production', 'API_URL=https://api.example.com\n')
        .create();

    expect(DartDefines.readFile(_sandboxFile('.env.production')), {
      'API_URL': 'https://api.example.com',
    });
  });

  test('Given a dart defines file named .env with a JSON object '
      'when reading it then it is read as JSON', () async {
    await d.file('.env', '{"API_URL": "https://api.example.com"}').create();

    expect(DartDefines.readFile(_sandboxFile('.env')), {
      'API_URL': 'https://api.example.com',
    });
  });

  test('Given no dart defines file '
      'when reading it then FailureException is thrown', () {
    expect(
      () => DartDefines.readFile(_sandboxFile('missing.env')),
      throwsA(isA<FailureException>()),
    );
  });

  group('Given two dart defines files and dart defines', () {
    setUp(() async {
      await d.file('base.env', 'API_URL=https://base\nFLAVOR=base\n').create();
      await d.file('override.json', '{"FLAVOR": "staging"}').create();
    });

    test('when collecting them then a later value of a key replaces an '
        'earlier one', () {
      final dartDefines = DartDefines.collect(
        files: [_sandboxFile('base.env'), _sandboxFile('override.json')],
        defines: ['API_URL=https://override'],
      );

      expect(dartDefines, {'API_URL': 'https://override', 'FLAVOR': 'staging'});
    });

    test('when collecting them with an invalid dart define '
        'then FailureException is thrown', () {
      expect(
        () => DartDefines.collect(
          files: [_sandboxFile('base.env')],
          defines: ['FLAVOR'],
        ),
        throwsA(isA<FailureException>()),
      );
    });
  });
}

File _sandboxFile(String name) => File(p.join(d.sandbox, name));
