import 'dart:convert';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/constants.dart' show numTimeStampChars;
import 'package:serverpod_cloud_cli/util/common.dart';
import 'package:serverpod_cloud_cli/util/duration_formatter.dart';
import 'package:serverpod_cloud_cli/util/printers/table_printer.dart';
import 'package:yaml_codec/yaml_codec.dart';

/// The supported output formats.
enum OutputFormat {
  text,
  json,
  yaml;

  bool get isStructured => this != OutputFormat.text;
}

/// Defines the schema for a field in an object.
class OutputSchemaField<T extends Object> {
  final String name;
  final String label;
  final Object? Function(T object) value;

  OutputSchemaField({
    required this.name,
    required this.label,
    required this.value,
  });
}

/// Defines the schema for an object.
class OutputSchemaObject<T extends Object> {
  OutputSchemaObject(this.fields);

  final List<OutputSchemaField<T>> fields;
}

/// Base class for all command output types.
/// An instance of this type is typically passed to command implementations,
/// which shall be agnostic of the output format.
sealed class CommandOutput {
  final CommandLogger logger;

  CommandOutput({required this.logger});

  /// Creates a new instance for the given output type and settings.
  factory CommandOutput.forFormat(
    final OutputFormat format,
    final CommandLogger logger, {
    final bool utc = false,
  }) {
    return switch (format) {
      OutputFormat.text => TextOutput(logger: logger, utc: utc),
      OutputFormat.json => JsonOutput(logger: logger),
      OutputFormat.yaml => YamlOutput(logger: logger),
    };
  }

  /// Outputs a single object.
  void outputObject<T extends Object>(
    final T object,
    final OutputSchemaObject<T> schema,
  );

  /// Outputs a list of objects.
  void outputList<T extends Object>(
    final List<T> objects,
    final OutputSchemaObject<T> schema, {
    final void Function(CommandLogger logger)? onEmpty,
  });

  /// Outputs an error.
  void error(
    final String message, {
    final Exception? exception,
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
    final bool forcePrintStackTrace = false,
    final int? exitCode,
  });
}

/// Outputs objects in text format.
/// The output may be enriched with terminal-supported formatting.
class TextOutput extends CommandOutput {
  final bool utc;

  TextOutput({required super.logger, this.utc = false});

  @override
  void outputObject<T extends Object>(
    final T object,
    final OutputSchemaObject<T> schema,
  ) {
    outputList([object], schema);
  }

  @override
  void outputList<T extends Object>(
    final List<T> objects,
    final OutputSchemaObject<T> schema, {
    final void Function(CommandLogger logger)? onEmpty,
  }) {
    if (objects.isEmpty && onEmpty != null) {
      onEmpty(logger);
      return;
    }

    final printer = TablePrinter(
      headers: [for (final column in schema.fields) column.label],
      rows: [
        for (final obj in objects)
          [
            for (final column in schema.fields)
              _tableCell(column.value(obj), utc: utc),
          ],
      ],
    );
    printer.writeLines(logger.line);
  }

  @override
  void error(
    final String message, {
    final Exception? exception,
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
    final bool forcePrintStackTrace = false,
    final int? exitCode,
  }) {
    logger.error(
      message,
      exception: exception,
      hint: hint,
      newParagraph: newParagraph,
      stackTrace: stackTrace,
      forcePrintStackTrace: forcePrintStackTrace,
    );
  }
}

/// Base class for the structured output types.
sealed class StructuredOutput extends CommandOutput {
  StructuredOutput({required super.logger});

  String _encode(final Object? object);

  @override
  void outputObject<T extends Object>(
    final T object,
    final OutputSchemaObject<T> schema,
  ) {
    final payload = {
      for (final field in schema.fields)
        field.name: _structuredValue(field.value(object)),
    };
    final encoded = _encode(payload);
    logger.raw(encoded);
  }

  @override
  void outputList<T extends Object>(
    final List<T> objects,
    final OutputSchemaObject<T> schema, {
    final void Function(CommandLogger logger)? onEmpty,
  }) {
    final encoded = _encode(_toOutputListPayload(objects, schema));
    logger.raw(encoded);
  }

  @override
  void error(
    final String message, {
    final Exception? exception,
    final String? hint,
    final bool newParagraph = false,
    final StackTrace? stackTrace,
    final bool forcePrintStackTrace = false,
    final int? exitCode,
  }) {
    final encoded = _encode({
      'message': message,
      if (hint != null) 'hint': hint,
      if (exception != null) 'exception': exception.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (exitCode != null) 'exitCode': exitCode,
    });

    logger.raw(encoded, logLevel: LogLevel.error);
  }
}

class JsonOutput extends StructuredOutput {
  JsonOutput({required super.logger});

  @override
  String _encode(final Object? object) {
    return jsonEncode(object);
  }
}

class YamlOutput extends StructuredOutput {
  YamlOutput({required super.logger});

  @override
  String _encode(final Object? object) {
    return yamlEncode(object);
  }
}

List<Map<String, Object?>> _toOutputListPayload<T extends Object>(
  final List<T> objects,
  final OutputSchemaObject<T> schema,
) {
  return [
    for (final obj in objects)
      {
        for (final field in schema.fields)
          field.name: _structuredValue(field.value(obj)),
      },
  ];
}

Object? _structuredValue(final Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }
  if (value is Duration) {
    return value.inSeconds;
  }
  if (value is Enum) {
    return value.name;
  }
  if (value is List) {
    return [for (final element in value) _structuredValue(element)];
  }
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _structuredValue(entry.value),
    };
  }
  if (value is num || value is bool || value is String) {
    return value;
  }
  return value.toString();
}

String? _tableCell(final Object? value, {required final bool utc}) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toTzString(utc, numTimeStampChars);
  }
  if (value is Duration) {
    return value.friendlyFormat();
  }
  if (value is List) {
    return [
      for (final element in value) _tableCell(element, utc: utc) ?? '',
    ].join(', ');
  }
  if (value is Enum) {
    return value.name;
  }
  return value.toString();
}
