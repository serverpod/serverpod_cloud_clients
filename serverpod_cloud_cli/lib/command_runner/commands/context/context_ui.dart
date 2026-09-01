import 'package:serverpod_cloud_cli/command_runner/ui/ui.dart';

class ContextShowTextUi extends OutputWidget {
  const ContextShowTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final projectContext = result['projectContext'];
    if (projectContext is! String) {
      return const InfoTextWidget('No global project context is set.');
    }
    return InfoTextWidget(projectContext);
  }
}

class ContextSetTextUi extends OutputWidget {
  const ContextSetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    final result = context.get<Map<String, Object?>>();
    final projectId = result['projectId'];
    return SuccessTextWidget('Set the global project context to "$projectId".');
  }
}

class ContextUnsetTextUi extends OutputWidget {
  const ContextUnsetTextUi();

  @override
  OutputWidget build(final OutputContext context) {
    return const SuccessTextWidget('Unset the global project context.');
  }
}
