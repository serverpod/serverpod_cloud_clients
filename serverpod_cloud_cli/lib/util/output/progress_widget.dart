import 'dart:async';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/util/inline_tui/inline_tui.dart';

import 'output_context.dart';
import 'output_widget.dart';

/// Shows a heading-only spinner while consuming a [Stream].
///
/// Uses [ScrollingSection.runSpinner]; it does not call
/// [CommandLogger.progressStream].
///
/// [stream] may be omitted when the output context holds a `Stream<T>`.
class ProgressStreamWidget<T extends Object> extends OutputWidget {
  final String initialMessage;
  final Stream<T>? stream;
  final String? successMessage;
  final String? failedMessage;
  final String Function(T)? toMessage;
  final bool Function(T)? isSuccess;
  final bool newParagraph;

  ProgressStreamWidget({
    required this.initialMessage,
    this.stream,
    this.successMessage,
    this.failedMessage,
    this.toMessage,
    this.isSuccess,
    this.newParagraph = false,
  });

  @override
  OutputWidget build(OutputContext context) {
    return _ProgressStreamRenderer<T>(
      initialMessage: initialMessage,
      stream: stream ?? context.get<Stream<T>>(),
      successMessage: successMessage,
      failedMessage: failedMessage,
      toMessage: toMessage,
      isSuccess: isSuccess,
      newParagraph: newParagraph,
    );
  }
}

class _ProgressStreamRenderer<T extends Object> extends OutputWidget {
  final String initialMessage;
  final Stream<T> stream;
  final String? successMessage;
  final String? failedMessage;
  final String Function(T)? toMessage;
  final bool Function(T)? isSuccess;
  final bool newParagraph;

  const _ProgressStreamRenderer({
    required this.initialMessage,
    required this.stream,
    required this.successMessage,
    required this.failedMessage,
    required this.toMessage,
    required this.isSuccess,
    required this.newParagraph,
  });

  @override
  Future<void> renderAsync({required CommandLogger logger}) async {
    if (newParagraph) {
      logger.inlineTerminal.write('\n');
    }

    await ScrollingSection.runSpinner<T>(
      logger.inlineTerminal,
      heading: initialMessage,
      stream: stream,
      toMessage: toMessage,
      isSuccess: isSuccess,
      successMessage: successMessage,
      failedMessage: failedMessage,
    );
  }
}
