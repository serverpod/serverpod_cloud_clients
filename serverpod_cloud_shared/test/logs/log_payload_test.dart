import 'package:serverpod_cloud_shared/serverpod_cloud_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Given plain text content', () {
    test('then the whole line is the headline', () {
      final payload = LogPayload.parse('Server started');

      expect(payload.headline, 'Server started');
      expect(payload.fields, isEmpty);
      expect(payload.isStructured, isFalse);
    });
  });

  group('Given a Serverpod log entry', () {
    test('then the message is the headline', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":1,"serverId":"a","logLevel":"info",'
        '"message":"Handled request"}',
      );

      expect(payload.headline, 'Handled request');
      expect(payload.fields, isEmpty);
    });

    test('then the error is kept as a field', () {
      final payload = LogPayload.parse(
        '{"message":"Boom","error":"StateError","stackTrace":"#0 main"}',
      );

      expect(payload.headline, 'Boom');
      expect(payload.fields, {'error': 'StateError', 'stackTrace': '#0 main'});
    });
  });

  group('Given a Serverpod session entry', () {
    test('then the endpoint and method form the headline', () {
      final payload = LogPayload.parse(
        '{"id":3,"endpoint":"users","method":"read","duration":0.5}',
      );

      expect(payload.headline, 'users.read');
      expect(payload.fields, {'duration': 0.5});
    });
  });

  group('Given a Serverpod query entry', () {
    test('then the query is the headline', () {
      final payload = LogPayload.parse(
        '{"query":"SELECT 1","numRows":1,"slow":false}',
      );

      expect(payload.headline, 'SELECT 1');
      expect(payload.fields, {'numRows': 1, 'slow': false});
    });
  });

  group('Given a string-encoded payload', () {
    test('then the encoding is unwrapped', () {
      final payload = LogPayload.parse(r'"{\"message\":\"hi\"}"');

      expect(payload.headline, 'hi');
    });
  });

  group('Given unknown JSON', () {
    test('then every key stays a field and there is no headline', () {
      final payload = LogPayload.parse('{"foo":1,"bar":{"baz":2}}');

      expect(payload.headline, isNull);
      expect(payload.fields, {
        'foo': 1,
        'bar': {'baz': 2},
      });
    });

    test('then a nested value is formatted as indented JSON', () {
      expect(LogPayload.formatValue({'baz': 2}), '{\n  "baz": 2\n}');
    });
  });

  group('Given a JSON list', () {
    test('then the content is left untouched', () {
      final payload = LogPayload.parse('[1,2]');

      expect(payload.headline, '[1,2]');
      expect(payload.fields, isEmpty);
    });
  });

  group('Given null fields', () {
    test('then they are dropped', () {
      final payload = LogPayload.parse('{"message":"hi","error":null}');

      expect(payload.fields, isEmpty);
    });
  });
}
