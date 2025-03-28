import 'dart:convert';
import 'dart:io';

class MockStdout implements Stdout {
  final _buffer = StringBuffer();

  @override
  final bool supportsAnsiEscapes;

  MockStdout({this.supportsAnsiEscapes = false});

  @override
  Encoding encoding = utf8;

  @override
  String lineTerminator = '\n';

  String get output => _buffer.toString();

  @override
  void add(final List<int> data) {
    _buffer.write(utf8.decode(data));
  }

  @override
  void addError(final Object error, [final StackTrace? stackTrace]) {
    throw UnimplementedError();
  }

  @override
  Future addStream(final Stream<List<int>> stream) {
    throw UnimplementedError();
  }

  @override
  Future close() {
    return Future.value();
  }

  @override
  Future get done => Future.value();

  @override
  Future flush() {
    return Future.value();
  }

  @override
  bool get hasTerminal => true;

  @override
  IOSink get nonBlocking => throw UnimplementedError();

  @override
  int get terminalColumns => 80;

  @override
  int get terminalLines => 24;

  @override
  void write(final Object? object) {
    _buffer.write(object);
  }

  @override
  void writeAll(final Iterable objects, [final String sep = ""]) {
    _buffer.writeAll(objects, sep);
  }

  @override
  void writeCharCode(final int charCode) {
    _buffer.writeCharCode(charCode);
  }

  @override
  void writeln([final Object? object = ""]) {
    _buffer.writeln(object);
  }
}
