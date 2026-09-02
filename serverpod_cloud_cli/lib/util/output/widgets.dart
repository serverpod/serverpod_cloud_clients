import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_context.dart';
import 'output_format.dart';
import 'output_formatter.dart';
import 'output_widget.dart';

class FormatBranchingWidget extends OutputWidget {
  final OutputWidget textWidget;
  final OutputWidget jsonWidget;
  final OutputWidget yamlWidget;

  const FormatBranchingWidget({
    required this.textWidget,
    required this.jsonWidget,
    required this.yamlWidget,
  });

  @override
  OutputWidget build(OutputContext context) {
    final format = context.format;
    return switch (format) {
      OutputFormat.text => textWidget,
      OutputFormat.json => jsonWidget,
      OutputFormat.yaml => yamlWidget,
    };
  }
}

/// Renders an error widget if the context contains a matching exception.
/// Otherwise it renders the [elseWidget] if provided.
class ExceptionHandlingWidget<E extends Exception> extends OutputWidget {
  final OutputWidget Function(E exception) errorWidgetMaker;
  final OutputWidget? elseWidget;

  const ExceptionHandlingWidget({
    required this.errorWidgetMaker,
    this.elseWidget,
  });

  @override
  OutputWidget build(OutputContext context) {
    final error = context.find<QualifiedException>();
    if (error?.exception case final E e) {
      return errorWidgetMaker(e);
    }
    return elseWidget ?? this;
  }
}

/// Renders a raw string.
class RawStringWidget extends OutputWidget {
  final String content;

  const RawStringWidget(this.content);

  @override
  void render({required CommandLogger logger}) {
    logger.raw(content);
  }
}

/// Renders an "info text" message.
class InfoTextWidget extends OutputWidget {
  final String message;
  final bool? newParagraph;

  const InfoTextWidget(this.message, {this.newParagraph});

  @override
  void render({required CommandLogger logger}) {
    logger.info(message, newParagraph: newParagraph ?? false);
  }
}

/// Renders a success message.
class SuccessTextWidget extends OutputWidget {
  final String message;
  final bool? newParagraph;

  const SuccessTextWidget(this.message, {this.newParagraph});

  @override
  void render({required CommandLogger logger}) {
    logger.success(message, newParagraph: newParagraph ?? false);
  }
}

/// Renders a "command hint" message.
class CommandHintTextWidget extends OutputWidget {
  final String? message;
  final String command;
  final bool? newParagraph;

  const CommandHintTextWidget(
    this.message, {
    required this.command,
    this.newParagraph,
  });

  const CommandHintTextWidget.command(this.command, {this.newParagraph})
    : message = null;

  @override
  void render({required CommandLogger logger}) {
    logger.terminalCommand(
      command,
      message: message,
      newParagraph: newParagraph ?? false,
    );
  }
}

/// Renders a string formatted with the given formatter.
///
/// O is the object type to format.
class FormattedStringWidget<O extends Object> extends OutputWidget {
  final OutputFormatter<O, String> formatter;

  const FormattedStringWidget({required this.formatter});

  @override
  OutputWidget build(OutputContext context) {
    final object = context.get<O>();
    final content = formatter.format(object);
    return RawStringWidget(content);
  }
}

abstract class ErrorWidget extends OutputWidget {
  const ErrorWidget();
}

class TextErrorWidget extends ErrorWidget {
  const TextErrorWidget();

  @override
  OutputWidget build(OutputContext context) {
    final error = context.get<QualifiedException>();
    return TextErrorOutputWidget(
      error,
      message: error.exception.toString(),
      exception: error.exception,
      stackTrace: error.stackTrace,
    );
  }
}

class JsonErrorWidget extends ErrorWidget {
  const JsonErrorWidget();

  @override
  OutputWidget build(OutputContext context) {
    final error = context.get<QualifiedException>();
    return JsonErrorOutputWidget(error);
  }
}

class YamlErrorWidget extends ErrorWidget {
  const YamlErrorWidget();

  @override
  OutputWidget build(OutputContext context) {
    final error = context.get<QualifiedException>();
    return YamlErrorOutputWidget(error);
  }
}

abstract class ErrorOutputWidget extends OutputWidget {
  final Object error;

  const ErrorOutputWidget(this.error);
}

class TextErrorOutputWidget extends ErrorOutputWidget {
  final String? message;
  final String? hint;
  final Exception? exception;
  final StackTrace? stackTrace;
  final bool newParagraph;

  const TextErrorOutputWidget(
    super.error, {
    this.message,
    this.hint,
    this.exception,
    this.stackTrace,
    this.newParagraph = false,
  });

  @override
  void render({required CommandLogger logger}) {
    logger.error(
      message ?? error.toString(),
      hint: hint,
      exception: exception,
      stackTrace: stackTrace,
      newParagraph: newParagraph,
    );
  }
}

class JsonErrorOutputWidget extends ErrorOutputWidget {
  const JsonErrorOutputWidget(super.error);

  @override
  void render({required CommandLogger logger}) {
    final content = JsonOutputFormatter().format(error);
    logger.error(content);
  }
}

class YamlErrorOutputWidget extends ErrorOutputWidget {
  const YamlErrorOutputWidget(super.error);

  @override
  void render({required CommandLogger logger}) {
    final content = YamlOutputFormatter().format(error);
    logger.error(content);
  }
}
