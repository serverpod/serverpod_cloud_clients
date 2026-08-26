import 'dart:async' show Completer;

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

import 'output_widget.dart';

/// Base class for interactive widgets.
///
/// Interactive widgets provide a completer that will be completed with the
/// user's response.
///
/// Interactive widgets are non-const.
class InteractiveWidget<T> extends OutputWidget {
  final Completer<T> completer;

  InteractiveWidget() : completer = Completer<T>();
}

/// Renders a yes/no confirmation prompt.
class ConfirmationWidget extends InteractiveWidget<bool> {
  final String message;
  final bool? defaultValue;

  ConfirmationWidget(this.message, {this.defaultValue});

  @override
  void render({required final CommandLogger logger}) {
    logger
        .confirm(message, defaultValue: defaultValue)
        .then((final response) => completer.complete(response))
        .catchError((final error) => completer.completeError(error));
  }
}
