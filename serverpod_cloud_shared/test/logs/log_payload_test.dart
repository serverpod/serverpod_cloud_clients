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
        '{"sessionLogId":1,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"logLevel":"info","message":"Handled request","order":0}',
      );

      expect(payload.headline, 'Handled request');
      expect(payload.fields, isEmpty);
    });

    test('then its log level index is read as a named level', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":1,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"logLevel":3,"message":"Boom","order":0}',
      );

      expect(payload.logLevel, 'ERROR');
    });

    test('then a log level name is read in upper case', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":1,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"logLevel":"warning","message":"Careful","order":0}',
      );

      expect(payload.logLevel, 'WARNING');
    });

    test('then its session log id is read', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":42,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"logLevel":1,"message":"Hi","order":0}',
      );

      expect(payload.sessionLogId, 42);
    });

    test('then the error is kept as a field', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":1,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"logLevel":"error","message":"Boom","order":0,'
        '"error":"StateError","stackTrace":"#0 main"}',
      );

      expect(payload.headline, 'Boom');
      expect(payload.fields, {'error': 'StateError', 'stackTrace': '#0 main'});
    });
  });

  group('Given a Serverpod session entry', () {
    test('then the endpoint and method form the headline', () {
      final payload = LogPayload.parse(
        '{"id":3,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"touched":"2026-01-01T00:00:01Z","endpoint":"users",'
        '"method":"read","duration":0.5}',
      );

      expect(payload.headline, 'users.read');
      expect(payload.fields, {'duration': 0.5});
    });

    test('then its id is read as the session log id', () {
      final payload = LogPayload.parse(
        '{"id":3,"serverId":"a","time":"2026-01-01T00:00:00Z",'
        '"touched":"2026-01-01T00:00:01Z","endpoint":"users",'
        '"method":"read","duration":0.5}',
      );

      expect(payload.sessionLogId, 3);
    });
  });

  group('Given a Serverpod query entry', () {
    test('then the query is the headline', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":1,"serverId":"a","query":"SELECT 1",'
        '"duration":0.1,"slow":false,"order":0,"numRows":1}',
      );

      expect(payload.headline, 'SELECT 1');
      expect(payload.fields, {'duration': 0.1, 'slow': false, 'numRows': 1});
    });

    test('then its session log id is read', () {
      final payload = LogPayload.parse(
        '{"sessionLogId":7,"serverId":"a","query":"SELECT 1",'
        '"duration":0.1,"slow":false,"order":0}',
      );

      expect(payload.sessionLogId, 7);
    });
  });

  group('Given a string-encoded payload', () {
    test('then the encoding is unwrapped', () {
      final payload = LogPayload.parse(
        r'"{\"sessionLogId\":1,\"serverId\":\"a\",'
        r'\"time\":\"2026-01-01T00:00:00Z\",\"logLevel\":\"info\",'
        r'\"message\":\"hi\",\"order\":0}"',
      );

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

    test('then no session log id is read', () {
      final payload = LogPayload.parse('{"sessionLogId":42,"foo":1}');

      expect(payload.sessionLogId, isNull);
    });

    test('then no log level is read', () {
      final payload = LogPayload.parse('{"logLevel":3,"foo":1}');

      expect(payload.logLevel, isNull);
    });

    test('then keys that Serverpod hides stay fields', () {
      final payload = LogPayload.parse(
        '{"id":"external-1","message":"event","foo":1}',
      );

      expect(payload.headline, isNull);
      expect(payload.fields, {
        'id': 'external-1',
        'message': 'event',
        'foo': 1,
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
      final payload = LogPayload.parse('{"foo":1,"error":null}');

      expect(payload.fields, {'foo': 1});
    });
  });
}
