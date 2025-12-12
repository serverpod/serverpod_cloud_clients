import 'package:serverpod_cloud_cli/util/scloud_config/json_to_yaml.dart';
import 'package:test/test.dart';

void main() {
  test('Given a single string value then converts to yaml', () {
    final data = {'singleValue': 'value1'};

    expect(jsonToYaml(data), '''
singleValue: "value1"
''');
  });

  test('Given a map value with keys then converts to yaml', () {
    final data = {
      'mapKey': {'key1': 'value1', 'key2': 'value2'},
    };

    expect(jsonToYaml(data), '''
mapKey:
  key1: "value1"
  key2: "value2"
''');
  });

  test('Given a map value without keys then converts to yaml', () {
    final data = {'mapKey': {}};

    expect(jsonToYaml(data), '''
mapKey: {}
''');
  });

  test('Given a nested map value then converts to yaml', () {
    final data = {
      'mapKey': {
        'nestedMap': {'key5': 'value5', 'key6': 'value6'},
      },
    };

    expect(jsonToYaml(data), '''
mapKey:
  nestedMap:
    key5: "value5"
    key6: "value6"
''');
  });

  test('Given a list value then converts to yaml', () {
    final data = {
      'listKey': ['value1', 'value2'],
    };

    expect(jsonToYaml(data), '''
listKey:
  - "value1"
  - "value2"
''');
  });

  test('Given an empty list value then converts to yaml', () {
    final data = {'listKey': []};

    expect(jsonToYaml(data), '''
listKey: []
''');
  });

  test('Given nested list values then converts to yaml', () {
    final data = {
      'listKey': [
        'value1',
        ['value2', 'value3'],
      ],
    };

    expect(jsonToYaml(data), '''
listKey:
  - "value1"
  -
    - "value2"
    - "value3"
''');
  });

  test('Given nested empty list then converts to yaml', () {
    final data = {
      'listKey': ['value1', []],
    };

    expect(jsonToYaml(data), '''
listKey:
  - "value1"
  - []
''');
  });

  test('Given a nested list in a nested map then converts to yaml', () {
    final data = {
      'mapKey': {
        'key1': 'value1',
        'key2': 'value2',
        'nestedMap': {
          'nestedList': ['value3'],
          'key4': 'value4',
        },
      },
    };

    expect(jsonToYaml(data), '''
mapKey:
  key1: "value1"
  key2: "value2"
  nestedMap:
    nestedList:
      - "value3"
    key4: "value4"
''');
  });

  test('Given a nested map in a list then converts to yaml', () {
    final data = {
      'listKey': [
        'value1',
        {'key1': 'value1', 'key2': 'value2'},
      ],
    };

    expect(jsonToYaml(data), '''
listKey:
  - "value1"
  -
    key1: "value1"
    key2: "value2"
''');
  });

  test('Given a nested empty map in a list then converts to yaml', () {
    final data = {
      'listKey': ['value1', {}],
    };

    expect(jsonToYaml(data), '''
listKey:
  - "value1"
  - {}
''');
  });

  test('Given both lists and maps then converts to yaml', () {
    final data = {
      'mapKey': {'key1': 'value1', 'key2': 'value2'},
      'listKey': ['value3', 'value4'],
    };

    expect(jsonToYaml(data), '''
mapKey:
  key1: "value1"
  key2: "value2"
listKey:
  - "value3"
  - "value4"
''');
  });
}
