import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_context.dart';
import 'output_formatter.dart';
import 'output_widget.dart';

/// Renders a raw string.
class RawStringWidget extends OutputWidget {
  final String content;

  const RawStringWidget(this.content);

  @override
  void render({required final CommandLogger logger}) {
    logger.raw(content);
  }
}

/// Renders an "info text" message.
class InfoTextWidget extends OutputWidget {
  final String message;
  final bool? newParagraph;

  const InfoTextWidget(this.message, {this.newParagraph});

  @override
  void render({required final CommandLogger logger}) {
    logger.info(message, newParagraph: newParagraph ?? false);
  }
}

/// Renders a success message.
class SuccessTextWidget extends OutputWidget {
  final String message;
  final bool? newParagraph;

  const SuccessTextWidget(this.message, {this.newParagraph});

  @override
  void render({required final CommandLogger logger}) {
    logger.success(message, newParagraph: newParagraph ?? false);
  }
}

/// Renders a "command hint" message.
class CommandHintTextWidget extends OutputWidget {
  final String message;
  final String command;
  final bool? newParagraph;

  const CommandHintTextWidget(
    this.message, {
    required this.command,
    this.newParagraph,
  });

  @override
  void render({required final CommandLogger logger}) {
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
  OutputWidget build(final OutputContext context) {
    final object = context.get<O>();
    final content = formatter.format(object);
    return RawStringWidget(content);
  }
}

abstract class ErrorWidget extends OutputWidget {
  final Object error;

  const ErrorWidget(this.error);
}

class TextErrorWidget extends ErrorWidget {
  const TextErrorWidget(super.error);

  @override
  void render({required final CommandLogger logger}) {
    logger.error(error.toString());
  }
}

class JsonErrorWidget extends ErrorWidget {
  const JsonErrorWidget(super.error);

  @override
  void render({required final CommandLogger logger}) {
    final content = JsonOutputFormatter().format(error);
    logger.error(content);
  }
}

class YamlErrorWidget extends ErrorWidget {
  const YamlErrorWidget(super.error);

  @override
  void render({required final CommandLogger logger}) {
    final content = YamlOutputFormatter().format(error);
    logger.error(content);
  }
}
